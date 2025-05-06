//
//  ChatView 2.swift
//  Locus
//
//  Created by Banibe Ebegbodi on 4/5/25.
//

import SwiftUI

struct ChatView: View {
    
    @EnvironmentObject var settings: AppSettings
    @StateObject private var chatController = ChatController(settings: AppSettings())

    @StateObject var speechManager = SpeechManager()
    @State var string: String = ""
    
    @State private var showExitPrompt = false
    @State private var showRenamePrompt = false
    @State private var chatTitle = ""
    
    @State private var inputText: String = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @Binding var navigateToChat: Bool

    //vr part
    @Environment(AppModel.self) private var appModel
    //@Environment(AppModel.self) var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
        
        init(navigateToChat: Binding<Bool>) {
            self._navigateToChat = navigateToChat
            // Use _chatController to initialize the StateObject
            _chatController = StateObject(wrappedValue: ChatController(settings: AppSettings()))
        }

    
    var body: some View {
        
        VStack {
            HStack {
                Button(action: {
                    //only show exit prompt if there are messages to save
                    if !chatController.messages.isEmpty {
                        showExitPrompt = true
                    } else {
                        //exit if no message
                        exitChat()
                    }
                }) {
                    Label("Exit", systemImage: "chevron.backward")
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(Color.gray)
                        .cornerRadius(15)
                }
                .buttonStyle(.plain)

                
                Spacer()
                Button(action: {
                    chatController.resetChat()
                }) {
                    Label("Reset Chat", systemImage: "trash")
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(Color.red)
                        .cornerRadius(15)
                }
                .padding(.bottom)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack {
                        ForEach(chatController.messages) { message in
                            MessageView(message: message, isStreaming: message.isUser ? false : chatController.isStreaming)
                                .padding(5)
                                .id(message.id)
                        }
                    }
                    .onChange(of: chatController.messages.count) { _ in
                        if let lastMessage = chatController.messages.last {
                            withAnimation {
                                scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    //streaming updates
                    .onChange(of: chatController.currentStreamedText) { _ in
                        if let lastMessage = chatController.messages.last {
                            withAnimation {
                                scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            // Show transcribed text while listening
            if speechManager.isListening {
                Text("Listening...")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
            }
            
            Divider()
            
            HStack {
                TextField("Message...", text: self.$string, axis: .vertical)
                    .padding(5)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .disabled(chatController.isStreaming) // Disable input while streaming
                
                Button {
                    if !string.isEmpty {
                        self.chatController.sendNewMessage(content: string)
                        string = ""
                    }
                } label: {
                    Image(systemName: "paperplane")
                }
                .disabled(chatController.isStreaming) // Disable send button while streaming
            }
            .padding()
            
            Button(action: {
                if speechManager.isListening {
                    speechManager.stopListening()
                } else {
                    speechManager.startListening()
                }
            }) {
                HStack {
                    Image(systemName: speechManager.isListening ? "mic.fill" : "mic")
                        .font(.system(size: 24))
                    Text(speechManager.isListening ? "Done" : "Start Speaking")
                }
                .padding()
                .foregroundColor(.white)
                .background(speechManager.isListening ? Color.red : Color.blue)
                .cornerRadius(15)
            }
            .padding(.bottom)
            .disabled(chatController.isStreaming) //disable mic button while streaming
            .buttonStyle(.plain)
        }
        .padding(10)
        .onAppear {
            // Set up the speech detection handler
            speechManager.onSpeechDetected = { text in
                if !text.isEmpty {
                    chatController.sendNewMessage(content: text)
                }
            }
        }
        .navigationBarBackButtonHidden(true) 
        // Show errors if any
        .alert(item: Binding(
            get: { speechManager.errorMessage.map { ErrorWrapper(error: $0) } },
            set: { _ in speechManager.errorMessage = nil }
        )) { errorWrapper in
            Alert(
                title: Text("Speech Recognition Error"),
                message: Text(errorWrapper.error),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            chatController.targetLanguageCode = chatController.preferredLocale(for: settings.targetLanguage)
        }
        .alert(isPresented: $showExitPrompt) {
            Alert(
                title: Text("Save chat before exiting?"),
                message: Text("Would you like to save this conversation before clearing it?"),
                primaryButton: .default(Text("Save")) {
                    // Set up default title placeholder
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM d, h:mm a"
                    let timestamp = formatter.string(from: Date())
                    let language = Locale(identifier: "en").localizedString(forLanguageCode: settings.targetLanguage) ?? "Chat"
                    chatTitle = "\(language.capitalized) – \(timestamp)"
                    showRenamePrompt = true
                },
                secondaryButton: .destructive(Text("Clear & Exit")) {
                    chatController.resetChat()
                }
            )
        }
        //exit confirmation
            .alert(isPresented: $showExitPrompt) {
                Alert(
                    title: Text("Save chat before exiting?"),
                    message: Text("Would you like to save this conversation before clearing it?"),
                    primaryButton: .default(Text("Save")) {
                        //default title placeholder
                        let formatter = DateFormatter()
                        formatter.dateFormat = "MMM d, h:mm a"
                        let timestamp = formatter.string(from: Date())
                        let languageName = Locale(identifier: "en").localizedString(forLanguageCode: settings.targetLanguage) ?? "Chat"
                        chatTitle = "\(languageName.capitalized) – \(timestamp)"
                        showRenamePrompt = true
                    },
                    secondaryButton: .destructive(Text("Clear & Exit")) {
                        chatController.resetChat()
                        exitChat()
                    }
                )
            }
            //rename prompt sheet
            .sheet(isPresented: $showRenamePrompt) {
                VStack(spacing: 20) {
                    Text("Rename Chat Log")
                        .font(.headline)

                    TextField("Enter a title...", text: $chatTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button("Save") {
                        saveChat(title: chatTitle)
                        showRenamePrompt = false
                        chatController.resetChat()
                        exitChat()
                        //appModel.immersiveSpaceState = .closed
                    }
                    .padding()
                    //.background(Color.blue)
                    .foregroundColor(.white)
                    //.cornerRadius(10)
                    .buttonStyle(.borderedProminent)

                    Button("Cancel") {
                        showRenamePrompt = false
                    }
                    .foregroundColor(.red)
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        
        //exit the chat view
        private func exitChat() {
            //dismiss()
            //appModel.immersiveSpaceState = .closed
            //navigateToChat = false
            //appModel.immersiveSpaceState = .closed
            Task {
                await dismissImmersiveSpaceIfNeeded()
                navigateToChat = false
                appModel.immersiveSpaceState = .closed
                dismiss()
            }
            //dismiss()
            

        }
    //make sure everything's closed
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    private func dismissImmersiveSpaceIfNeeded() async {
        if appModel.immersiveSpaceState == .open || appModel.immersiveSpaceState == .inTransition {
            await dismissImmersiveSpace()
        }
    }

        
        // Save the chat log
        func saveChat(title: String) {
            // Create a ChatLog object to save
            let newChatLog = ChatLog(
                id: UUID(),
                title: title,
                messages: chatController.messages,
                languageCode: settings.targetLanguage,
                timestamp: Date()
            )
            
            // Add to the stored chat logs
            ChatLogStore.shared.addChatLog(newChatLog)
            
            print("Chat saved as: \(title)")

    }
    
}


// Helper struct to make string error alerts possible
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let error: String
}

struct MessageView: View {
    var message: Message
    var isStreaming: Bool
    
    var body: some View {
        Group {
            if message.isUser {
                HStack {
                    Spacer()
                    Text(message.content)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .clipShape(Capsule())
                }
            } else {
                HStack {
                    // For bot messages
                    VStack(alignment: .leading) {
                        if isStreaming && message.content.isEmpty {
                            //empty messages show thinking
                            Text("Thinking...")
                                .italic()
                                .padding(.vertical, 10)
                                .background(Color.black)
                                .foregroundColor(Color.white)
                                .clipShape(Capsule())
                        } else {
                            //for messages with content
                            HStack(spacing: 0) {
                                Text(message.content)
                            }
                            .padding()
                            .background(Color.black)
                            .foregroundColor(Color.white)
                            .clipShape(Capsule())
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    //ChatView()
        //.environmentObject(AppSettings())
        //.environment(AppModel())
    ChatView(navigateToChat: Binding<Bool>.constant(false))
        .environmentObject(AppSettings())
        .environment(AppModel())
}

