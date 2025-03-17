//
//  ContentView.swift
//  Locus
//
//  Created by Banibe Ebegbodi on 3/13/25.
//

import SwiftUI
import RealityKit

struct ContentView: View {

    var body: some View {
        TabView {
            MainView()
                .tabItem{ Label("Home", systemImage: "house")
                }
            Collection()
                .tabItem { Label("Collection", systemImage: "book.pages")
                }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
