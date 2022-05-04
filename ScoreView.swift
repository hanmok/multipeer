//
//  ScoreView.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/04.
//

import UIKit
import Then


class ScoreButton: UIButton {
    public var wrappedScoreString: String {
        didSet {
            setupLayout()
        }
    }
    
    init(_ score: String = "") {
        self.wrappedScoreString = score
        super.init(frame: .zero)
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        
    }
    
    private func setupLayout() {
        self.setTitle(wrappedScoreString, for: .normal)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

