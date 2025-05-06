//
//  ChatController.swift
//  Locus
//
//  Created by Banibe Ebegbodi on 3/20/25.
//

import SwiftUI
import OpenAI
import Speech
import AVFoundation


class ChatController: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isStreaming = false
    @Published var currentStreamedText = ""
    @Published var targetLanguageCode: String = "fr-FR"
    private var settings: AppSettings
    var audioPlayer: AVAudioPlayer?
        
    //store the settings
    init(settings: AppSettings) {
        self.settings = settings
        self.targetLanguageCode = preferredLocale(for: settings.targetLanguage)
    }
    
    //exchanging the target lang name for google voice to understand
    func preferredLocale(for languageCode: String) -> String {
        switch languageCode {
            case "en": return "en-US"
            case "fr": return "fr-FR"
            case "es": return "es-ES"
            case "de": return "de-DE"
            case "ja": return "ja-JP"
            case "ta": return "ta-IN"
            case "zh": return "cmn-CN"
            case "ko": return "ko-KR"
            case "vi": return "vi-VN"
            case "ar": return "ar-XA"
            case "gu": return "gu-IN"
            case "hi": return "hi-IN"
            case "mr": return "mr-IN"
            case "pt": return "pt-BR"
            case "te": return "te-IN"
            default:
                let fallback = languageCode + "-" + languageCode.uppercased()
                        print("Fallback locale used: \(fallback)")
                        return fallback
        }
    }
        
    //OpenAI api key
    let openAI = OpenAI(apiToken: "YOUR-OPENAI-API-KEY")
    
    func sendNewMessage(content: String) {
        //Don't add empty messages
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        //Check if this is a duplicate of the last message
        if let lastMessage = messages.last, lastMessage.isUser && lastMessage.content == content {
            print("Duplicate message detected - ignoring")
            return
        }
        
        let userMessage = Message(content: content, isUser: true)
        self.messages.append(userMessage)
        getStreamingReply()
    }
    
    func getStreamingReply() {
        // Reset streamed text
        currentStreamedText = ""
        isStreaming = true
        
        //add a placeholder message for the streaming content
        let placeholderID = UUID()
        let placeholderMessage = Message(id: placeholderID, content: "", isUser: false)
        DispatchQueue.main.async {
            self.messages.append(placeholderMessage)
        }
        
        let query = ChatQuery(
            messages: [
                .init(role: .system, content: createSystemPrompt())!
            ] + self.messages.filter { $0.id != placeholderID }.map({
                .init(role: $0.isUser ? .user : .assistant, content: $0.content)!
            }),
            model: .gpt4_o
        )
        
        //system prompt for basic chatting
        func createSystemPrompt() -> String {
            let locale = Locale(identifier: "en")
            
            //use the settings that were passed to the controller during init
            let knownLanguageCode = settings.knownLanguage
            let targetLanguageCode = self.targetLanguageCode
            let languageLevel = settings.languageLevel
            
            //convert language codes to readable language names
            let knownLanguageName = locale.localizedString(forLanguageCode: knownLanguageCode) ?? "their native language"
            let targetLanguageName = locale.localizedString(forLanguageCode: targetLanguageCode.split(separator: "-").first?.description ?? "") ?? "the target language"
            
            //prompt
            return """
            Your name is Locus, a friendly and encouraging barista in a language learning enviornment specializing in \(targetLanguageName). 
            Your personality is warm, patient, and slightly playful. You occasionally use humor to make learning fun.
            
            The user is speaking to you in a cafe to practice their \(targetLanguageName) with relavent vocabulary to the cafe as well as casual small talk.
            Their native language is \(knownLanguageName).
            Their proficiency level is \(languageLevel).
            
            Help users practice with ordering food, pricing of items, asking if they are enjoying their food, and paying for food. Make sure to be friendly and gently correct users if they make a mistake. Open the conversation by welcoming the user and asking what they would like to order. 
            
            Based on their level:
            - For beginners: Use simple phrases, speak slowly, and provide gentle corrections. Use vocabulary related to everyday situations.
            - For intermediate learners: Introduce more complex grammatical structures and vocabulary. Correct errors thoughtfully without overwhelming.
            - For advanced learners: Have natural, flowing conversations. Use idioms, cultural references, and challenge them appropriately.
            
            Your teaching style:
            - Be conversational and responsive
            - Ask follow-up questions to keep the conversation flowing
            - When correcting, highlight the error subtly and demonstrate the correct form
            - Occasionally share brief cultural insights related to language usage
            - Keep responses concise (under 75 words) since this is a spoken interface
            
            IMPORTANT: Always respond in \(targetLanguageName). Only use English if the user seems genuinely confused. No emojis: Do not use any emojis or decorative characters.
            """
        }
        
        
        openAI.chatsStream(query: query) { [weak self] partialResult in
            guard let self = self else { return }
            
            switch partialResult {
            case .success(let result):
                // Check if this is a delta update with content
                if let deltaContent = result.choices.first?.delta.content {
                    DispatchQueue.main.async {
                        // Append new content to the current streamed text
                        self.currentStreamedText += deltaContent
                        
                        // Update the placeholder message
                        if let index = self.messages.firstIndex(where: { $0.id == placeholderID }) {
                            self.messages[index].content = self.currentStreamedText
                        }
                    }
                }
                
                //check if this is the final message (stream completion)
                if result.choices.first?.finishReason != nil {
                    DispatchQueue.main.async {
                        print("Stream chunk indicates completion")
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Streaming chunk error: \(error)")
                }
            }
        } completion: { [weak self] error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isStreaming = false
                
                if let error = error {
                    print("Streaming completed with error: \(error)")
                    
                    // Handle error by showing error message if needed
                    if let index = self.messages.firstIndex(where: { $0.id == placeholderID }) {
                        if self.currentStreamedText.isEmpty {
                            self.messages.remove(at: index)
                            self.messages.append(Message(content: "Sorry, I couldn't generate a response. Please try again.", isUser: false))
                        } else {
                            // Keep partial response if we have some content
                            self.messages[index].content = self.currentStreamedText + " (Message was cut off)"
                        }
                    }
                } else {
                    print("Streaming completed successfully")
                    // Speak the final message when complete
                    if !self.currentStreamedText.isEmpty {
                        //self.speakMessage(self.currentStreamedText)
                        self.synthesizeWithGoogleTTS(self.currentStreamedText) { audioData in
                            guard let audioData = audioData else {
                                print("No audio data returned from Google TTS")
                                return
                            }
                            DispatchQueue.main.async {
                                self.playAudioData(audioData)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    //using google cloud api for text to speech
    func synthesizeWithGoogleTTS(_ text: String, language: String = "", completion: @escaping (Data?) -> Void) {

        let apiKey = "YOUR-GOOGLE-TEXT-TO-SPEECH-API-KEY"
            //let url = URL(string: "https://texttospeech.googleapis.com/v1/text:synthesize")!
        let url = URL(string: "https://texttospeech.googleapis.com/v1/text:synthesize?key=\(apiKey)")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            //let url = URL(string: "https://texttospeech.googleapis.com/v1/text:synthesize?key=\(apiKey)")

            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: Any] = [
                "input": ["text": self.currentStreamedText],
                "voice": [
                    "languageCode": self.targetLanguageCode,
                    "name": defaultVoice(for: self.targetLanguageCode)
                    //"ssmlGender": "FEMALE"
                ],
                "audioConfig": [
                    "audioEncoding": "MP3",
                    "pitch": 0,
                    "speakingRate": 1
                ]
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        //debugging
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("TTS request failed: \(error.localizedDescription)")
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }

            if let responseData = data,
               let responseText = String(data: responseData, encoding: .utf8) {
                print("Google TTS Raw Response: \(responseText)")
            } else {
                print("No response data received.")
            }

            // Now try to parse it
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let audioContent = json["audioContent"] as? String,
                  let audioData = Data(base64Encoded: audioContent) else {
                print("Could not decode audio from Google TTS response.")
                return completion(nil)
            }

            completion(audioData)
        }.resume()

        }
    
    func defaultVoice(for languageCode: String) -> String {
        switch languageCode {
            case "es-ES": return "es-ES-Chirp3-HD-Kore"
            case "fr-FR": return "fr-FR-Chirp3-HD-Kore"
            case "ja-JP": return "ja-JP-Chirp3-HD-Kore"
            case "en-US": return "en-US-Chirp3-HD-Kore"
            case "ta-IN": return "ta-IN-Chirp3-HD-Kore"
            case "cmn-CN": return "cmn-CN-Chirp3-HD-Kore"
            case "ko-KR": return "ko-KR-Chirp3-HD-Kore"
            case "vi-VN": return "vi-VN-Chirp3-HD-Kore"
            case "ar-XA": return "ar-XA-Chirp3-HD-Kore"
            case "gu-IN": return "gu-IN-Chirp3-HD-Kore"
            case "hi-IN": return "hi-IN-Chirp3-HD-Kore"
            case "mr-IN": return "mr-IN-Chirp3-HD-Kore"
            case "pt-BR": return "pt-BR-Chirp3-HD-Kore"
            case "te-IN": return "te-IN-Chirp3-HD-Kore"
            default:
            // For debugging
            print("Finding voice for language code: \(languageCode)")
            
            // Make sure we're constructing the voice name with proper case
            let parts = languageCode.split(separator: "-")
            let langPart = parts.first?.lowercased() ?? ""
            let regionPart = parts.last?.uppercased() ?? ""
            let formattedCode = langPart + "-" + regionPart
            
            let fallback = "\(formattedCode)-Chirp3-HD-Kore"
            print("Fallback voice: \(fallback)")
            return fallback
        }
    }
    
    func resetChat() {
        messages.removeAll()
        currentStreamedText = ""
        isStreaming = false
        self.audioPlayer?.stop()
        print("Chat reset")
    }

    
    func playAudioData(_ data: Data) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            self.audioPlayer = try AVAudioPlayer(data: data)
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.play()
        } catch {
            print("Audio playback failed: \(error)")
        }
    }

}



struct Message: Identifiable, Equatable {
    var id: UUID = .init()
    var content: String
    var isUser: Bool
    let timestamp = Date()
    
    //Implement Equatable
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
}

//whisper speech to text
class SpeechManager: NSObject, ObservableObject {
    @Published var isListening = false
    @Published var transcribedText = ""
    @Published var errorMessage: String?

    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("recording.m4a")
    }

    var onSpeechDetected: ((String) -> Void)?

    func startListening() {
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .default)
            try session.setActive(true)
            audioRecorder = try AVAudioRecorder(url: recordingURL, settings: settings)
            audioRecorder?.record()
            isListening = true
            print("Recording started")
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
        }
    }

    func stopListening() {
        audioRecorder?.stop()
        isListening = false
        print("Recording stopped, sending to Whisper")
        transcribeWithWhisper()
    }

    private func transcribeWithWhisper() {
        guard FileManager.default.fileExists(atPath: recordingURL.path) else {
            errorMessage = "Recording file not found"
            return
        }

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/audio/transcriptions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer YOUR-OPENAI-API-KEY", forHTTPHeaderField: "Authorization")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        // audio file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"recording.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append((try? Data(contentsOf: recordingURL)) ?? Data())
        body.append("\r\n".data(using: .utf8)!)

        // model
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let text = result["text"] as? String else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to transcribe audio"
                    print("Transcription failed")
                }
                return
            }

            DispatchQueue.main.async {
                self.transcribedText = text
                self.onSpeechDetected?(text)
                print("Transcription: \(text)")
            }
        }.resume()
    }
}
