//
//  PositionSelectingController.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/25.
//

import UIKit
import SnapKit
import Then





class PositionSelectingController: UIViewController {
    
    private let squatView = PositionBlockView(PositionListEnum.deepsquat)
    private let hurdleStep = PositionBlockView(PositionListEnum.hurdleStep)
    private let inlineLunge = PositionBlockView(PositionListEnum.inlineLunge)
    private let shoulderMobility = PositionBlockView(PositionListEnum.shoulderMobility)
    
    private let straightLegRaise = PositionBlockView(PositionListEnum.straightLegRaise)
//
    private let stabilityPushup = PositionBlockView(PositionListEnum.stabilityPushup)
    private let rotaryStability = PositionBlockView(PositionListEnum.rotaryStability)
    
    private let shoulder = PositionBlockView(PositionListEnum.shoulder)
    private let extensions = PositionBlockView(PositionListEnum.extensions)
    private let flexion = PositionBlockView(PositionListEnum.flexion)

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }
    
    private func setupLayout() {
        print("started setupLayout in positionSelectingController")
        let allViews = [
            squatView,hurdleStep, inlineLunge, shoulderMobility,
            straightLegRaise
            , stabilityPushup
            , rotaryStability,
                                    shoulder, extensions, flexion
        ]
        
        allViews.forEach { eachPosition in
            self.view.addSubview(eachPosition)
        }
        
        squatView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }
       
        print("squat View ended")
        hurdleStep.snp.makeConstraints { make in
            make.leading.equalTo(squatView.snp.trailing)
//            make.left.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }
        print("hurdleStep View ended")
        inlineLunge.snp.makeConstraints { make in
            make.leading.equalTo(hurdleStep.snp.trailing)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }
        print("inlineLunge View ended")
        shoulderMobility.snp.makeConstraints { make in
            make.leading.equalTo(inlineLunge.snp.trailing)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }
        
        straightLegRaise.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(squatView.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(3)
        }
//
        stabilityPushup.snp.makeConstraints { make in
            make.leading.equalTo(straightLegRaise.snp.trailing)
            make.top.equalTo(squatView.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(3)
        }
        
        rotaryStability.snp.makeConstraints { make in
            make.leading.equalTo(stabilityPushup.snp.trailing)
            make.top.equalTo(squatView.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(3)
        }
        
        
        
        
        shoulder.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(straightLegRaise.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(3)
        }

        extensions.snp.makeConstraints { make in
            make.leading.equalTo(shoulder.snp.trailing)
            make.top.equalTo(straightLegRaise.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(3)
        }
        
        flexion.snp.makeConstraints { make in
            make.leading.equalTo(extensions.snp.trailing)
            make.top.equalTo(straightLegRaise.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(3)
        }
        
//        shoulder.snp.makeConstraints { make in
//            make.leading.equalTo(flexi)
//        }
    }
}
