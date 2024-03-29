//
//  ChatManager.swift
//  connection_app
//
//  Created by Adam Barta on 26.11.2023.
//

import Foundation
import MultipeerConnectivity

struct Message: Codable,Hashable {
    let text: String
    let from: Person
    let id: UUID
    
    init(text: String, from: Person) {
        self.text = text
        self.from = from
        self.id = UUID()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

struct Person: Codable,Equatable,Hashable {
    let name: String
    let id: UUID
    
    static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    init(_ peer: MCPeerID,id:UUID){
        self.name = peer.displayName
        
        self.id = id
    }
}

struct Chat: Equatable {
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        return lhs.id == rhs.id
    }

    var messages: [Message] = []
    var peer: MCPeerID
    var person:Person
    var id = UUID()

}

struct PeerInfo: Codable{
    enum PeerInfoType: Codable {
        case Person
    }
    var peerInfoType: PeerInfoType = .Person
}

struct ConnectMessage: Codable {
    enum MessageType: Codable {
        case Message
        case PeerInfo
    }
    
    var messageType: MessageType = .Message
    var peerInfo: Person? = nil
    var message: Message? = nil
    
}

class ChatManager: NSObject, ObservableObject {
    
    private let serviceType = "local-chat"
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private let session: MCSession
    private let encoder = PropertyListEncoder()
    private let decoder = PropertyListDecoder()
    private var advertiser: MCNearbyServiceAdvertiser!
    private var browser: MCNearbyServiceBrowser!
    
    
    @Published var connectedPeers: [MCPeerID] = []
    @Published var chats: Dictionary<Person,Chat> = [:]
    
    var myPerson:Person
    
    override init() {
        
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        myPerson = Person(self.session.myPeerID,id: UIDevice.current.identifierForVendor!)
        
        super.init()
        
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
        
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }
    
    
    
    func send(_ messageText: String,chat: Chat) {
        print("send: \(messageText) to \(chat.peer.displayName)")
        
        DispatchQueue.main.async {
            let newMessage = ConnectMessage(messageType: .Message,message: Message(text: messageText, from: self.myPerson))
            if !self.session.connectedPeers.isEmpty {
                do {
                    if let data = try? self.encoder.encode(newMessage) {
                        DispatchQueue.main.async {
                            self.chats[chat.person]?.messages.append(newMessage.message!)
                        }
                        try self.session.send(data, toPeers: [chat.peer], with: .reliable)
                    }
                } catch {
                    print("Error for sending: \(String(describing: error))")
                }
            }
        }
    }
    
    func reciveInfo(info: ConnectMessage,from:MCPeerID){
        print("Recived Info",info.messageType)
        if(info.messageType == .Message){
            newMessage(message: info.message!,from:from)
        }
        if(info.messageType == .PeerInfo){
            newPerson(person: info.peerInfo!,from:from)
        }
    }
    
    func newConnection(peer:MCPeerID){
        print("New Connection ",peer.displayName)
        
        let newMessage = ConnectMessage(messageType: .PeerInfo,peerInfo: self.myPerson)
        do {
            if let data = try? encoder.encode(newMessage) {
                try session.send(data, toPeers: [peer], with: .reliable)
            }
        } catch {
            print("Error for newConnection: \(String(describing: error))")
        }
    }
    
    func newPerson(person:Person,from:MCPeerID){
        print("New Person ",person.name)
        self.chats[person] = Chat(peer:from,person: person)

    }
    
    func newMessage(message:Message,from:MCPeerID){
        print("New Message ",message.text)
        chats[message.from]!.messages.append(message)
    }
}

extension ChatManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("ServiceAdvertiser didNotStartAdvertisingPeer: \(String(describing: error))")
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("didReceiveInvitationFromPeer \(peerID)")
        DispatchQueue.main.async {
            invitationHandler(true, self.session)
        }
    }
}

extension ChatManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("ServiceBrowser didNotStartBrowsingForPeers: \(String(describing: error))")
        
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        print("ServiceBrowser found peer: \(peerID)")
        DispatchQueue.main.async {
            browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("ServiceBrowser lost peer: \(peerID)")
    }
}

extension ChatManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("peer \(peerID) didChangeState: \(state.rawValue)")
        DispatchQueue.main.async {
            if(state == .connected){
                self.newConnection(peer:peerID)
            }
            self.connectedPeers = session.connectedPeers
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("didReceive bytes \(data.count) bytes")
        if let message = try? decoder.decode(ConnectMessage.self, from: data) {
            DispatchQueue.main.async {
                self.reciveInfo(info: message,from: peerID)
            }
        }
    }

    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("Receiving streams is not supported")
    }

    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Receiving resources is not supported")
    }

    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("Receiving resources is not supported")
    }
}
