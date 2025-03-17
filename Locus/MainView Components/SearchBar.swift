//
//  SearchBar.swift
//  Locus
//
//  Created by Banibe Ebegbodi on 2/18/25.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search languages", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}
