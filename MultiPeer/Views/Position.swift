//
//  Position.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/26.
//

import Foundation


struct PositionBlock {
    var title: String
    
    var imageName: [String]
    var score: [Int?] = [nil]
    
    var leftRight: Bool {
        return imageName.count == 2 ? true : false
    }
}




enum PositionImgs {
    static let deepSquat = (title: "deep Squat", imageNames: ["deepSquat"])
    static let extensions = (title: "extensions", imageNames: ["extensions"])
    static let flexion = (title: "flexion", imageNames: ["flexion"])
    
    static let hurdleStep = (title: "hurdle Step", imageNames: ["hurdleStepLeft", "hurdleStepRight"])
    static let inlineLunge = (title: "inline Lunge", imageNames: ["inlineLungeLeft","inlineLungeRight" ])
    static let rotaryStability = (title: "rotary Stability", imageNames: ["rotaryStabilityLeft","rotaryStabilityRight"])
    static let shoulder = (title: "shoulder", imageNames: ["shoulderLeft", "shoulderRight"])
    static let shoulderMobility = (title: "shoulder Mobility", imageNames: ["shoulderMobilityLeft", "shoulderMobilityRight"])
    
    static let stabilityPushup = (title: "stability Pushup", imageNames: ["stabilityPushup"])
    
    static let straightLegRaise = (title: "straight LegRaise", imageNames: ["straightLegRaiseLeft", "straightLegRaiseRight"])
}
//



var positionList: [PositionBlock] = [
    PositionBlock(title: PositionImgs.deepSquat.0,
                  imageName: [PositionImgs.deepSquat.imageNames[0]]),
    
    
    
    PositionBlock(title: PositionImgs.deepSquat.0,
                  imageName: [PositionImgs.hurdleStep.imageNames[0], PositionImgs.hurdleStep.imageNames[1]]),
    
    PositionBlock(title: PositionImgs.inlineLunge.0,
                  imageName: [PositionImgs.inlineLunge.imageNames[0],PositionImgs.inlineLunge.imageNames[1]]),
    
    PositionBlock(title: PositionImgs.shoulderMobility.0,
                  imageName: [PositionImgs.shoulderMobility.imageNames[0], PositionImgs.shoulderMobility.imageNames[1]]),
    
    PositionBlock(title: PositionImgs.straightLegRaise.0,
                  imageName: [PositionImgs.straightLegRaise.imageNames[0], PositionImgs.straightLegRaise.imageNames[1]]),
    
    PositionBlock(title: PositionImgs.stabilityPushup.0,
                  imageName: [PositionImgs.stabilityPushup.imageNames[0], PositionImgs.stabilityPushup.imageNames[1]]),
    
    PositionBlock(title: PositionImgs.rotaryStability.0,
                  imageName:[PositionImgs.rotaryStability.imageNames[0], PositionImgs.rotaryStability.imageNames[1]]),
    
    PositionBlock(title: PositionImgs.shoulder.0,
                  imageName: [PositionImgs.shoulder.imageNames[0], PositionImgs.shoulder.imageNames[1]]),
    
    
    PositionBlock(title: PositionImgs.extensions.0, imageName: [PositionImgs.extensions.imageNames[0]]),
    PositionBlock(title: PositionImgs.flexion.0, imageName: [PositionImgs.flexion.imageNames[0]])
]

enum PositionListEnum {
    static let deepsquat = PositionBlock(title: PositionImgs.deepSquat.0,
                                         imageName: [PositionImgs.deepSquat.imageNames[0]])
    
    static let hurdleStep = PositionBlock(title: PositionImgs.hurdleStep.0,
                                          imageName: [PositionImgs.hurdleStep.imageNames[0], PositionImgs.hurdleStep.imageNames[1]])
    static let inlineLunge = PositionBlock(title: PositionImgs.inlineLunge.0,
                                           imageName: [PositionImgs.inlineLunge.imageNames[0],PositionImgs.inlineLunge.imageNames[1]])
    static let shoulderMobility = PositionBlock(title: PositionImgs.shoulderMobility.0,
                                                imageName: [PositionImgs.shoulderMobility.imageNames[0], PositionImgs.shoulderMobility.imageNames[1]])
    static let straightLegRaise = PositionBlock(title: PositionImgs.straightLegRaise.0,
                                                imageName: [PositionImgs.straightLegRaise.imageNames[0], PositionImgs.straightLegRaise.imageNames[1]])
    static let stabilityPushup = PositionBlock(title: PositionImgs.stabilityPushup.0,
                                               imageName: [PositionImgs.stabilityPushup.imageNames[0]])
    static let rotaryStability = PositionBlock(title: PositionImgs.rotaryStability.0,
                                               imageName:[PositionImgs.rotaryStability.imageNames[0], PositionImgs.rotaryStability.imageNames[1]])
    static let shoulder = PositionBlock(title: PositionImgs.shoulder.0,
                                        imageName: [PositionImgs.shoulder.imageNames[0], PositionImgs.shoulder.imageNames[1]])
    static let extensions = PositionBlock(title: PositionImgs.extensions.0, imageName: [PositionImgs.extensions.imageNames[0]])
    static let flexion = PositionBlock(title: PositionImgs.flexion.0, imageName: [PositionImgs.flexion.imageNames[0]])
}



