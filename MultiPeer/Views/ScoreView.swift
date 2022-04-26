//
//  ScoreView.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/25.
//

import UIKit
import SnapKit

class ScoreView: UILabel {
    var score: Int? {
        didSet {
            self.loadView()
        }
    }
    init( score: Int? = nil, frame: CGRect = .zero) {
        self.score = score
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
        
        scoreLabel.text = "\(score)"
        
        if let validScore = score {
            scoreLabel.text = String(validScore)
        } else {
            scoreLabel.text = ""
        }
        
//        self.layer.borderColor = UIColor.magenta.cgColor
//        self.layer.borderWidth = 1
//        self.layer.cornerRadius = 10
        
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
