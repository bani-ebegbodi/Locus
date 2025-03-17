//
//  LanguageDifficulty.swift
//  Locus
//
//  Created by Banibe Ebegbodi on 3/16/25.
//


import SwiftUI

struct LanguageDifficulty: View {
    @State private var selectedLevel: String = "Beginner"
    @State private var showInfo: Bool = false
    @State private var infoText: String = ""
    
    let levels: [(name: String, description: String)] = [
        ("Beginner", "You know basic words and phrases but have limited conversation skills."),
        ("Intermediate", "You can hold conversations and understand common phrases."),
        ("Advanced", "You have strong fluency and understand complex language structures.")
    ]
    
    var body: some View {
        VStack {
            Text("Select Your Language Level")
                .font(.title)
                .padding()
            
            Menu {
                ForEach(levels, id: \..name) { level in
                    Button(action: {
                        selectedLevel = level.name
                    }) {
                        HStack {
                            Text(level.name)
                            Spacer()
                            Button(action: {
                                infoText = level.description
                                showInfo.toggle()
                            }) {
                                Image(systemName: "questionmark.circle")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
            } label: {
                Text(selectedLevel)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
            .padding()
            
            if showInfo {
                Text(infoText)
                    .font(.caption)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
        }
    }
}

#Preview {
    LanguageDifficulty()
}
