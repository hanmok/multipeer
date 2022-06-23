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

    var latestDirection: CameraDirection?
    
    static let shared = ConnectionManager()
    
    private static let service = "jobmanager-chat"
    
    weak var delegate: ConnectionManagerDelegate?
    
    
    
    static var peers: [MCPeerID] = [] {
        didSet {
            print("current peers: \(oldValue.count)")
        }
    }
    
    var cameraDirectionDic: [String: CameraDirection] = [:]
    
    let myId = UIDevice.current.name
    var mydirection: CameraDirection?
    var peersId = Set<String>()
    var numOfPeers = 0
    
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
    
    func send(_ peerInfo: PeerInfo) {
        let encoder = JSONEncoder()
        
        guard let session = session else { return }
        
        do {
//            let data = try encoder.encode(movementCore)
            let data = try encoder.encode(peerInfo)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    
    func join() {
        // TODO: 이게 뭔 코드여? removeAll() ? why ?
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
            let receivedData = try jsonDecoder.decode(PeerInfo.self, from: data)
            let messageType = receivedData.msgType
            
            guard let notificationName = PeerCommunicationHelper.msgToKeyDic[messageType] else { fatalError() }
            
            switch messageType {
                // no msg
            case .startRecordingMsg,
                    .stopRecordingMsg,
                    .hidePreviewMsg:
                NotificationCenter.default.post(name: notificationName, object: nil)
            // detail info
                
            case .presentCameraMsg
                , .updatePeerTitleMsg: // fatalError!!
                guard let titleDirectionInfo = receivedData.info.movementTitleDirection else { fatalError() }
                
                let titleDirectionDic: [AnyHashable: Any] = [
                    "title": titleDirectionInfo.title,
                    "direction": titleDirectionInfo.direction
                ]
                
                NotificationCenter.default.post(name: notificationName, object: nil, userInfo: titleDirectionDic)
                
//            case .presentCameraMsg,
//                    .requestPostMsg,
//                    .updatePeerTitleMsg:
            case .requestPostMsg:
                
//                guard let reqInfoDic = receivedData.info.ftpInfo else { fatalError() }
//
//                let requestInfoDic: [AnyHashable: Any] = [
//                    "date": reqInfoDic.date,
//                    "inspectorName": reqInfoDic.inspectorName,
//                    "subjectName": reqInfoDic.subjectName,
//                    "screenIndex": reqInfoDic.screenIndex,
//
//                    "title": reqInfoDic.title,
//                    "direction": reqInfoDic.direction,
//                    "trialNo": reqInfoDic.trialNo,
//
//                    "phoneNumber": reqInfoDic.phoneNumber,
//                    "gender": reqInfoDic.gender,
//                    "birth": reqInfoDic.birth,
//                    "kneeLength": reqInfoDic.kneeLength,
//                    "palmLength": reqInfoDic.palmLength,
//                    "cameraAngle": reqInfoDic.cameraAngle
//                ]
                
                guard let reqInfoDic = receivedData.info.ftpInfoString else { fatalError() }
                
                let requestInfoDic: [AnyHashable: Any] = [
                    "fileName": reqInfoDic.fileName
                ]
                
                NotificationCenter.default.post(name: notificationName, object: nil, userInfo: requestInfoDic)
                
            case .updatePeerCameraDirectionMsg:
                // CameraDirection Used
                guard let idWithCamera = receivedData.info.idWithDirection else { fatalError() }
                
                let peerId = idWithCamera.peerId
                let cameraDirection = idWithCamera.cameraDirection
                
                cameraDirectionDic[peerId] = cameraDirection
                
                // TODO: 중복 체크.
                //
//                showalert 처리는 여기서 못함.. notification post 로 가서 처리하자. 아냐 ;; 버튼 누를 때 이미 처리했어 ㅠㅠ
                //
             default: print("default case !")
            }
            
            
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("session delegate called")
        switch state {
        case .connected:
            print("connectionFlag, case: connected")
            if !ConnectionManager.peers.contains(peerID) {
                ConnectionManager.peers.insert(peerID, at: 0)
            }
                        
            self.numOfPeers = ConnectionManager.peers.count
            self.connectionState = .connected
            print("state: connected !")
            startTime = Date()
            
            delegate?.updateState(state: .connected, connectedAmount: self.numOfPeers)
            
            self.startDurationTimer()
            
        case .notConnected:
            print("connectionFlag, case: notconnected")
            if let index = ConnectionManager.peers.firstIndex(of: peerID) {
                ConnectionManager.peers.remove(at: index)
            }
            if ConnectionManager.peers.isEmpty && !self.isHosting {
                ConnectionManager.connectedToChat = false
            }
            self.numOfPeers = 0
            self.connectionState = .disconnected
            endTime = Date()
            
            delegate?.updateState(state: .disconnected, connectedAmount: self.numOfPeers)
        
            numOfPeers = 0
            
            print("disconnected!!")
        case .connecting:
            print("connectionFlag, case: connecting")
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


/*
static let msgToKeyDic: [MessageType: Notification.Name] = [
    .startRecordingMsg: .startRecordingKey,
    .stopRecordingMsg: .stopRecordingKey,
    .hidePreviewMsg: .hidePreviewKey,
    
    .presentCameraMsg: .presentCameraKey,
    .updatePeerTitleMsg: .updatePeerTitleKey,
    .requestPostMsg: .requestPostKey,
    
    .updatePeerCameraDirectionMsg: .updatePeerCameraDirectionKey
]
*/
