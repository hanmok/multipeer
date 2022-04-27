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



var positionList: [Position] = [
    Position(title: PositionImgs.deepSquat.0,
                  imageName: [PositionImgs.deepSquat.imageNames[0]]),
    
    
    
    Position(title: PositionImgs.deepSquat.0,
                  imageName: [PositionImgs.hurdleStep.imageNames[0], PositionImgs.hurdleStep.imageNames[1]]),
    
    Position(title: PositionImgs.inlineLunge.0,
                  imageName: [PositionImgs.inlineLunge.imageNames[0],PositionImgs.inlineLunge.imageNames[1]]),
    
    Position(title: PositionImgs.shoulderMobility.0,
                  imageName: [PositionImgs.shoulderMobility.imageNames[0], PositionImgs.shoulderMobility.imageNames[1]]),
    
    Position(title: PositionImgs.straightLegRaise.0,
                  imageName: [PositionImgs.straightLegRaise.imageNames[0], PositionImgs.straightLegRaise.imageNames[1]]),
    
    Position(title: PositionImgs.stabilityPushup.0,
                  imageName: [PositionImgs.stabilityPushup.imageNames[0], PositionImgs.stabilityPushup.imageNames[1]]),
    
    Position(title: PositionImgs.rotaryStability.0,
                  imageName:[PositionImgs.rotaryStability.imageNames[0], PositionImgs.rotaryStability.imageNames[1]]),
    
    Position(title: PositionImgs.shoulderClearing.0,
                  imageName: [PositionImgs.shoulderClearing.imageNames[0], PositionImgs.shoulderClearing.imageNames[1]]),
    
    
    Position(title: PositionImgs.extensionClearing.0, imageName: [PositionImgs.extensionClearing.imageNames[0]]),
    Position(title: PositionImgs.flexionClearing.0, imageName: [PositionImgs.flexionClearing.imageNames[0]])
]

enum PositionListEnum {
    static let deepsquat = Position(title: PositionImgs.deepSquat.0,
                                         imageName: [PositionImgs.deepSquat.imageNames[0]])
    
    static let hurdleStep = Position(title: PositionImgs.hurdleStep.0,
                                          imageName: [PositionImgs.hurdleStep.imageNames[0],
                                                      PositionImgs.hurdleStep.imageNames[1]])
    static let inlineLunge = Position(title: PositionImgs.inlineLunge.0,
                                           imageName: [PositionImgs.inlineLunge.imageNames[0],
                                                       PositionImgs.inlineLunge.imageNames[1]])
    
    static let ankleClearing = Position(title: PositionImgs.ankleClearing.0,
                                           imageName: [PositionImgs.ankleClearing.imageNames[0],
                                                       PositionImgs.ankleClearing.imageNames[1]])
    
    
    
    static let shoulderMobility = Position(title: PositionImgs.shoulderMobility.0,
                                                imageName: [PositionImgs.shoulderMobility.imageNames[0],
                                                            PositionImgs.shoulderMobility.imageNames[1]])
    static let shoulderClearing = Position(title: PositionImgs.shoulderClearing.0,
                                        imageName: [PositionImgs.shoulderClearing.imageNames[0],
                                                    PositionImgs.shoulderClearing.imageNames[1]])
    static let straightLegRaise = Position(title: PositionImgs.straightLegRaise.0,
                                                imageName: [PositionImgs.straightLegRaise.imageNames[0],
                                                            PositionImgs.straightLegRaise.imageNames[1]])
    
    static let stabilityPushup = Position(title: PositionImgs.stabilityPushup.0,
                                               imageName: [PositionImgs.stabilityPushup.imageNames[0]])
    static let extensionClearing = Position(title: PositionImgs.extensionClearing.0,
                                          imageName: [PositionImgs.extensionClearing.imageNames[0]])
    static let rotaryStability = Position(title: PositionImgs.rotaryStability.0,
                                               imageName:[PositionImgs.rotaryStability.imageNames[0],
                                                          PositionImgs.rotaryStability.imageNames[1]])
    static let flexionClearing = Position(title: PositionImgs.flexionClearing.0, imageName:
                                        [PositionImgs.flexionClearing.imageNames[0]])
}
