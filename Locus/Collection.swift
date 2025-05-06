//
//  Collection.swift
//  beta
//
//  Created by Banibe Ebegbodi on 2/13/25.
//

import SwiftUI

struct Collection: View {
    @Environment(AppModel.self) var appModel
    @State private var navigateToChat = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color("Sky")
                    .cornerRadius(30)
                VStack {
                    Text("Worlds")
                        .font(.custom("Charter Bold", size: 100))
                        .foregroundColor(.sunshine)
                        .padding(.vertical, 80)
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            Worlds(title: "Cafe", image: "cafe_img", onTap: {
                                navigateToChat = true})
                            Worlds(title: "Supermarket", image: "supermarket_img", onTap: {})
                                .opacity(0.7)
                                .overlay(Image(systemName: "lock").font(.system(size: 80)))
                            Worlds(title: "Train Station", image: "station_img", onTap: {})
                                .opacity(0.7)
                                .overlay(Image(systemName: "lock").font(.system(size: 80)))
                            Worlds(title: "Retail Store", image: "retail_img", onTap: {})
                                .opacity(0.7)
                                .overlay(Image(systemName: "lock").font(.system(size: 80)))
                        }
                        .padding(.horizontal)
                    }
                    NavigationLink(
                        destination: ChatView(navigateToChat: $navigateToChat),
                        isActive: $navigateToChat
                    ) {
                        EmptyView()
                    }
                //.navigationBarBackButtonHidden(true)
                .buttonStyle(.plain)
                }
            }
        }
    }
}
   

//cards
struct Worlds: View {
    let title: String
    let image: String
    //let destination: AnyView
    let onTap: () -> Void
    
    //vr part
    @Environment(AppModel.self) private var appModel
    //@Environment(AppModel.self) var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    
    var body: some View {
        Button {
            Task {
                if title == "Cafe" {
                    appModel.immersiveSpaceState = .inTransition
                    let result = await openImmersiveSpace(id: appModel.immersiveSpaceID)
                    if case .opened = result {
                        onTap()
                    } else {
                        appModel.immersiveSpaceState = .closed
                    }
                }
            }
        } label: {
            VStack {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 150)
                    .cornerRadius(10)
                Text(title)
                    .font(.custom("DIN Alternate", size: 30))
                    .foregroundColor(.sky)
            }
            .padding()
            .background(Color("Sea"))
            .cornerRadius(10)
            .shadow(radius: 3)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    Collection()
        .environment(AppModel())
}
