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
    
    //list of levels
    let levels = [
        (id: "beginner", name: "Beginner", description: "Basic vocabulary and simple conversations. Suitable for those just starting to learn."),
        (id: "intermediate", name: "Intermediate", description: "Expanded vocabulary and can discuss various topics. Can understand common conversations."),
        (id: "advanced", name: "Advanced", description: "Close to fluent communication. Can discuss complex topics and understand native speakers.")
    ]
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("DIN Alternate", size: 30))
            
            Menu {
                ForEach(levels, id: \.id) { level in
                    Button(action: {
                        selectedLevel = level.id
                    }) {
                        HStack {
                            Text(level.name)
                                //.font(.custom("DIN Alternate", size: 30))
                            Spacer()
                            if selectedLevel == level.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(getLevelName(for: selectedLevel) + "*")
                        .font(.custom("DIN Alternate", size: 30))
                }
            }
        }
        
        //description for levels
        VStack {
            if let description = getLevelDescription(for: selectedLevel) {
                Text(description)
                    .font(.custom("DIN Alternate", size: 25))
                    //.foregroundColor(.secondary)
                    .padding(.top, 2)
                    .frame(width: 380)
                    .multilineTextAlignment(.center)
            }
        }
    }

        private func getLevelName(for id: String) -> String {
            levels.first(where: { $0.id == id })?.name ?? "Select Level"
        }
        
        private func getLevelDescription(for id: String) -> String? {
            levels.first(where: { $0.id == id })?.description
        }
    }
