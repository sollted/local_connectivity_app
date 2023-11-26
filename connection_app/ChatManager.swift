//
//  ChatManager.swift
//  connection_app
//
//  Created by Adam Barta on 26.11.2023.
//

import Foundation
import MultipeerConnectivity

class ChatManager: NSObject {

    private let serviceType = "local-chat"
    private var myPeerID: MCPeerID!
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!

    override init() {
        super.init()

        myPeerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)

        // Set delegates
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
    }

    func startAdvertising() {
        advertiser.startAdvertisingPeer()
    }

    func stopAdvertising() {
        advertiser.stopAdvertisingPeer()
    }

    func startBrowsing() {
        browser.startBrowsingForPeers()
    }

    func stopBrowsing() {
        browser.stopBrowsingForPeers()
    }

    func send(message: String) {
        guard !message.isEmpty else {
                    return // Don't send empty messages
                }

                let messageData = message.data(using: .utf8)!

                do {
                    try session.send(messageData, toPeers: session.connectedPeers, with: .reliable)
                } catch {
                    print("Error sending message: \(error.localizedDescription)")
                    // Handle the error, update UI, etc.
                }
    }
}

extension ChatManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        <#code#>
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        <#code#>
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        <#code#>
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        <#code#>
    }
    

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let receivedMessage = String(data: data, encoding: .utf8){
            print("Received message from \(peerID.displayName): \(receivedMessage)")
        }
        // Handle received data
    }

    // Implement other necessary MCSessionDelegate methods...
}

extension ChatManager: MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Handle incoming invitations
        //invitationHandler(true, session)
        invitationHandler(true, nil)
    }

    // Implement other necessary MCNearbyServiceAdvertiserDelegate methods...
}

extension ChatManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer: \(peerID.displayName)")
        <#code#>
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
        <#code#>
    }
    

    // Implement necessary MCNearbyServiceBrowserDelegate methods...
}
