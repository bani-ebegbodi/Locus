//
//  LanguagePicker.swift
//  Locus
//
//  Created by Banibe Ebegbodi on 2/18/25.
//

import SwiftUI

struct LanguagePicker: View {
    let title: String
    @Binding var selectedLanguage: String
    @State private var searchText: String = ""
    @State private var isShowingPicker = false
    let languages: [(code: String, name: String)]
    
    var filteredLanguages: [(code: String, name: String)] {
        if searchText.isEmpty {
            return languages
        }
        return languages.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            
            Button(action: {
                isShowingPicker = true
            }) {
                Text(languages.first(where: { $0.code == selectedLanguage })?.name ?? "Select")
                    .foregroundColor(.white)
            }
        }
        .sheet(isPresented: $isShowingPicker) {
            NavigationView {
                VStack {
                    SearchBar(text: $searchText)
                        .padding()
                    
                    List(filteredLanguages, id: \.code) { language in
                        Button(action: {
                            selectedLanguage = language.code
                            isShowingPicker = false
                        }) {
                            HStack {
                                Text(language.name)
                                Spacer()
                                if selectedLanguage == language.code {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                .navigationTitle("Select Language")
                .navigationBarItems(trailing: Button("Done") {
                    isShowingPicker = false
                })
            }
        }
    }
}
