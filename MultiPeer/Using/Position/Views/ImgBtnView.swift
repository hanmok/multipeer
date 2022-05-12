//
//  ImgBtnView.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/28.
//

import UIKit

// title, direction, score
class ImgBtnView: ButtonWithInfo {
    
    override init(title: String = "", direction: PositionDirection = .neutral, score: Int? = nil, frame: CGRect = .zero) {
        super.init(title: title, direction: direction, score: score, frame: frame)
        
        self.addTarget(nil, action: #selector(PositionController.imgTapped(_:)), for: .touchUpInside)
//        loadView()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


