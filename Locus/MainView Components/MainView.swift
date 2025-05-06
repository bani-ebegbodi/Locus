//
//  MainView.swift
//  Locus
//
//  Created by Banibe Ebegbodi on 2/18/25.
//

import SwiftUI
import RealityKit

struct MainView: View {
    //@State private var knownLanguage: String = "en"
    //@State private var targetLanguage: String = "es"
    //@State private var languageLevel: String = "beginner"
    @EnvironmentObject var settings: AppSettings
    
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
        ZStack {
            Color("Sky")
                .cornerRadius(30)
            VStack {
                Image("Locus_Full_Logo-2")
                    .resizable()
                //.aspectRatio(contentMode: .fit)
                    .frame(width: 500, height: 200)
                    //.padding(.bottom, 50)
                Rectangle()
                    .padding(.bottom, 50)
                    .frame(width: 500, height: 55)
                    .cornerRadius(10)
                    .foregroundColor(.sea)
                LanguagePicker(
                    title: "Your Language:",
                    selectedLanguage: $settings.knownLanguage,
                    languages: languages
                )
                .padding(.vertical, 8)
                
                LanguagePicker(
                    title: "Target Language:",
                    selectedLanguage: $settings.targetLanguage,
                    languages: languages
                )
                .padding(.vertical, 8)
                
                LanguageLevelPicker(
                    selectedLevel: $settings.languageLevel,
                    title: "Proficiency:"
                )
                .padding(.vertical, 8)
                
            }
            .padding()
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AppSettings())
}
