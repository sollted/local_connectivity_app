//
//  ViewController.swift
//  connection_app
//
//  Created by Adam Barta on 26.11.2023.
//

import SwiftUI

@main
struct PeerChatApp: App {
    @ObservedObject private var chat = ChatManger()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(chat)
        }
    }
}
