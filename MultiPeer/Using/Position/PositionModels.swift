//
//  PositionModels.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//

import Foundation


enum PositionDirection: String, Codable  {
    case left = "Left"
    case right = "Right"
    case neutral = "Neutral"
}

struct PositionInfo: Codable {
    var title: String
    
    var imageName: [String]
    var score: [Int?] = [nil, nil]
    
    var variationName: String?
    
    var leftRight: Bool {
        return imageName.count == 2 ? true : false
    }
}

//struct PositionInfoDetail: Codable {
//    var title: String
//
//    var imageName: [String]
//    var score: [Int?] = [nil, nil]
//
//    var variationName: String?
//
//    var sequentialPainPosition: String?
//
//    var leftRight: Bool {
//        return imageName.count == 2 ? true : false
//    }
//}

struct PositionDirectionScoreInfo: Codable {
    var title: String
    var direction: PositionDirection
    var score: Int?
    var pain: Bool?
}




struct PositionWithVarName {
    var positionName: PositionList
    var positionVarName: PositionList
    
    init(position name: PositionList, varName: PositionList) {
        self.positionName = name
        self.positionVarName = varName
    }
}


struct DetailPositionWIthMsgInfo: Codable {
    var message: MessageType
    var detailInfo: PositionDirectionScoreInfo
}



public struct PositionWithPainTestName {
    var positionName: PositionList
    var painTestName: PositionList
    
    init(position name: PositionList, testName: PositionList) {
        self.positionName = name
        self.painTestName = testName
    }
}
