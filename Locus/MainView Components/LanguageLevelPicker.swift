//
//  LanguageLevelPicker.swift
//  Locus
//
//  Created by Banibe Ebegbodi on 3/16/25.
//

import SwiftUI

struct LanguageLevelPicker: View {
    @Binding var selectedLevel: String
    let title: String
    
    // Define our language levels with descriptions
    let levels = [
        (id: "beginner", name: "Beginner", description: "Basic vocabulary and simple conversations. Suitable for those just starting to learn."),
        (id: "intermediate", name: "Intermediate", description: "Expanded vocabulary and ability to discuss various topics. Can understand most everyday conversations."),
        (id: "advanced", name: "Advanced", description: "Close to fluent communication with rich vocabulary. Can discuss complex topics and understand native speakers.")
    ]
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                //.padding(.bottom, 4)
            
            Menu {
                ForEach(levels, id: \.id) { level in
                    Button(action: {
                        selectedLevel = level.id
                    }) {
                        HStack {
                            Text(level.name)
                            Spacer()
                            if selectedLevel == level.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(getLevelName(for: selectedLevel))
                }
            }
        }
            
            // Show the description for the selected level
        VStack {
            if let description = getLevelDescription(for: selectedLevel) {
                Text(description)
                    .font(.caption)
                    //.foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
    }

    // Helper methods
        private func getLevelName(for id: String) -> String {
            levels.first(where: { $0.id == id })?.name ?? "Select Level"
        }
        
        private func getLevelDescription(for id: String) -> String? {
            levels.first(where: { $0.id == id })?.description
        }
    }
