//
//  PositionModels.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//

import Foundation


enum MovementDirection: String, Codable  {
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

struct MovementDirectionScoreInfo: Codable {
    var title: String
    var direction: MovementDirection
    var score: Int?
    var pain: Bool?
}




struct PositionWithVarName {
    var positionName: MovementList
    var positionVarName: MovementList
    
    init(position name: MovementList, varName: MovementList) {
        self.positionName = name
        self.positionVarName = varName
    }
}


struct DetailPositionWIthMsgInfo: Codable {
    var message: MessageType
    var detailInfo: MovementDirectionScoreInfo
}

struct LottieMsgInfo: Codable {
    var lottieType: LottieType
}

enum LottieType: String, Codable {
//    typealias RawValue = <#type#>
    case countDown
    
    
}



public struct PositionWithPainTestName {
    var positionName: MovementList
    var painTestName: MovementList
    
    init(position name: MovementList, testName: MovementList) {
        self.positionName = name
        self.painTestName = testName
    }
}
