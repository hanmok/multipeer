//
//  PositionLists.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//

import Foundation


// MARK: - Position
enum PositionList: String, CaseIterable {
    case deepSquat = "Deep Squat"
    case deepSquatVar = "Deep Squat Var"
    case hurdleStep = "Hurdle Step"
    case inlineLunge = "Inline Lunge"
    case ankleClearing = "Ankle Clearing"
    case shoulderMobility = "Shoulder Mobility"
    case shoulderClearing = "Shoulder Clearing"
    case activeStraightLegRaise = "Active Straight-LegRaise"
    case trunkStabilityPushUp = "Trunk Stability Push-up"
    case trunkStabilityPushUpVar = "Trunk Stability Push-up Var"
    case extensionClearing = "Extension Clearing"
    case rotaryStability = "Rotary Stability"
    case flexionClearing = "Flexion Clearing"
}

// Make positionList accessable using Index
extension CaseIterable where Self: Equatable {
    var index: Self.AllCases.Index? {
        return Self.allCases.firstIndex { self == $0 }
    }
}

struct Dummy {
    static let directionName: [Int: [String]] = [1: ["Neutral"], 2: ["Left", "Right"]]
    
    static let numOfDirections: [PositionList: Int] = [
        .deepSquat : 1,
        .deepSquatVar : 1,
        .hurdleStep:2,
        .inlineLunge:2,
        .ankleClearing: 2,
        .shoulderMobility:2,
        .shoulderClearing:2,
        .activeStraightLegRaise:2,
        .trunkStabilityPushUp:1,
        .trunkStabilityPushUpVar:1,
        .extensionClearing:1,
        .rotaryStability:2,
        .flexionClearing:1
    ]
}






enum PositionImgs {
    
    static let deepSquat = (title: PositionList.deepSquat.rawValue, imageNames: ["deepSquat"])
    static let hurdleStep = (title: PositionList.hurdleStep.rawValue, imageNames: ["hurdleStepLeft", "hurdleStepRight"])
    static let inlineLunge = (title: PositionList.inlineLunge.rawValue, imageNames: ["inlineLungeLeft","inlineLungeRight"])
    static let ankleClearing = (title: PositionList.ankleClearing.rawValue, imageNames: ["ankleClearingLeft","ankleClearingRight"])
    
    static let shoulderMobility = (title: PositionList.shoulderMobility.rawValue, imageNames: ["shoulderMobilityLeft", "shoulderMobilityRight"])
    static let shoulderClearing = (title: PositionList.shoulderClearing.rawValue, imageNames: ["shoulderClearingLeft", "shoulderClearingRight"])
    static let straightLegRaise = (title: PositionList.activeStraightLegRaise.rawValue, imageNames: ["activeStraightLegRaiseLeft", "activeStraightLegRaiseRight"])
    
    static let stabilityPushup = (title: PositionList.trunkStabilityPushUp.rawValue, imageNames: ["trunkStabilityPushup"])
    static let extensionClearing = (title: PositionList.extensionClearing.rawValue, imageNames: ["extensionClearing"])
    static let rotaryStability = (title: PositionList.rotaryStability.rawValue, imageNames: ["rotaryStabilityLeft","rotaryStabilityRight"])
    static let flexionClearing = (title: PositionList.flexionClearing.rawValue, imageNames: ["flexionClearing"])
}


enum PositionWithImageListEnum {
    static let deepsquat = PositionInfo(title: PositionImgs.deepSquat.0,
                                         imageName: [PositionImgs.deepSquat.imageNames[0]])
    
    static let hurdleStep = PositionInfo(title: PositionImgs.hurdleStep.0,
                                          imageName: [PositionImgs.hurdleStep.imageNames[0],
                                                      PositionImgs.hurdleStep.imageNames[1]])
    static let inlineLunge = PositionInfo(title: PositionImgs.inlineLunge.0,
                                           imageName: [PositionImgs.inlineLunge.imageNames[0],
                                                       PositionImgs.inlineLunge.imageNames[1]])
    
    static let ankleClearing = PositionInfo(title: PositionImgs.ankleClearing.0,
                                           imageName: [PositionImgs.ankleClearing.imageNames[0],
                                                       PositionImgs.ankleClearing.imageNames[1]])
    
    
    
    static let shoulderMobility = PositionInfo(title: PositionImgs.shoulderMobility.0,
                                                imageName: [PositionImgs.shoulderMobility.imageNames[0],
                                                            PositionImgs.shoulderMobility.imageNames[1]])
    static let shoulderClearing = PositionInfo(title: PositionImgs.shoulderClearing.0,
                                        imageName: [PositionImgs.shoulderClearing.imageNames[0],
                                                    PositionImgs.shoulderClearing.imageNames[1]])
    static let straightLegRaise = PositionInfo(title: PositionImgs.straightLegRaise.0,
                                                imageName: [PositionImgs.straightLegRaise.imageNames[0],
                                                            PositionImgs.straightLegRaise.imageNames[1]])
    
    static let stabilityPushup = PositionInfo(title: PositionImgs.stabilityPushup.0,
                                               imageName: [PositionImgs.stabilityPushup.imageNames[0]])
    static let extensionClearing = PositionInfo(title: PositionImgs.extensionClearing.0,
                                          imageName: [PositionImgs.extensionClearing.imageNames[0]])
    static let rotaryStability = PositionInfo(title: PositionImgs.rotaryStability.0,
                                               imageName:[PositionImgs.rotaryStability.imageNames[0],
                                                          PositionImgs.rotaryStability.imageNames[1]])
    static let flexionClearing = PositionInfo(title: PositionImgs.flexionClearing.0, imageName:
                                        [PositionImgs.flexionClearing.imageNames[0]])
}



// 위, 아래가 중복 데이터임. ;; 어.. 어떤 형태로 사용할 지 정해주는게 좋을 것 같은데 ??
// 현재 안쓰는중
public enum PositionWithPain {
    case ankleClearing
    case shoulderClearing
    case extensionClearing
    case flexionClearing
}

public let positionWithPainNoAnkle = [
    PositionList.shoulderClearing.rawValue,
    PositionList.flexionClearing.rawValue,
    PositionList.extensionClearing.rawValue
]

// 둘중 하나는 없애는게 ..
// 이것도 안쓰고있음.
public let positionsHasPain = [
    PositionList.ankleClearing.rawValue,
    PositionList.shoulderClearing.rawValue,
    PositionList.flexionClearing.rawValue,
    PositionList.extensionClearing.rawValue
]

public let positionWithPainTestTitle: [String: String] = [
    PositionList.ankleClearing.rawValue : PositionList.ankleClearing.rawValue,
    PositionList.shoulderMobility.rawValue: PositionList.shoulderClearing.rawValue,
    PositionList.trunkStabilityPushUp.rawValue: PositionList.extensionClearing.rawValue,
    PositionList.trunkStabilityPushUpVar.rawValue: PositionList.extensionClearing.rawValue,
    PositionList.rotaryStability.rawValue: PositionList.flexionClearing.rawValue
]

public let positionWithVariation: [String: String] = [
    PositionList.deepSquat.rawValue : PositionList.deepSquatVar.rawValue,
    PositionList.trunkStabilityPushUp.rawValue: PositionList.trunkStabilityPushUpVar.rawValue
]



// MARK: - Score

public enum ScoreType {
    case zeroThreeHold
    case zeroToThree
    case zeroToTwo
    case painOrNot
    case RYG
}

let positionToScoreType: [String: ScoreType] = [
    PositionList.deepSquat.rawValue: .zeroThreeHold,
    PositionList.deepSquatVar.rawValue: .zeroToTwo,
    
    PositionList.hurdleStep.rawValue: .zeroToThree,
    PositionList.inlineLunge.rawValue: .zeroToThree,

    PositionList.ankleClearing.rawValue: .RYG,
//        PositionList.ankleClearing.rawValue: .RGB,
    
    PositionList.shoulderMobility.rawValue: .zeroToThree,
//        PositionList.shoulderClearing.rawValue: .painOrNot,
    
    PositionList.activeStraightLegRaise.rawValue: .zeroToThree,
    
    PositionList.trunkStabilityPushUp.rawValue: .zeroThreeHold,
    PositionList.trunkStabilityPushUpVar.rawValue: .zeroToTwo,
//        PositionList.extensionClearing.rawValue: .painOrNot,
    
    PositionList.rotaryStability.rawValue: .zeroToThree,
//        PositionList.flexionClearing.rawValue: .painOrNot
]
