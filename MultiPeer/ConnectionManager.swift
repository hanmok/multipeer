//
//  ConnectionManager.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/14.
//

import Foundation
import MultipeerConnectivity
import AVFoundation


// TO be used for transferring Videos to a Server.
// use it? or Coding Key
// https://shark-sea.kr/entry/Swift-Codable-알아보기
//struct Videos: Identifiable, Equatable, Encodable {
//
//
//    var id = UUID()
//    let frontVideo:AVAsset // Video Type
//    let sideVideo: AVAsset
//
//    func encode(to encoder: Encoder) throws {
//        _ = try? JSONEncoder().encode(self)
//    }
//}

struct ChatMessage: Identifiable, Equatable, Codable {
    
    var id = UUID()
    let displayName: String
    let body: String
    var time = Date()
    
    var isUser: Bool {
        return displayName == UIDevice.current.name
    }
}






extension ConnectionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

protocol ConnectionManagerDelegate: NSObject {
    func presentVideo()
    func showDuration(_ startAt: Date, _ endAt: Date)
    func showStart(_ startAt: Date)
    func updateDuration(_ startAt: Date, current: Date )
    func updateState(state: String)
    func disconnected(state: String, timeDuration: Int)
}

class ConnectionManager: NSObject {
    
    static let shared = ConnectionManager()
    
    private static let service = "jobmanager-chat"
    
    weak var delegate: ConnectionManagerDelegate?
    
    static var messages: [ChatMessage] = [] // for testing
    static var peers: [MCPeerID] = []
    static var connectedToChat = false
    
    let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    
    private var advertiserAssistant: MCNearbyServiceAdvertiser?
    private var session: MCSession?
    private var isHosting = false
    
    override init() {
        print("connectionManager initiated.")
    }
    deinit {
        print("connectionManager deinitiated.")
    }
    var startTime = Date()
    var endTime = Date()
    
    func send(_ message: String) {
        let chatMessage = ChatMessage(displayName: myPeerId.displayName, body: message)
        ConnectionManager.messages.append(chatMessage)
        
        guard let session = session,
              let data = message.data(using: .utf8),
              !session.connectedPeers.isEmpty else { return }
        
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Error ! \(error.localizedDescription) ")
        }
    }
    
    func join() {
        ConnectionManager.peers.removeAll()
        ConnectionManager.messages.removeAll()
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
        
        guard let window = UIApplication.shared.windows.first,
              let session = session else { return }
        
        let mcBrowerViewController = MCBrowserViewController(serviceType: ConnectionManager.service, session: session)
        mcBrowerViewController.delegate = self
        window.rootViewController?.present(mcBrowerViewController, animated: true)
    }
    
    func host() {
        isHosting = true
        ConnectionManager.peers.removeAll()
        ConnectionManager.messages.removeAll()
        ConnectionManager.connectedToChat = true
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
        advertiserAssistant = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ConnectionManager.service)
        advertiserAssistant?.delegate = self
        advertiserAssistant?.startAdvertisingPeer()
    }
    
    func leaveChat() {
        isHosting = false
        ConnectionManager.connectedToChat = false
        advertiserAssistant?.stopAdvertisingPeer()
        ConnectionManager.messages.removeAll()
        session = nil
        advertiserAssistant = nil
    }
    
    @objc func updateTime() {

        delegate?.updateDuration(startTime, current: Date())
        
    }
}


extension ConnectionManager: MCSessionDelegate {
    
    // need to order Viewcontroller to trigger video recording when data received
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        guard let orderMessage = String(data: data, encoding: .utf8) else { return }
        
        switch orderMessage {
        case OrderMessageTypes.presentCamera:
            delegate?.presentVideo()
            
        case OrderMessageTypes.startRecording:
            NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.startRecordingFromVC), object: nil)
            
        case OrderMessageTypes.stopRecording:
            print("stop Recording!")
//            NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.stopRecordingFromVC), object: nil)
            
        case OrderMessageTypes.save:
            break
        default:
            break
            
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            if !ConnectionManager.peers.contains(peerID) {
                ConnectionManager.peers.insert(peerID, at: 0)
            }
            
            print("state: connected !")
            startTime = Date()
            
            delegate?.showStart(startTime)
            delegate?.updateState(state: "connected!")
            
            
        case .notConnected:
            if let index = ConnectionManager.peers.firstIndex(of: peerID) {
                ConnectionManager.peers.remove(at: index)
            }
            if ConnectionManager.peers.isEmpty && !self.isHosting {
                ConnectionManager.connectedToChat = false
            }
            
            endTime = Date()
            delegate?.updateState(state: "not connected!")
            
            print("connection remained for \((endTime.timeIntervalSince1970 - startTime.timeIntervalSince1970) / 60) min")
            
            print("state: not connected !!")
            delegate?.disconnected(state: "disconnected!", timeDuration: Int(endTime.timeIntervalSince1970 - startTime.timeIntervalSince1970))
            
        case .connecting:
            print("it's connecting .. ")
        @unknown default:
            fatalError(" it's in unknown state")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Receiving chat history")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        guard let localURL = localURL,
              let data = try? Data(contentsOf: localURL),
              let messages = try? JSONDecoder().decode([ChatMessage].self, from: data)
        else { return }
        
    }
}

extension ConnectionManager: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true) {
            ConnectionManager.connectedToChat = true
        }
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        session?.disconnect()
        browserViewController.dismiss(animated: true)
    }
}

