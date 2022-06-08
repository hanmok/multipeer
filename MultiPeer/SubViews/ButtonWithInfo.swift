//
//  ButtonWithInfo.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/28.
//

import UIKit

class ButtonWithInfo: UIButton {
//    var title: String
//    var direction: PositionDirection
//    var score: Int? // could be nil if not proceed yet.
    
    var movementDirectionScoreInfo: MovementDirectionScoreInfo
    
    init( title: String, direction: MovementDirection, score: Int? = nil, frame: CGRect = .zero) {
//        self.title = title
//        self.direction = direction
//        self.score = score
        movementDirectionScoreInfo = MovementDirectionScoreInfo(title: title, direction: direction, score: score)
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
