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

//struct ChatMessage: Identifiable, Equatable, Codable {
//
//    var id = UUID()
//    let displayName: String
//    let body: String
//    var time = Date()
//
//    var isUser: Bool {
//        return displayName == UIDevice.current.name
//    }
//}

public enum OrderMessageTypes {
    static let presentCamera = "presentCamera"
    static let startRecording = "startRecording"
    static let stopRecording = "stopRecording"
}


extension ConnectionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

public enum ConnectionState: String {
    case connected
    case disconnected
    case connecting
}

protocol ConnectionManagerDelegate: NSObject {
    func presentVideo()
    func updateState(state: ConnectionState)
    func updateDuration(in seconds: Int)
}


class ConnectionManager: NSObject {
    
    var connectionState: ConnectionState = .disconnected
    var duration = 0
    
     var sessionTimer: Timer?
    
    static let shared = ConnectionManager()
    
    private static let service = "jobmanager-chat"
    
    weak var delegate: ConnectionManagerDelegate?
    
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
        
//        let chatMessage = ChatMessage(displayName: myPeerId.displayName, body: message)
//        ConnectionManager.messages.append(chatMessage)
        
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
//        ConnectionManager.messages.removeAll()
        
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
        
        guard let window = UIApplication.shared.windows.first,
              let session = session else { return }
        
        let mcBrowerViewController = MCBrowserViewController(serviceType: ConnectionManager.service, session: session)
        mcBrowerViewController.modalPresentationStyle = .formSheet
        mcBrowerViewController.delegate = self
//        present(mcBrowerViewController)
        window.rootViewController?.present(mcBrowerViewController, animated: true)
//        window.pres
    }
    
    func host() {
        isHosting = true
        ConnectionManager.peers.removeAll()
//        ConnectionManager.messages.removeAll()
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
//        ConnectionManager.messages.removeAll()
        session = nil
        advertiserAssistant = nil
    }
    
    @objc func updateTime() {
//        delegate?.updateDuration(startTime, current: Date())
    }
    
    func startDurationTimer() {
        print("connection timer has started!")
//        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//            guard let `self` = self else { return }
//
//
//            self.duration += 1
//            self.delegate?.updateDuration(in: self.duration)
//
//            print("ConnectionManager.duration: \(self.duration)")
//        }
        
        
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let `self` = self else {
                print("self is nil ")
                return }
            
            print("hi!!!!!")
//            self.count += 1
            self.duration += 1
            self.delegate?.updateDuration(in: self.duration)
            
//            DispatchQueue.main.async {
//                self.durationLabel.text = "\(self.count) s"
//            }
        }
        
        
    }

    
}


extension ConnectionManager: MCSessionDelegate {
    

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        guard let orderMessage = String(data: data, encoding: .utf8) else { return }
        
        switch orderMessage {
            
        case OrderMessageTypes.presentCamera:
            delegate?.presentVideo()
            
        case OrderMessageTypes.startRecording:
            print("received data: \(OrderMessageTypes.startRecording)")
            
            NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.startRecordingKey), object: nil)
            
        case OrderMessageTypes.stopRecording:
            print("received data: \(OrderMessageTypes.stopRecording)")
            
            NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.stopRecordingKey), object: nil)
            
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
            self.connectionState = .connected
            print("state: connected !")
            startTime = Date()
            
//            delegate?.showStart(startTime)
            delegate?.updateState(state: .connected)
            
            NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.connectedKey), object: nil)
            
            self.startDurationTimer()
            
        case .notConnected:
            self.connectionState = .disconnected
            if let index = ConnectionManager.peers.firstIndex(of: peerID) {
                ConnectionManager.peers.remove(at: index)
            }
            if ConnectionManager.peers.isEmpty && !self.isHosting {
                ConnectionManager.connectedToChat = false
            }
            
            endTime = Date()
            
//            delegate?.updateState(state: "not connected!")
            delegate?.updateState(state: .disconnected)
            
            
            NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.disconnectedKey), object: nil)
            
//            delegate?.disconnected(state: "disconnected!", timeDuration: Int(endTime.timeIntervalSince1970 - startTime.timeIntervalSince1970))
        
            print("disconnected!!")
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
        
//        guard let localURL = localURL,
//              let data = try? Data(contentsOf: localURL),
//              let messages = try? JSONDecoder().decode([ChatMessage].self, from: data)
                
//        else { return }
        
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

