//
//  PositionCollectionCell.swift
//  MultiPeer
//
//  Created by 핏투비 on 2022/05/30.
//

import Foundation
import UIKit
import SnapKit
import Then

class PositionCollectionCell: UICollectionViewCell {
    static let cellId = "cellId"
    
    var viewModel: PositionViewModel? {
        didSet {
            loadView()
            
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
    
    
    public var scoreView1 = UILabel().then { $0.textAlignment = .center
        $0.backgroundColor = UIColor(red: 71 / 255,  green: 69 / 255, blue: 78 / 255, alpha: 1)
        $0.textColor = .white
        $0.layer.cornerRadius = 4
    }
    
    public var scoreView2 = UILabel().then { $0.textAlignment = .center
        $0.backgroundColor = UIColor(red: 71 / 255,  green: 69 / 255, blue: 78 / 255, alpha: 1)
        $0.textColor = .white
        $0.layer.cornerRadius = 4
    }
    
    private let bottomLineView = UIView().then {
        $0.backgroundColor = UIColor(red: 227/255, green: 42/255, blue: 47/255, alpha: 1)
    }
    
    let nameLabel = UILabel()
    
    private let scoreContainerView1 = UIView()
//        .then { $0.backgroundColor = .magenta }
    private let scoreContainerView2 = UIView()
//        .then { $0.backgroundColor = .cyan }
    
    
    private func trueIfDone(_ str: String) -> Bool {
        if Character(str).asciiValue! > 90 || Character(str).asciiValue! < 65 {
            return true
        }
        return false
    }
    
    private func loadView() {
        // two images
        guard let vm = viewModel else {fatalError()}
        imageView1.contentMode = .scaleAspectFit
        imageView2.contentMode = .scaleAspectFit
        
        nameLabel.textColor = .black
        nameLabel.textAlignment = .center
        nameLabel.text = vm.title
        nameLabel.numberOfLines = 0
        
        nameLabel.text = vm.shortTitleLabel
        
        
        self.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalToSuperview().inset(10)
            make.bottom.equalTo(self.snp.bottom).inset(10)
        }
        
        // Has Left and Right
        if vm.imageName.count == 2 {
            
            imageView1.image = UIImage(imageLiteralResourceName: vm.imageName[0])
            imageView2.image = UIImage(imageLiteralResourceName: vm.imageName[1])
            
            scoreView1.text = vm.scoreLabel[0]
            scoreView2.text = vm.scoreLabel[1]


            if trueIfDone(vm.scoreLabel[0]) {
                scoreView1.backgroundColor = UIColor(red: 201 / 255, green: 196 / 255, blue: 229 / 255, alpha: 1)
            }
            
            if trueIfDone(vm.scoreLabel[1]) {
                scoreView2.backgroundColor = UIColor(red: 201 / 255, green: 196 / 255, blue: 229 / 255, alpha: 1)
            }
            
            if trueIfDone(vm.scoreLabel[0]) && trueIfDone(vm.scoreLabel[1]) {
                layer.borderColor = UIColor(red: 201 / 255, green: 196 / 255, blue: 229 / 255, alpha: 1).cgColor
            }
            
            let imageStackView = UIStackView(arrangedSubviews: [imageView1, imageView2])
            self.addSubview(imageStackView)
            
            imageStackView.distribution = .fillEqually
            imageStackView.spacing = 10
            
            imageStackView.snp.makeConstraints { make in
                make.left.top.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.equalToSuperview().dividedBy(2)
            }

            imgBtnLeft = ImgBtnView(title: vm.title, direction: .left)
            imageView1.addSubview(imgBtnLeft)
            imgBtnLeft.snp.makeConstraints { make in
                make.leading.top.trailing.bottom.equalToSuperview()
            }
            
            imgBtnRight = ImgBtnView(title: vm.title, direction: .right)
            imageView2.addSubview(imgBtnRight)
            imgBtnRight.snp.makeConstraints { make in
                make.leading.top.trailing.bottom.equalToSuperview()
            }
            
//            let scoreStackView = UIStackView(arrangedSubviews: [scoreView1, scoreView2])
            let scoreStackView = UIStackView(arrangedSubviews: [scoreContainerView1, scoreContainerView2])
            
            scoreStackView.distribution = .fillEqually
            scoreStackView.spacing = 10
            
            self.addSubview(scoreStackView)
            scoreStackView.snp.makeConstraints { make in
                make.top.equalTo(imageStackView.snp.bottom).offset(10)
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
//                make.height.equalTo(50)
                make.bottom.equalTo(nameLabel.snp.top)
            }
            
            scoreContainerView1.addSubview(scoreView1)
            scoreView1.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(20)
            }
            
            scoreContainerView2.addSubview(scoreView2)
            scoreView2.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(20)
            }
            

            
            // one Image
        } else {
            let allViews = [imageView1,
                            scoreContainerView1]
            
            allViews.forEach { view in
                self.addSubview(view)
            }
            
            print("imageName: \(vm.imageName[0])")
            imageView1.image = UIImage(imageLiteralResourceName: vm.imageName[0])
            imageView1.snp.makeConstraints { make in
//                make.left.top.equalToSuperview().offset(10)
//                make.right.equalToSuperview().offset(-10)
//                make.height.equalToSuperview().dividedBy(2)
//                make.left.top.equalToSuperview().offset(10)
//                make.right.equalToSuperview().offset(-10)
////                make.height.equalToSuperview().dividedBy(2)
//                make.height.equalTo(60)
                make.left.top.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.equalToSuperview().dividedBy(2)
            }

            imgBtnLeft = ImgBtnView(title: vm.title, direction: .neutral)
            
            imageView1.addSubview(imgBtnLeft)
            imgBtnLeft.snp.makeConstraints { make in
                make.leading.top.trailing.bottom.equalToSuperview()
            }
            
            scoreView1.text = vm.scoreLabel[0]
            
            
            addSubview(scoreContainerView1)
            scoreContainerView1.snp.makeConstraints { make in
                make.top.equalTo(imageView1.snp.bottom).offset(10)
                make.leading.trailing.equalToSuperview().inset(10)
                make.bottom.equalTo(nameLabel.snp.top)
            }
            
            scoreContainerView1.addSubview(scoreView1)
            scoreView1.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(20)
            }
            
//            self.addSubview(scoreStackView)
//            scoreStackView.snp.makeConstraints { make in
//                make.top.equalTo(imageStackView.snp.bottom).offset(10)
//                make.left.equalToSuperview().offset(10)
//                make.right.equalToSuperview().offset(-10)
////                make.height.equalTo(50)
//                make.bottom.equalTo(nameLabel.snp.top)
//            }
            
//            self.addSubview(scoreView2)
//            self.addSubview(scoreContainerView2)
            self.addSubview(imageView2)
//            scoreView2.isHidden = true
            scoreContainerView2.isHidden = true
            imageView2.isHidden = true
            
            // 이것들 반드시 필요함..?
//            scoreView2.snp.makeConstraints { make in
//            scoreContainerView2.snp.makeConstraints { make in
//                make.center.equalToSuperview()
//                make.height.width.equalToSuperview()
//            }
            
            imageView2.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.height.width.equalToSuperview()
            }
        }
        
        addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2.5)
            make.height.equalTo(2)
        }
        

//        scoreContainerView1.addSubview(scoreView1)
//        scoreContainerView1.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//            make.height.width.equalTo(20)
//        }
        
//        scoreContainerView2.addSubview(scoreView2)
//        scoreContainerView2.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//            make.height.width.equalTo(20)
//        }
        
        switch vm.title {
        case PositionList.flexionClearing.rawValue,
            PositionList.shoulderClearing.rawValue,
            PositionList.extensionClearing.rawValue:
            imgBtnLeft.isUserInteractionEnabled = false
            imgBtnRight.isUserInteractionEnabled = false
        default:
            break
        }
    }
    
    
    private func configureLayout() {
        
    }
    
    private func setupLayout() {

    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupLayout()
//        backgroundColor = .green
        backgroundColor = .white
        
//        layer.borderWidth = 1
        layer.cornerRadius = 16
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
