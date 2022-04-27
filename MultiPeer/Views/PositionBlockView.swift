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
        loadView()
        self.backgroundColor = .white
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadView() {
        // two images
        imageView1.contentMode = .scaleAspectFit
        imageView2.contentMode = .scaleAspectFit

        nameLabel.textColor = .black
        nameLabel.textAlignment = .center
        nameLabel.text = positionBlock.title
        nameLabel.numberOfLines = 0

        self.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()

            make.height.equalTo(60)

            make.width.equalToSuperview().inset(10)
            make.bottom.equalTo(self.snp.bottom)
        }
        
        if positionBlock.leftRight {
            imageView1.image = UIImage(imageLiteralResourceName: positionBlock.imageName[0])
            imageView2.image = UIImage(imageLiteralResourceName: positionBlock.imageName[1])
            
            scoreView1 = ScoreView(direction: .left, score: positionBlock.score[0])
            scoreView2 = ScoreView(direction: .right, score: positionBlock.score[1])
            
            let imageStackView = UIStackView(arrangedSubviews: [imageView1, imageView2])
            self.addSubview(imageStackView)

            
            imageStackView.distribution = .fillEqually
            imageStackView.spacing = 10
            
            imageStackView.snp.makeConstraints { make in
                make.left.top.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.equalToSuperview().dividedBy(2)
            }

//            if positionBlock.score.count == 2 {
//                scoreView2 = ScoreView(direction: .right, score: positionBlock.score[1])
//            }


            let scoreStackView = UIStackView(arrangedSubviews: [scoreView1, scoreView2])

            scoreStackView.distribution = .fillEqually
            scoreStackView.spacing = 10
            
            self.addSubview(scoreStackView)
            scoreStackView.snp.makeConstraints { make in
                make.top.equalTo(imageStackView.snp.bottom)
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.equalTo(50)
            }

            // one Image
        } else {
            let allViews = [imageView1,
                            scoreView1
            ]
                    
            allViews.forEach { view in
                self.addSubview(view)
            }

            imageView1.image = UIImage(imageLiteralResourceName: positionBlock.imageName[0])
            imageView1.snp.makeConstraints { make in
                make.left.top.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.equalToSuperview().dividedBy(2)
            }

            scoreView1 = ScoreView(direction: .neutral, score: positionBlock.score[0])
            // This line ??
            
            print("bbb")
            addSubview(scoreView1)
            scoreView1.snp.makeConstraints { make in
                make.top.equalTo(imageView1.snp.bottom)
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
//                make.left.equalTo(self.snp.left)
//                make.right.equalTo(self.snp.right)
                make.height.equalTo(50)
            }
            print("cccc")
            // umm ..
            print("flag12")
            // 여기서 막히는것 같은ㄷ ㅔ??
            
            self.addSubview(scoreView2)
            print("flag13")
            self.addSubview(imageView2)
            scoreView2.isHidden = true
            imageView2.isHidden = true
            print("hi")
            scoreView2.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.height.width.equalToSuperview()
            }
            print("bye")
            imageView2.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.height.width.equalToSuperview()
            }
            print("hi2")
            print("one pose ended")
        }
        print("successfully loaded positionBlockView")
    }
}
