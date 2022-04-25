//
//  PositionSelectingController.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/25.
//

import UIKit
import SnapKit
import Then


struct PositionBlock {
    var imageName: [String]
    var score: [Int] = []
    var title: String
    let leftRight: Bool = false
}





public enum PositionImgs: CaseIterable {
    static let deepSquat = (title: "deepSquat", imageNames: ["deepSquat"])
    static let extensions = (title: "extensions", imageNames: ["extensions"])
    static let flexion = (title: "flexion", imageNames: ["flexion"])
    
    static let hurdleStep = (title: "hurdleStep", imageNames: ["hurdleStepLeft", "hurdleStepRight"])
    static let inlineLunge = (title: "inlineLunge", imageNames: ["inlineLungeLeft","inlineLungeRight" ])
    static let rotartStability = (title: "rotartStability", imageNames: ["rotartStabilityLeft","rotaryStabilityRight"])
    static let shoulder = (title: "shoulder", imageNames: ["shoulderLeft", "shoulderRight"])
    static let shoulderMobility = (title: "shoulderMobility", imageNames: ["shoulderMobilityLeft", "shoulderMobilityRight"])
    
    static let stabilityPushup = (title: "stabilityPushup", imageNames: ["stabilityPushup"])
    
    static let straightLegRaise = (title: "straightLegRaise", imageNames: ["straightLegRaiseLeft", "straightLegRaiseRight"])
}


class PositionSelectingController: UIViewController {
    

    
    public var positionList: [PositionBlock] = [
        PositionBlock(imageName: [PositionImgs.deepSquat.imageNames[0]], title: PositionImgs.deepSquat.0),
        PositionBlock(imageName: [PositionImgs.hurdleStep.imageNames[0], PositionImgs.hurdleStep.imageNames[1]], title: PositionImgs.deepSquat.0),
        PositionBlock(imageName: [PositionImgs.inlineLunge.imageNames[0],PositionImgs.inlineLunge.imageNames[1]], title: PositionImgs.inlineLunge.0),
        PositionBlock(imageName: [PositionImgs.shoulderMobility.imageNames[0], PositionImgs.shoulderMobility.imageNames[1]], title: PositionImgs.shoulderMobility.0),
        
        PositionBlock(imageName: [PositionImgs.straightLegRaise.imageNames[0], PositionImgs.straightLegRaise.imageNames[1]], title: PositionImgs.straightLegRaise.0),
        PositionBlock(imageName: [PositionImgs.stabilityPushup.imageNames[0], PositionImgs.stabilityPushup.imageNames[1]], title: PositionImgs.stabilityPushup.0),
        PositionBlock(imageName: [PositionImgs.rotartStability.imageNames[0], PositionImgs.rotartStability.imageNames[1]], title: PositionImgs.rotartStability.0),
        
        PositionBlock(imageName: [PositionImgs.shoulder.imageNames[0], PositionImgs.shoulder.imageNames[1]], title: PositionImgs.shoulder.0),
        PositionBlock(imageName: [PositionImgs.extensions.imageNames[0]], title: PositionImgs.extensions.0),
        PositionBlock(imageName: [PositionImgs.flexion.imageNames[0]], title: PositionImgs.flexion.0)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
//    private var squatView = PositionBlockView(PositionBlock(imageName: ["deepSquat"], score: <#T##[Int]#>, title: <#T##String#>))
    
}


let positions: [PositionBlock] = [PositionBlock(imageName: ["deepSquat"], title: "deepSquat")]
