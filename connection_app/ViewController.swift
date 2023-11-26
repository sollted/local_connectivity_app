//
//  ViewController.swift
//  connection_app
//
//  Created by Adam Barta on 26.11.2023.
//

import UIKit

class ViewController: UIViewController {

    var chatManager: ChatManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize ChatManager
        chatManager = ChatManager()

        // Start advertising and browsing
        chatManager.startAdvertising()
        chatManager.startBrowsing()
    }

    // Add code for sending messages and handling the chat UI as needed
}


