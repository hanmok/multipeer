//
//  ScoreView.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/25.
//

import UIKit
import SnapKit



// has no idea for direction
class ScoreBtnView: ButtonWithInfo {
    
    override init(title: String = "", direction: PositionDirection = .neutral, score: Int? = nil, frame: CGRect = .zero) {
        super.init(title: title, direction: direction, score: score, frame: frame)
        let anotherSelf = self as! ButtonWithInfo
        
        self.addTarget(nil, action: #selector(PositionSelectingController.scoreTapped(_:)), for: .touchUpInside)
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
        
        
        if let validScore = score {
            scoreLabel.text = String(validScore)
        } else {
            switch direction {
            case .right: scoreLabel.text = "R"
            case .left: scoreLabel.text = "L"
            case .neutral: scoreLabel.text = "N"
            }
        }
        scoreLabel.textAlignment = .center
        
        self.layer.borderColor = UIColor.blue.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 20
        
    }
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ImgBtnView: ButtonWithInfo {
    
    override init(title: String = "", direction: PositionDirection = .neutral, score: Int? = nil, frame: CGRect = .zero) {
        super.init(title: title, direction: direction, score: score, frame: frame)
//        let anotherSelf = self as! ButtonWithInfo
        
        self.addTarget(nil, action: #selector(PositionSelectingController.imgTapped(_:)), for: .touchUpInside)
//        loadView()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ButtonWithInfo: UIButton {
    var title: String
    var direction: PositionDirection
    var score: Int? // could be nil if not proceed yet.
    
    init( title: String, direction: PositionDirection, score: Int? = nil, frame: CGRect = .zero) {
        self.title = title
        self.direction = direction
        self.score = score
        super.init(frame: frame)
        
        self.addTarget(nil, action: #selector(PositionSelectingController.imgTapped(_:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
