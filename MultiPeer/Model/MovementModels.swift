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

enum CameraDirection: String, Codable {
    case front = "Front"
    case side = "Side"
    case between = "45°"
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

/// title, direction, score, pain
struct MovementDirectionScoreInfo: Codable {
    var title: String
    var direction: MovementDirection
    var score: Int?
    var pain: Bool?
}

struct MovementTitleDirectionInfo: Codable {
    var title: String
    var direction: MovementDirection
}




struct MovementWithVarName {
    var positionName: MovementList
    var positionVarName: MovementList
    
    init(position name: MovementList, varName: MovementList) {
        self.positionName = name
        self.positionVarName = varName
    }
}




struct LottieMsgInfo: Codable {
    var lottieType: LottieType
}

enum LottieType: String, Codable {
    case countDown
}


public struct MovementWithPainTestName {
    var positionName: MovementList
    var painTestName: MovementList
    
    init(position name: MovementList, testName: MovementList) {
        self.positionName = name
        self.painTestName = testName
    }
}

