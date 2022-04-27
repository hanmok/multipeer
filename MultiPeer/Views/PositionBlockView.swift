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
///





class PositionBlockView: UIView {
    
    var positionBlock: Position {
        didSet {
            DispatchQueue.main.async {
                self.loadView()
            }
        }
    }
    
    let imageView1 = UIImageView().then{ $0.isUserInteractionEnabled = true
        $0.backgroundColor = .blue
    }
    
    let imageView2 = UIImageView().then { $0.isUserInteractionEnabled = true
        $0.backgroundColor = .orange
    }
    
//    var imgBtnLeft: ButtonWithInfo = ButtonWithInfo(title: "", direction: .neutral)
//    var imgBtnRight: ButtonWithInfo = ButtonWithInfo(title: "", direction: .neutral)
    
    var imgBtnLeft = ImgBtnView(title: "", direction: .neutral)
    var imgBtnRight = ImgBtnView(title: "", direction: .neutral)
    
    var scoreView1 = ScoreBtnView().then { $0.tag = 0}
    var scoreView2 = ScoreBtnView().then { $0.tag = 1}
    
    let nameLabel = UILabel()
    
    init(_ positionBlock: Position, frame: CGRect = .zero) {
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
            
            scoreView1 = ScoreBtnView(title: positionBlock.title,direction: .left, score: positionBlock.score[0]).then { $0.tag =  0}
            scoreView2 = ScoreBtnView(title: positionBlock.title, direction: .right, score: positionBlock.score[1]).then { $0.tag = 1}
            
            let imageStackView = UIStackView(arrangedSubviews: [imageView1, imageView2])
            self.addSubview(imageStackView)
            
            
            imageStackView.distribution = .fillEqually
            imageStackView.spacing = 10
            
            imageStackView.snp.makeConstraints { make in
                make.left.top.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.equalToSuperview().dividedBy(2)
            }
            
            //            dummyBtnLeft
//            imgBtnLeft = ButtonWithInfo(title: positionBlock.title, direction: .left)
            imgBtnLeft = ImgBtnView(title: positionBlock.title, direction: .left)
            imageView1.addSubview(imgBtnLeft)
            imgBtnLeft.snp.makeConstraints { make in
                make.leading.top.trailing.bottom.equalToSuperview()
            }
            
//            imgBtnRight = ButtonWithInfo(title: positionBlock.title, direction: .right)
            imgBtnRight = ImgBtnView(title: positionBlock.title, direction: .right)
            imageView2.addSubview(imgBtnRight)
            imgBtnRight.snp.makeConstraints { make in
                make.leading.top.trailing.bottom.equalToSuperview()
            }
            
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
                            scoreView1]
            
            allViews.forEach { view in
                self.addSubview(view)
            }
            
            imageView1.image = UIImage(imageLiteralResourceName: positionBlock.imageName[0])
            imageView1.snp.makeConstraints { make in
                make.left.top.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.equalToSuperview().dividedBy(2)
            }
//            imgBtnLeft = ButtonWithInfo(title: positionBlock.title, direction: .neutral)
            imgBtnLeft = ImgBtnView(title: positionBlock.title, direction: .neutral)
            imageView1.addSubview(imgBtnLeft)
            imgBtnLeft.snp.makeConstraints { make in
                make.leading.top.trailing.bottom.equalToSuperview()
            }
            
            scoreView1 = ScoreBtnView(title: positionBlock.title, direction: .neutral, score: positionBlock.score[0]).then { $0.tag = 0}
            
            addSubview(scoreView1)
            scoreView1.snp.makeConstraints { make in
                make.top.equalTo(imageView1.snp.bottom)
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.equalTo(50)
            }
            
            self.addSubview(scoreView2)
            self.addSubview(imageView2)
            scoreView2.isHidden = true
            imageView2.isHidden = true
            
            scoreView2.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.height.width.equalToSuperview()
            }
            
            imageView2.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.height.width.equalToSuperview()
            }
        }
    }
}
