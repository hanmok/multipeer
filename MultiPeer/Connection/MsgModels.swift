//
//  MsgModels.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//

import Foundation


import Foundation


struct MsgWithMovementDetail: Codable {
    var message: MessageType
    var detailInfo: MovementDirectionScoreInfo // 이게 문제
    
}

struct PeerInfo: Codable {
    var msgType: MessageType
    var info: Info
}

struct Info: Codable {
    var movementDetail: MovementDirectionScoreInfo?
//    var cameraDirection: CameraDirection?
    var idWithDirection: PeerIdWithCameraDirection?
}

struct PeerIdWithCameraDirection: Codable {
    var peerId: String
    var cameraDirection: CameraDirection
}

struct MsgWithTime: Codable {
    let msg: MessageType
    let timeInMilliSec: Int
}

struct PeerCommunicationHelper {
    static let msgToKeyDic: [MessageType: Notification.Name] = [
        .startRecordingMsg: .startRecordingKey,
        .stopRecordingMsg: .stopRecordingKey,
        .hidePreviewMsg: .hidePreviewKey,
        
        
        .presentCamera: .presentCameraKey,
        .updatePeerTitle: .updatePeerTitleKey,
        .requestPostMsg: .requestPostKey,
        
        .updatePeerCameraDirection: .updatePeerCameraDirectionKey
    ]
}




//struct MessageWithInfo {
//    var date: Date
//    var messageType: OrderMessageTypes
//}



// MARK: - Message

public enum MessageType: String, Codable {
    case hidePreviewMsg
    case startRecordingMsg
    case stopRecordingMsg
//    case saveMsg
    
    case presentCamera
    case requestPostMsg
    case updatePeerTitle
    
    case updatePeerCameraDirection
}



// MARK: - Connection State
public enum ConnectionState: String, Codable {
    case connected
    case disconnected
}


