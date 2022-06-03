//
//  movementCollectionCell.swift
//  MultiPeer
//
//  Created by 핏투비 on 2022/05/30.
//

import Foundation
import UIKit
import SnapKit
import Then

protocol MovementCellDelegate: AnyObject {
    func cell(navToCameraWith trialCore: TrialCore)
}

class MovementCell: UICollectionViewCell {
    static let cellId = "cellId"
    
    var viewModel: MovementViewModel? { // viewmodel get trialCores (one or two)
        didSet {
            loadView()
            assignTrialCore()
            addTargets()
            printReceivedData()
        }
    }
    
    weak var delegate: MovementCellDelegate?
    
    private func assignTrialCore() {
        guard let viewModel = viewModel else {
            return
        }
        let trialCores = viewModel.trialCore

        if trialCores.count == 1 {
            imgBtnLeft.trialCore = trialCores.first!
        } else if trialCores.count == 2 {
            imgBtnLeft.trialCore = trialCores.first!
            imgBtnRight.trialCore = trialCores.last!
        }
    }
    
    private func addTargets() {
        guard let viewModel = viewModel else {
            fatalError()
        }
        
        imgBtnLeft.addTarget(self, action: #selector(imgBtnTapped(_:))  , for: .touchUpInside)
        imgBtnRight.addTarget(self, action: #selector(imgBtnTapped(_:))  , for: .touchUpInside)
    }
    
//    private func changeColor(when condition: Bool, closure: () -> Void ) {
//        if condition {
//            closure()
////            targetView.backgroundColor = UIColor.purple500
//        }
//    }
    
    @objc func imgBtnTapped(_ sender: ButtonWIthTrialCore) {

        
        guard let vm = viewModel else { return }
        
        // TODO: Implement Blink Animation
        //        sender.blink()
        
//        if vm.trialCore.count == 2 {
//            UIView.animate(withDuration: 0.4) {
//                self.scoreView1.backgroundColor = .white
//                self.scoreView2.backgroundColor = .white
//                self.nameLabel.textColor = .white
//                self.backgroundColor = UIColor.lavenderGray900
//            } completion: { done in
//                if done {
//                    UIView.animate(withDuration: 0.4) {
//
//                        self.nameLabel.textColor = .black
//                        self.backgroundColor = UIColor.clear
//                    }
//                }
//            }
//        } else {
//
//        }
        
        print("triggerBtnTapped!")
        guard let sentTrialCore = sender.trialCore else {fatalError()}
        delegate?.cell(navToCameraWith: sentTrialCore)
    }
    
    let imageView1 = UIImageView().then{
        $0.isUserInteractionEnabled = true
        $0.backgroundColor = .white
    }
    
    let imageView2 = UIImageView().then {
        $0.isUserInteractionEnabled = true
        $0.backgroundColor = .white
    }
    

    var imgBtnLeft = ButtonWIthTrialCore()
    var imgBtnRight = ButtonWIthTrialCore()
    
    var scoreViewDefaultColor = UIColor.white
    
    public var scoreView1 = UILabel().then { $0.textAlignment = .center
        $0.textColor = .white
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    
    public var scoreView2 = UILabel().then { $0.textAlignment = .center
        $0.textColor = .white
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }

    private let bottomLineView = UIView().then {
        $0.backgroundColor = .red500
    }
    
    let nameLabel = UILabel()
    
    private let scoreContainerView1 = UIView()

    private let scoreContainerView2 = UIView()
    

    
    private func trueIfDone(_ str: String) -> Bool {
        print("ankle Clearing Test bug fetching received str from trueIfDone: \(str)")
        
        if str == "Yellow" || str == "Green" || str == "Red" {
            return true
        }
        
        if str.count != 1 { return false }
        guard let asciiOfChar = Character(str).asciiValue else { fatalError("passed str2: \(str)") }

        // if not alphabet -> true
        if asciiOfChar > 90 || asciiOfChar < 65 {
            return true
        }

        return false
    }
    
    //TODO: Fix) 왜 이거 두번 호출됨? cell 잘못 아님. Controller 쪽으로 넘어가야함.
    // FIXME: separate into two Funcs (configureLayout, setupLayout)
    // But.. Two funcs rely on ViewModel.
    // then.. How ?
    
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
        
        print("ankle Clearing Test bug fetching title: \(vm.title)")
        // Has Left and Right
        if vm.imageName.count == 2 {
            print("two images are rendered for title: \(vm.title)")
            
            imageView1.image = UIImage(imageLiteralResourceName: vm.imageName[0])
            imageView2.image = UIImage(imageLiteralResourceName: vm.imageName[1])

            scoreView1.text = String(vm.scoreLabel[0].first!)
            scoreView2.text = String(vm.scoreLabel[1].first!)
                        
            
            if trueIfDone(vm.scoreLabel[0]) {
                scoreView1.backgroundColor = UIColor.purple500
            } else {
                scoreView1.backgroundColor = UIColor.lavenderGray900
            }
            
            if trueIfDone(vm.scoreLabel[1]) {
                scoreView2.backgroundColor = UIColor.purple500
            } else {
                scoreView2.backgroundColor = UIColor.lavenderGray900
            }

            if trueIfDone(vm.scoreLabel[0]) && trueIfDone(vm.scoreLabel[1]) {
                layer.borderColor = UIColor.purple300.cgColor
                layer.borderWidth = 1
            } else {
                layer.borderColor = UIColor.clear.cgColor
                layer.borderWidth = 0
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

            imageView1.addSubview(imgBtnLeft)
            imgBtnLeft.snp.makeConstraints { make in
                make.leading.top.trailing.bottom.equalToSuperview()
            }
            
            imageView2.addSubview(imgBtnRight)
            imgBtnRight.snp.makeConstraints { make in
                make.leading.top.trailing.bottom.equalToSuperview()
            }
            

            let scoreStackView = UIStackView(
                arrangedSubviews: [scoreContainerView1, scoreContainerView2])
            
            scoreStackView.distribution = .fillEqually
            scoreStackView.spacing = 10
            
            self.addSubview(scoreStackView)
            scoreStackView.snp.makeConstraints { make in
                make.top.equalTo(imageStackView.snp.bottom).offset(10)
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
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
        } else if vm.imageName.count == 1 {
            
            let allViews = [imageView1,
                            scoreContainerView1]
            
            allViews.forEach { view in
                self.addSubview(view)
            }
            
            imageView1.image = UIImage(imageLiteralResourceName: vm.imageName[0])
            
            if trueIfDone(vm.scoreLabel[0]) {
                scoreView1.backgroundColor = UIColor.purple500
                layer.borderColor = UIColor.purple300.cgColor
                layer.borderWidth = 1
            } else {
                scoreView1.backgroundColor = UIColor.lavenderGray900
                layer.borderColor = UIColor.clear.cgColor
                layer.borderWidth = 0
            }
            
            imageView1.snp.makeConstraints { make in
                make.left.top.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.equalToSuperview().dividedBy(2)
            }
            
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
        }

        addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2.5)
            make.height.equalTo(2)
        }
    }
    
    private func configureLayout() {
        
    }
    
    private func setupLayout() {

    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupLayout()

        backgroundColor = .white // 아니 ㅅㅂ...옆에 찌꺼기 뭐야 ??  일단 pass..
        
        layer.cornerRadius = 16
        
    }
    
    private func printReceivedData() {
        
        guard let viewModel = viewModel else { fatalError() } // 왜 이 점수가 아니지 ?
        print("numOfTrialCore: \(viewModel.trialCore.count)") // 점수 안나옴 . 어디서 나오는거지.. ?
        print("trial title: \(viewModel.trialCore.first!.title)")
        
        for eachTrial in viewModel.trialCore {
            print("directions: \(eachTrial.direction)")
            print("score: \(eachTrial.latestScore)")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ButtonWIthTrialCore: UIButton {
    var trialCore: TrialCore?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
