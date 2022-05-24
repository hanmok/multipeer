//
//  PositionBlockView.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/25.
//

import UIKit
import SnapKit
import Then


class PositionBlockView: UIView {
    
    var positionBlock: PositionInfo {
        didSet {
            DispatchQueue.main.async {
                self.loadView()
            }
        }
    }
    
    let imageView1 = UIImageView().then{
        $0.isUserInteractionEnabled = true
    }
    
    let imageView2 = UIImageView().then {
        $0.isUserInteractionEnabled = true
    }
    
    var imgBtnLeft = ImgBtnView(title: "", direction: .neutral)
    var imgBtnRight = ImgBtnView(title: "", direction: .neutral)
    
    public var scoreView1 = ScoreBtnView()
    public var scoreView2 = ScoreBtnView()
    
    let nameLabel = UILabel()
    
    init(_ positionBlock: PositionInfo, frame: CGRect = .zero) {
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
            print("imageName[0]: \(positionBlock.imageName[0])")
            print("imageName[1]: \(positionBlock.imageName[1])")
            
//            if positionBlock.imageName[0] != PositionWithImageListEnum.ankleClearing.imageName[0] {
                
            imageView1.image = UIImage(imageLiteralResourceName: positionBlock.imageName[0])
            imageView2.image = UIImage(imageLiteralResourceName: positionBlock.imageName[1])
            
//            }
            
            scoreView1 = ScoreBtnView(title: positionBlock.title, direction: .left, score: positionBlock.score[0]) // what does this tag do ?
            scoreView2 = ScoreBtnView(title: positionBlock.title, direction: .right, score: positionBlock.score[1])
            
            let imageStackView = UIStackView(arrangedSubviews: [imageView1, imageView2])
            self.addSubview(imageStackView)
            
            imageStackView.distribution = .fillEqually
            imageStackView.spacing = 10
            
            imageStackView.snp.makeConstraints { make in
                make.left.top.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.equalToSuperview().dividedBy(2)
            }

            imgBtnLeft = ImgBtnView(title: positionBlock.title, direction: .left)
            imageView1.addSubview(imgBtnLeft)
            imgBtnLeft.snp.makeConstraints { make in
                make.leading.top.trailing.bottom.equalToSuperview()
            } 
            
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
//                make.height.equalTo(50)
                make.bottom.equalTo(nameLabel.snp.top)
            }
            
            // one Image
        } else {
            let allViews = [imageView1,
                            scoreView1]
            
            allViews.forEach { view in
                self.addSubview(view)
            }
            
            print("imageName: \(positionBlock.imageName[0])")
            imageView1.image = UIImage(imageLiteralResourceName: positionBlock.imageName[0])
            imageView1.snp.makeConstraints { make in
                make.left.top.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.equalToSuperview().dividedBy(2)
            }

            imgBtnLeft = ImgBtnView(title: positionBlock.title, direction: .neutral)
            imageView1.addSubview(imgBtnLeft)
            imgBtnLeft.snp.makeConstraints { make in
                make.leading.top.trailing.bottom.equalToSuperview()
            }
            
            scoreView1 = ScoreBtnView(title: positionBlock.title, direction: .neutral, score: positionBlock.score[0])
            
            addSubview(scoreView1)
            scoreView1.snp.makeConstraints { make in
                make.top.equalTo(imageView1.snp.bottom)
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.bottom.equalTo(nameLabel.snp.top)
            }
            
            self.addSubview(scoreView2)
            self.addSubview(imageView2)
            scoreView2.isHidden = true
            imageView2.isHidden = true
            
            // 이것들 반드시 필요함..?
            scoreView2.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.height.width.equalToSuperview()
            }
            
            imageView2.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.height.width.equalToSuperview()
            }
        }
        
////        if positionBlock.title == PositionList.
//        switch positionBlock.title {
////        case PositionList.ankleClearing.rawValue: fallthrough
//        case PositionList.flexionClearing.rawValue: fallthrough
//        case PositionList.shoulderClearing.rawValue: fallthrough
//        case PositionList.extensionClearing.rawValue:
//            imgBtnLeft.isUserInteractionEnabled = false
//            imgBtnRight.isUserInteractionEnabled = false
//        default:
//            break
//        }
        
        switch positionBlock.title {
        case PositionList.flexionClearing.rawValue,
            PositionList.shoulderClearing.rawValue,
            PositionList.extensionClearing.rawValue:
            imgBtnLeft.isUserInteractionEnabled = false
            imgBtnRight.isUserInteractionEnabled = false
        default:
            break
        }
    }
}
