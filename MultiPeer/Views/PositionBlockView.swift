//
//  PositionBlockView.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/25.
//

import UIKit
import SnapKit
import Then

/// implement tap gesture recognizer to be button
class PositionBlockView: UIView {
    
    var positionBlock: PositionBlock {
        didSet {
            DispatchQueue.main.async {
                self.loadView()
            }
        }
    }
    

    let imageView1 : UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    let imageView2 : UIImageView = {
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    var scoreView1 = ScoreView()

    var scoreView2 = ScoreView()
    
    let nameLabel = UILabel()
    
    init(_ positionBlock: PositionBlock, frame: CGRect = .zero) {
        self.positionBlock = positionBlock
        super.init(frame: frame)
//        loadView()
        self.backgroundColor = .magenta
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadView() {
        if positionBlock.leftRight {
            
            let imageStackView = UIStackView(arrangedSubviews: [imageView1, imageView2])
            imageStackView.distribution = .fillEqually
            imageStackView.spacing = 10
            
            imageStackView.snp.makeConstraints { make in
                make.left.top.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.equalToSuperview().dividedBy(2)
            }
            
            self.addSubview(imageStackView)
            
            scoreView1 = ScoreView(score: positionBlock.score[0])
            scoreView2 = ScoreView(score: positionBlock.score[1])
            
            let scoreStackView = UIStackView(arrangedSubviews: [scoreView1, scoreView2])
            scoreStackView.distribution = .fillEqually
            scoreStackView.spacing = 10
            
            scoreStackView.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.equalTo(50)
            }
            
            self.addSubview(scoreStackView)
            
            self.addSubview(nameLabel)
            nameLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(scoreStackView.snp.bottom).offset(10)
                make.width.equalToSuperview()
                make.bottom.equalTo(self.snp.bottom).offset(-10)
            }

        } else {
            let allViews = [imageView1, scoreView1, nameLabel]
            allViews.forEach { view in
                self.addSubview(view)
            }
            
            imageView1.snp.makeConstraints { make in
                make.left.top.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.equalToSuperview().dividedBy(2)
            }
            
            scoreView1.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.equalTo(50)
            }
            
            nameLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(scoreView1.snp.bottom).offset(10)
                make.width.equalToSuperview()
                make.bottom.equalTo(self.snp.bottom).offset(-10)
            }
        }
    }
}
