//
//  AppSettings.swift
//  Locus
//
//  Created by Banibe Ebegbodi on 4/3/25.
//

import Foundation

class AppSettings: ObservableObject {
    @Published var knownLanguage: String = "en"
    @Published var targetLanguage: String = "en"
    @Published var languageLevel: String = "beginner"
}

