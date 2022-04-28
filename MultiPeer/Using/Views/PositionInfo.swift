//
//  Position.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/26.
//

import Foundation







enum PositionImgs {
    static let deepSquat = (title: "Deep Squat", imageNames: ["deepSquat"])
    static let hurdleStep = (title: "Hurdle Step", imageNames: ["hurdleStepLeft", "hurdleStepRight"])
    static let inlineLunge = (title: "Inline Lunge", imageNames: ["inlineLungeLeft","inlineLungeRight"])
    static let ankleClearing = (title: "Ankle Clearing", imageNames: ["ankleClearingLeft","ankleClearingRight"])
    
    static let shoulderMobility = (title: "shoulder Mobility", imageNames: ["shoulderMobilityLeft", "shoulderMobilityRight"])
    static let shoulderClearing = (title: "Shoulder Clearing", imageNames: ["shoulderClearingLeft", "shoulderClearingRight"])
    static let straightLegRaise = (title: "Active Straight-LegRaise", imageNames: ["activeStraightLegRaiseLeft", "activeStraightLegRaiseRight"])
    
    static let stabilityPushup = (title: "Trunk Stability Push-up", imageNames: ["trunkStabilityPushup"])
    static let extensionClearing = (title: "Extension Clearing", imageNames: ["extensionClearing"])
    static let rotaryStability = (title: "Rotary Stability", imageNames: ["rotaryStabilityLeft","rotaryStabilityRight"])
    static let flexionClearing = (title: "Flexion Clearing", imageNames: ["flexionClearing"])
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

enum PositionListEnum {
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
