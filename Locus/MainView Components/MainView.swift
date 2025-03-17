//
//  MainView.swift
//  Locus
//
//  Created by Banibe Ebegbodi on 2/18/25.
//

import SwiftUI
import RealityKit

struct MainView: View {
    @State private var knownLanguage: String = "en"
    @State private var targetLanguage: String = "es"
    @State private var languageLevel: String = "beginner"
    
    let languages: [(code: String, name: String)] = {
        //making the lang names english instead of its native lang
        let locale = Locale(identifier: "en")
        var seenLangs = Set<String>()
        return Locale.availableIdentifiers.compactMap { identifier in
            let langLocale = Locale(identifier: identifier)
            if let languageCode = langLocale.language.languageCode?.identifier,
               let languageName = locale.localizedString(forLanguageCode: languageCode)?.capitalized,
               !seenLangs.contains(languageCode) {
                seenLangs.insert(languageCode)
                return (languageCode, languageName)
            }
            return nil
        }.sorted { $0.name < $1.name }
    }()
    
    var body: some View {
        VStack {
            Text("Locus")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .padding(.bottom, 100)
                
            LanguagePicker(
                title: "Your Language:",
                selectedLanguage: $knownLanguage,
                languages: languages
            )
            .padding(.vertical, 8)
                
            LanguagePicker(
                title: "Target Language:",
                selectedLanguage: $targetLanguage,
                languages: languages
            )
            .padding(.vertical, 8)
                
            LanguageLevelPicker(
                selectedLevel: $languageLevel,
                title: "Language Level:"
            )
            .padding(.vertical, 8)
            
        }
        .padding()
    }
}

#Preview {
    MainView()
}
