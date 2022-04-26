//
//  PositionSelectingController.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/25.
//

import UIKit
import SnapKit
import Then




// This is Main Screen From now on.. ^_^

class PositionSelectingController: UIViewController {
    
    var connectionManager = ConnectionManager()
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupTargets()
        connectionManager.delegate = self
        
        
    }
    
    private func setupTargets() {
        sessionButton.addTarget(self, action: #selector(showConnectivityAction(_:)), for: .touchUpInside)
    }
    
    @objc func showConnectivityAction(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Todo Exchange", message: "Do you want to Host or Join a session?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Host Session", style: .default, handler: { (action: UIAlertAction) in
            self.connectionManager.host()
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Join Session", style: .default, handler: { (action: UIAlertAction) in
            self.connectionManager.join()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
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
    
    private let topView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemPink
        return v
    }()
    
    let sessionButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Connect", for: .normal)
        btn.setTitleColor(.green, for: .normal)
        return btn
    }()
    
    
    // MARK: - UI PART
    private func setupLayout() {

        let allViews = [
            squatView,hurdleStep, inlineLunge, shoulderMobility,
            straightLegRaise, stabilityPushup, rotaryStability,
            shoulder, extensions, flexion
        ]
        
        let otherViews = [topView]
        
        allViews.forEach { eachPosition in
            self.view.addSubview(eachPosition)
        }
        
        otherViews.forEach { v in
            self.view.addSubview(v)
        }
        
        topView.addSubview(sessionButton)
        
        
        
        topView.snp.makeConstraints { make in
            make.left.top.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(40)
        }
        
        sessionButton.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.width.equalTo(100)
        }
        
        squatView.snp.makeConstraints { make in
            make.left.equalToSuperview()
//            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.top.equalTo(topView.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }
       
        hurdleStep.snp.makeConstraints { make in
            make.leading.equalTo(squatView.snp.trailing)
//            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.top.equalTo(topView.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }

        inlineLunge.snp.makeConstraints { make in
            make.leading.equalTo(hurdleStep.snp.trailing)
//            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.top.equalTo(topView.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }

        shoulderMobility.snp.makeConstraints { make in
            make.leading.equalTo(inlineLunge.snp.trailing)
//            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.top.equalTo(topView.snp.bottom)
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
        
    }
}


extension PositionSelectingController: ConnectionManagerDelegate {
    func presentVideo() {
        
    }
    
    func showDuration(_ startAt: Date, _ endAt: Date) {
        
    }
    
    func showStart(_ startAt: Date) {
        
    }
    
    func updateDuration(_ startAt: Date, current: Date) {
        
    }
    
    func updateState(state: String) {
        
    }
    
    func disconnected(state: String, timeDuration: Int) {
        
    }
    
    
}
