//
//  ScoreView.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/25.
//

import UIKit
import SnapKit



// title, direction, Score
class ScoreBtnView: ButtonWithInfo {
    
    override init(title: String = "", direction: PositionDirection = .neutral, score: Int? = nil, frame: CGRect = .zero) {
        super.init(title: title, direction: direction, score: score, frame: frame)
        
        self.addTarget(nil, action: #selector(PositionController.scoreTapped(_:)), for: .touchUpInside)
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
        
        
        if let validScore = positionDirectionScoreInfo.score {
            scoreLabel.text = String(validScore)
            print("validScore : \(validScore)")
        } else {
            switch positionDirectionScoreInfo.direction {
            case .right: scoreLabel.text = "R"
            case .left: scoreLabel.text = "L"
            case .neutral: scoreLabel.text = "N"
            }
            print("direction: \(positionDirectionScoreInfo.direction)")
        }
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = .magenta
        
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
    }
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



