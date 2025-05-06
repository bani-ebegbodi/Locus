//
//  ChatLogView.swift
//  Locus
//
//  Created by Banibe Ebegbodi on 4/9/25.
//


import SwiftUI

struct ChatLogView: View {
    @StateObject private var chatLogStore = ChatLogStore.shared
    @State private var selectedChatLog: ChatLog?
    @State private var showingDeleteAlert = false
    @State private var logToDelete: UUID?
    @EnvironmentObject var settings: AppSettings
    @State private var showChatView = false
    @State private var showChatDetail = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Sky")
                    .cornerRadius(30)
                VStack {
                    Text("Chat Logs")
                        .font(.custom("Charter Bold", size: 100))
                        .foregroundColor(.sunshine)
                        .padding(.vertical, 30)
                    if chatLogStore.chatLogs.isEmpty {
                        ContentUnavailableView(
                            "No Saved Chats",
                            systemImage: "bubble.left.and.text.bubble.right",
                            description: Text("Your saved conversations will appear here")
                        )
                    } else {
                        List {
                            ForEach(chatLogStore.chatLogs.sorted(by: { $0.timestamp > $1.timestamp })) { log in
                                NavigationLink(destination: ChatDetailView(chatLog: log)) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(log.title)
                                            .font(.headline)
                                        
                                        HStack {
                                            Text(languageName(for: log.languageCode))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            
                                            Spacer()
                                            
                                            //format date
                                            Text(formattedDate(log.timestamp))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        logToDelete = log.id
                                        showingDeleteAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                //.navigationTitle("Saved Chats")
                .sheet(isPresented: $showChatView) {
                    ChatView(navigateToChat: .constant(false))
                        .environmentObject(settings)
                }
                .sheet(isPresented: $showChatDetail) {
                    if let log = selectedChatLog {
                        ChatDetailView(chatLog: log)
                            .environmentObject(settings)
                    }
                }
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text("Delete Chat"),
                        message: Text("Are you sure you want to delete this chat log? This cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            if let id = logToDelete {
                                chatLogStore.deleteChatLog(withID: id)
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
    }
    
    private func languageName(for code: String) -> String {
        let locale = Locale(identifier: "en")
        return locale.localizedString(forLanguageCode: code) ?? code
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ChatDetailView: View {
    let chatLog: ChatLog
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack {
            /*
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Label("Back", systemImage: "chevron.backward")
                }
                .buttonStyle(.plain)

                Spacer()
               
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            .padding()
             */
            
            ScrollView {
                LazyVStack {
                    ForEach(chatLog.messages) { message in
                        MessageView(message: message, isStreaming: false)
                            .padding(5)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(chatLog.title)
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Chat"),
                message: Text("Are you sure you want to delete this conversation?"),
                primaryButton: .destructive(Text("Delete")) {
                    ChatLogStore.shared.deleteChatLog(withID: chatLog.id)
                    dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }
}

#Preview {
    ChatLogView()
        .environmentObject(AppSettings())
}
