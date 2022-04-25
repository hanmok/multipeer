//
//  ScoreView.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/25.
//

import UIKit
import SnapKit

class ScoreView: UILabel {
    var score: Int {
        didSet {
            self.loadView()
        }
    }
    init( score: Int = 0, frame: CGRect = .zero) {
        self.score = score
        super.init(frame: frame)
        self.backgroundColor = .magenta
    }
    
    private func loadView() {
        self.addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
            make.height.equalToSuperview().dividedBy(2)
        }
        
        scoreLabel.text = "\(score)"
        
        self.layer.borderColor = UIColor.magenta.cgColor
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
