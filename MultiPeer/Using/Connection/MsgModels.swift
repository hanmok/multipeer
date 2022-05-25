//
//  MsgModels.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//

import Foundation


import Foundation

struct MsgWithTime: Codable {
    let msg: MessageType
    let timeInMilliSec: Int
}


struct MessageWithInfo {
    var date: Date
    var messageType: OrderMessageTypes
}



// MARK: - Message

public enum MessageType: String, Codable {
    case presentCamera
    // Do I need to dismiss ?
    // Timer ?
    case startRecordingMsg
    case stopRecordingMsg
    case startRecordingAfterMsg
    case startCountDownMsg
    case none
}


public enum OrderMessageTypes {
    case presentCameraMsg
    case startRecordingMsg
    case stopRecordingMsg
}


// MARK: - Connection State
public enum ConnectionState: String, Codable {
    case connected
    case disconnected
}

