//
//  ScoreView.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/25.
//

import UIKit
import SnapKit


enum PositionDirection {
    case left
    case right
    case none // represent 'Center' or 'Neutral'
}

// has no idea for direction
class ScoreView: UILabel {
    var score: Int? {
        didSet {
            self.loadView()
        }
    }
    
    var direction: PositionDirection
    
    
    init(direction: PositionDirection = .none, score: Int? = nil, frame: CGRect = .zero) {
        self.score = score
        self.direction = direction
        super.init(frame: frame)
//        self.backgroundColor = .magenta
        loadView()
    }
    
    private func loadView() {
        print("started load scoreView")
        self.addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
            make.height.equalToSuperview().dividedBy(2)
        }
        
//        scoreLabel.text = "\(score)"
        
        if let validScore = score {
            scoreLabel.text = String(validScore)
        } else {
            switch direction {
            case .right: scoreLabel.text = "R"
            case .left: scoreLabel.text = "L"
            case .none: scoreLabel.text = "N"
            }
        }
        
        print("successfully loaded scoreView")
    }
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
