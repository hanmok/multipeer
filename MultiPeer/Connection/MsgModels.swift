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
    var message: MessageType
    var info: Info
}

struct Info: Codable {
    var movementDetail: MovementDirectionScoreInfo?
    var cameraDirection: CameraDirection?
}

struct MsgWithTime: Codable {
    let msg: MessageType
    let timeInMilliSec: Int
}


//struct MessageWithInfo {
//    var date: Date
//    var messageType: OrderMessageTypes
//}



// MARK: - Message

public enum MessageType: String, Codable {
    case presentCamera

    case startRecordingMsg
    case stopRecordingMsg
    case none

    case requestPostMsg
    
    case updatePeerTitle
    
    case updatePeerCameraDirection
}


//public enum OrderMessageTypes {
//    case presentCameraMsg
//    case startRecordingMsg
//    case stopRecordingMsg
//    case requestPostMsg
//}



// MARK: - Connection State
public enum ConnectionState: String, Codable {
    case connected
    case disconnected
//    case notConnected
}

