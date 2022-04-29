//
//  PositionDirection.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/27.
//

import Foundation

enum PositionDirection:Codable {
    case left
    case right
    case neutral // represent 'Center' or 'Neutral'
//    case not
}

struct PositionInfo: Codable {
    var title: String
    
//    var direction: PositionDirection
    var imageName: [String]
    var score: [Int?] = [nil, nil]
    
    var leftRight: Bool {
        return imageName.count == 2 ? true : false
    }
}

struct PositionWithDirectionInfo: Codable {
    var title: String
    
    var direction: PositionDirection
//    var imageName: String
    var score: Int?
    
//    var leftRight: Bool {
//        return imageName.count == 2 ? true : false
//    }
}

struct DetailPositionWIthMsgInfo: Codable {

    var message: MessageType
    
//    var positionInfo: PositionInfo?
    var detailInfo: PositionWithDirectionInfo
}


public enum MessageType: String, Codable {
    case presentCamera
    // Do I need to dismiss ?
    // Timer ?
    case startRecording
    case stopRecording
    case none
}
