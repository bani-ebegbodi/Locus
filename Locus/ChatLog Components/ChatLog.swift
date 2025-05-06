//
//  ChatLog.swift
//  Locus
//
//  Created by Banibe Ebegbodi on 4/9/25.
//

import Foundation

struct ChatLog: Identifiable, Codable {
    var id: UUID
    var title: String
    var messages: [Message]
    var languageCode: String
    var timestamp: Date
    
}

extension Message: Codable {
    enum CodingKeys: String, CodingKey {
        case id, content, isUser, timestamp
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        isUser = try container.decode(Bool.self, forKey: .isUser)
        _ = try container.decode(Date.self, forKey: .timestamp)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        try container.encode(isUser, forKey: .isUser)
        try container.encode(timestamp, forKey: .timestamp)
    }
}

class ChatLogStore: ObservableObject {
    static let shared = ChatLogStore()
    
    @Published var chatLogs: [ChatLog] = []
    
    private let savePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("chatLogs.json")
    
    private init() {
        loadChatLogs()
    }
    
    func addChatLog(_ chatLog: ChatLog) {
        chatLogs.append(chatLog)
        saveChatLogs()
    }
    
    func deleteChatLog(withID id: UUID) {
        chatLogs.removeAll { $0.id == id }
        saveChatLogs()
    }
    
    private func saveChatLogs() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(chatLogs)
            try data.write(to: savePath)
        } catch {
            print("Error saving chat logs: \(error)")
        }
    }
    
    private func loadChatLogs() {
        guard FileManager.default.fileExists(atPath: savePath.path) else { return }
        
        do {
            let data = try Data(contentsOf: savePath)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            chatLogs = try decoder.decode([ChatLog].self, from: data)
        } catch {
            print("Error loading chat logs: \(error)")
        }
    }
}
