//
//  ConnectionManager.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/14.
//

import Foundation
import MultipeerConnectivity
import AVFoundation


// MARK: - references for later

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
//}






// MARK: - ConnectionManager Delegate Protocol
protocol ConnectionManagerDelegate: NSObject {
//    func presentVideo() // What the hell is that ?
    
    func updateState(state: ConnectionState, connectedAmount: Int)
//    func updateDuration(in seconds: Int)
}




// TODO: Diversify Delegate for Each Controllers (MovementListController, CameraController) Sure ?? What about Common Situations ?

class ConnectionManager: NSObject {
    
    var isHost = false
    var connectionState: ConnectionState = .disconnected
    var duration = 0
    
     var sessionTimer: Timer?

    static let shared = ConnectionManager()
    
    private static let service = "jobmanager-chat"
    
    weak var delegate: ConnectionManagerDelegate?
    
    static var peers: [MCPeerID] = [] {
        didSet {
            print("current peers: \(oldValue.count)")
        }
    }
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
    
    func send(_ customMsg: String) {

//        let chatMessage = ChatMessage(displayName: myPeerId.displayName, body: message)
//        ConnectionManager.messages.append(chatMessage)

        let encoder = JSONEncoder()
        
        guard let session = session else {return }
        do {
            let data = try encoder.encode(customMsg)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
//        guard let session = session,
//              let data = customMsg.data(using: .utf8),
//              !session.connectedPeers.isEmpty else { return }
//        do {
//            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
//        } catch {
//            print("Error ! \(error.localizedDescription) ")
//        }
    }
    
    // FIXME: Action need to be changed to send difference of recording start time
    func send(_ messageWithTime: MsgWithTime) {
//        print("message: \(message.rawValue) sended")
        let encoder = JSONEncoder()
        
        guard let session = session else {return }
        do {
            let data = try encoder.encode(messageWithTime)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }
    // invalid peer id ?
    func send(_ message: MessageType) {
        print("message: \(message.rawValue) sended")
        let encoder = JSONEncoder()

        guard let session = session else { return }
        
        do {
            let data = try encoder.encode(message)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print(error.localizedDescription)
            fatalError("Fatal Error during encoding!!", file: #function)
        }
    }
    
    
    
    func send(_ movement: MsgWithMovementDetail) {
        print("message: \(movement.message.rawValue) sended")
        let encoder = JSONEncoder()

        guard let session = session else { return }
        
        do {
            let data = try encoder.encode(movement)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print(error.localizedDescription)
//            fatalError("Fatal Error during encoding!!", file: #function)
        }
    }
    
    func send(_ movementCore: TrialCore) {
        let encoder = JSONEncoder()
        
        guard let session = session else { return }
        
        do {
            let data = try encoder.encode(movementCore)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    func join() {
        ConnectionManager.peers.removeAll()

        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
        
        guard let window = UIApplication.shared.windows.first,
              let session = session else { return }
        
        let mcBrowerViewController = MCBrowserViewController(serviceType: ConnectionManager.service, session: session)
        mcBrowerViewController.modalPresentationStyle = .formSheet
        mcBrowerViewController.delegate = self

        window.rootViewController?.present(mcBrowerViewController, animated: true)
    }
    
    func host() {
        isHosting = true
        ConnectionManager.peers.removeAll()
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
        session = nil
        advertiserAssistant = nil
    }
    
    func startDurationTimer() {
        print("connection timer has started!")
        
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let `self` = self else { return }
            

            self.duration += 1
        }
    }
}


// MARK: - MCSessionDelegate
extension ConnectionManager: MCSessionDelegate {

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("data received via ConnectionManager !!")
        
        
        let jsonDecoder = JSONDecoder()
        
        do {
            let movementInfoWithMsg = try jsonDecoder.decode(MsgWithMovementDetail.self, from: data)
            
            let detailInfo = movementInfoWithMsg.detailInfo
            
            let msg = movementInfoWithMsg.message
            
            let detailInfoDic: [AnyHashable: Any] = [
                "title": detailInfo.title,
                "direction": detailInfo.direction,
                "score": detailInfo.score ?? -1
            ]
            
            switch msg {
                
            case .presentCamera:
                // TODO: Send Message with position Info
                
                NotificationCenter.default.post(name: .presentCameraKey, object: nil, userInfo: detailInfoDic)
                print("NotificationKey named presentCamera has posted.")
                break
                
            case .startRecordingMsg:
                // TODO: Send Message with position Info
                print("post startRecording !!")
                NotificationCenter.default.post(name: .startRecordingKey, object: nil, userInfo: detailInfoDic)
                
            case .stopRecordingMsg:
                // TODO: Send Message with position Info
                NotificationCenter.default.post(name: .stopRecordingKey, object: nil, userInfo: detailInfoDic)
                break
                
            case .updatePeerTitle:
                NotificationCenter.default.post(name: .updatePeerTitleKey, object: nil, userInfo: detailInfoDic)
                
            case .none:
                print("none has been passed!")
                break
            
                // TODO: Make it work
            case .requestPostMsg:
                NotificationCenter.default.post(name: .requestPostKey, object: nil, userInfo: detailInfoDic)
            }
            
        } catch {
            print("error: \(error.localizedDescription)")
                print("Error Occurred during Decoding DetailPositionWithMsgInfo!!!")
                do {
                    let testInfoMsg = try jsonDecoder.decode(MsgWithTime.self, from: data)
                    
                    let msgReceived = testInfoMsg.msg
                    let timeReceived = testInfoMsg.timeInMilliSec
                    
                    let timeInfo: [AnyHashable: Any] = ["msg": msgReceived,"receivedTime": timeReceived]
                    
                    switch msgReceived {
                        
//                    case .startRecordingAfterMsg:
//                        NotificationCenter.default.post(name: .startRecordingAfterKey, object: nil, userInfo: timeInfo)
//                    print("successfully post startRecordingAfterKey")
                        
//                    case .startCountDownMsg:
//                        NotificationCenter.default.post(name: .startCountdownAfterKey, object: nil, userInfo: timeInfo)
//                        print("post startCountdownAfterKey")
                    
                    default:
                        print("something has posted! \(msgReceived.rawValue)")
                    }
                    print(#function, #line)
                } catch {
                    print("Error Occurred during Decoding String!!!", #file, #line)
                    print("Error : \(error.localizedDescription)")
                }
        }
        
        
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            if !ConnectionManager.peers.contains(peerID) {
                ConnectionManager.peers.insert(peerID, at: 0)
            }

            
            let connectedNum = ConnectionManager.peers.count
            print("connectedNum: \(connectedNum)")
            self.connectionState = .connected
            print("state: connected !")
            startTime = Date()
            
            delegate?.updateState(state: .connected, connectedAmount: connectedNum)
            
            self.startDurationTimer()
            
        case .notConnected:

            if let index = ConnectionManager.peers.firstIndex(of: peerID) {
                ConnectionManager.peers.remove(at: index)
            }
            if ConnectionManager.peers.isEmpty && !self.isHosting {
                ConnectionManager.connectedToChat = false
            }
            self.connectionState = .disconnected
            endTime = Date()
            
            delegate?.updateState(state: .disconnected, connectedAmount: 0)
            
            print("disconnected!!")
        case .connecting:
            print("it's connecting .. ")
        @unknown default:
            fatalError(" it's in unknown state")
        }
        
        let connectionInfo: [AnyHashable: Any] = ["connectionState": connectionState]
        NotificationCenter.default.post(name: .updateConnectionStateKey, object: nil, userInfo: connectionInfo)
        
        
//        delegate?.updateState(state: state)
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


// MARK: - MCBrowserViewController Delegate
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



// MARK: - MCNearbyServiceAdvertiser Delegate
extension ConnectionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}
