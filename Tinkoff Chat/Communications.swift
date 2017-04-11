//
//  Communications.swift
//  Tinkoff Chat
//
//  Created by Mikhail Gilmutdinov on 11.04.17.
//  Copyright © 2017 Mikhail Gilmutdinov. All rights reserved.
//

import MultipeerConnectivity

protocol Communicator {
    func sendMessage(string: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?) -> ())?)
    weak var delegate: CommunicatorDelegate? {get set}
    var online: Bool {get set}
}

protocol CommunicatorDelegate: class {
    // discovering
    func didFindUser(userID: String, userName: String?)
    func didLoseUser(userID: String)
    
    // errors
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)
    
    // messages
    func didReveiveMessage(text: String, fromUser: String, toUser: String)
}

func generateMessageId() -> String {
    let string = "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)+\(arc4random_uniform(UINT32_MAX))".data(using: .utf8)?.base64EncodedString()
    return string!
}

class MultipeerCommunicator: NSObject, Communicator {
    weak var delegate: CommunicatorDelegate?
    var online: Bool = true
    
    var serviceType: String
    var userName: String
    var myPeerID: MCPeerID = MCPeerID(displayName: UIDevice.current.identifierForVendor!.uuidString)
    var advertiser: MCNearbyServiceAdvertiser
    var browser: MCNearbyServiceBrowser
    
    var sessions: [String: MCSession?] = [:]
    
    init(withUserName userName: String, serviceType: String) {
        self.userName = userName
        self.serviceType = serviceType
        self.advertiser = MCNearbyServiceAdvertiser(peer: self.myPeerID, discoveryInfo: ["userName": userName], serviceType: self.serviceType)
        self.browser = MCNearbyServiceBrowser(peer: self.myPeerID, serviceType: self.serviceType)
        super.init()
        self.advertiser.delegate = self
        self.browser.delegate = self
        self.advertiser.startAdvertisingPeer()
        self.browser.startBrowsingForPeers()
    }
    func sendMessage(string: String, to userID: String, completionHandler: ((Bool, Error?) -> ())?) {
        let dict: [String: String] = ["eventType": "TextMessage", "messageId": generateMessageId(), "text": string]
        var data = Data()
        do {
            data = try JSONSerialization.data(withJSONObject: dict, options: [])
        } catch{
            print(error)
        }
        if let session = self.sessions[userID]! {
            do {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                completionHandler?(true, nil)
            } catch {
                completionHandler?(false, error)
            }
            
        }
        
    }
    
}

extension MultipeerCommunicator: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        self.delegate?.failedToStartAdvertising(error: error)
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        let userID = peerID.displayName
        if self.sessions[userID] == nil {
            let session = MCSession(peer: self.myPeerID)
            session.delegate = self
            invitationHandler(true, session)
            self.sessions[userID] = session
        } else {
            invitationHandler(true, self.sessions[userID]!)
        }
    }
}

extension MultipeerCommunicator: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        self.delegate?.failedToStartBrowsingForUsers(error: error)
    }
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        let userID = peerID.displayName
        let session = MCSession(peer: self.myPeerID)
        session.delegate = self
        self.browser.invitePeer(peerID, to: session, withContext: nil, timeout: 0)
        self.sessions[userID] = session
        self.delegate?.didFindUser(userID: userID, userName: info?["userName"])
    }
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        self.delegate?.didLoseUser(userID: peerID.displayName)
    }
}

extension MultipeerCommunicator: MCSessionDelegate {
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let data = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:String]
        self.delegate?.didReveiveMessage(text: data["text"] ?? "", fromUser: peerID.displayName, toUser: "")
    }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
    }
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    }
    
}

enum MessageDirection {
    case incoming
    case outgoing
}

struct Message {
    var otherUser: String?
    var text: String?
    var direction: MessageDirection?
    var date: Date?
}

class CommunicationManager: CommunicatorDelegate {
    var communicator: MultipeerCommunicator
    weak var conversationsList: ConversationsListViewController?
    weak var conversation: ConversationViewController?
    var users: [String: String] = [:] {
        didSet {
            self.reloadTables()
        }
    }
    var messages: [String: [Message]] = [:] {
        didSet {
            self.reloadTables()
        }
    }
    init(withConversationsListViewController controller: ConversationsListViewController, userName: String, serviceType: String) {
        self.communicator = MultipeerCommunicator.init(withUserName: userName, serviceType: serviceType)
        self.communicator.delegate = self
        self.conversationsList = controller
    }
    func reloadTables() {
        // почему это не работает?
        self.conversationsList?.tableView.reloadData()
        self.conversation?.tableView.reloadData()
    }
    // discovering
    func didFindUser(userID: String, userName: String?) {
        self.users[userID] = userName
        if self.messages[userID] == nil {
            self.messages[userID] = []
        }
    }
    func didLoseUser(userID: String) {
        self.users.removeValue(forKey: userID)
    }
    
    // errors
    func failedToStartBrowsingForUsers(error: Error) {
        // TODO: handle error
    }
    func failedToStartAdvertising(error: Error) {
        // TODO: handle error
    }
    
    // messages
    func didReveiveMessage(text: String, fromUser: String, toUser: String) {
        self.messages[fromUser]?.append(Message(otherUser: fromUser, text: text, direction: .incoming, date: Date()))
    }
    func sendMessage(text: String, fromUser: String, toUser: String) {
        self.communicator.sendMessage(string: text, to: toUser) {
            [weak self] (success, error) in
            if success {
                self?.messages[toUser]?.append(Message(otherUser: toUser, text: text, direction: .outgoing, date: Date()))
                self?.conversation?.textField.text = ""
                self?.conversation?.sendButton.isEnabled = false
            }
            // TODO: handle error
        }
    }
}
