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
                .tabItem { Label("Worlds", systemImage: "globe.americas")
                }
            /*
            ChatView(navigateToChat: .constant(false))
                .tabItem { Label("Chat Logs", systemImage: "book.pages")
                }
             */
            ChatLogView()
                .tabItem { Label("Chat Logs", systemImage: "book.pages")
                }

        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environmentObject(AppSettings())
}
