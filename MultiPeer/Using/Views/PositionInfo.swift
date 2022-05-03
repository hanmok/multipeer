//
//  Position.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/26.
//

import Foundation
import UIKit




enum PositionList: String {
    case deepSquat = "Deep Squat"
    case hurdleStep = "Hurdle Step"
    case inlineLunge = "Inline Lunge"
    case ankleClearing = "Ankle Clearing"
    case shoulderMobility = "shoulder Mobility"
    case shoulderClearing = "Shoulder Clearing"
    case activeStraightLegRaise = "Active Straight-LegRaise"
    case trunkStabilityPushUp = "Trunk Stability Push-up"
    case extensionClearing = "Extension Clearing"
    case rotaryStability = "Rotary Stability"
    case flexionClearing = "Flexion Clearing"
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



var positionList: [PositionInfo] = [
    PositionInfo(title: PositionImgs.deepSquat.0,
                  imageName: [PositionImgs.deepSquat.imageNames[0]]),

    PositionInfo(title: PositionImgs.deepSquat.0,
                  imageName: [PositionImgs.hurdleStep.imageNames[0], PositionImgs.hurdleStep.imageNames[1]]),
    
    PositionInfo(title: PositionImgs.inlineLunge.0,
                  imageName: [PositionImgs.inlineLunge.imageNames[0],PositionImgs.inlineLunge.imageNames[1]]),
    
    PositionInfo(title: PositionImgs.shoulderMobility.0,
                  imageName: [PositionImgs.shoulderMobility.imageNames[0], PositionImgs.shoulderMobility.imageNames[1]]),
    
    PositionInfo(title: PositionImgs.straightLegRaise.0,
                  imageName: [PositionImgs.straightLegRaise.imageNames[0], PositionImgs.straightLegRaise.imageNames[1]]),
    
    PositionInfo(title: PositionImgs.stabilityPushup.0,
                  imageName: [PositionImgs.stabilityPushup.imageNames[0], PositionImgs.stabilityPushup.imageNames[1]]),
    
    PositionInfo(title: PositionImgs.rotaryStability.0,
                  imageName:[PositionImgs.rotaryStability.imageNames[0], PositionImgs.rotaryStability.imageNames[1]]),
    
    PositionInfo(title: PositionImgs.shoulderClearing.0,
                  imageName: [PositionImgs.shoulderClearing.imageNames[0], PositionImgs.shoulderClearing.imageNames[1]]),
    
    
    PositionInfo(title: PositionImgs.extensionClearing.0, imageName: [PositionImgs.extensionClearing.imageNames[0]]),
    PositionInfo(title: PositionImgs.flexionClearing.0, imageName: [PositionImgs.flexionClearing.imageNames[0]])
]

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
