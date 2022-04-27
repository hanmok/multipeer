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

class ImageButton: ButtonWithInfo {
    override init(title: String, direction: PositionDirection = .neutral, score: Int? = nil, frame: CGRect = .zero) {
        super.init(title: title, direction: direction, score: score, frame: frame)
        self.addTarget(nil, action: #selector(PositionSelectingController.imgTapped(_:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PositionSelectingController: UIViewController {
    
    var connectionManager = ConnectionManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupTargets()
        connectionManager.delegate = self
        
    }
    

    private let testImg = UIImageView().then { $0.isUserInteractionEnabled = true }
    
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
    
    private let deepSquat = PositionBlockView(PositionListEnum.deepsquat)
    private let hurdleStep = PositionBlockView(PositionListEnum.hurdleStep)
    private let inlineLunge = PositionBlockView(PositionListEnum.inlineLunge)
    private let ankleClearing = PositionBlockView(PositionListEnum.ankleClearing)
    
    private let shoulderMobility = PositionBlockView(PositionListEnum.shoulderMobility)
    private let shoulderClearing = PositionBlockView(PositionListEnum.shoulderClearing)
    private let straightLegRaise = PositionBlockView(PositionListEnum.straightLegRaise)
    
    private let stabilityPushup = PositionBlockView(PositionListEnum.stabilityPushup)
    private let extensionClearing = PositionBlockView(PositionListEnum.extensionClearing)
    private let rotaryStability = PositionBlockView(PositionListEnum.rotaryStability)
    private let flexionClearing = PositionBlockView(PositionListEnum.flexionClearing)
    
    private let topView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemPink
        return v
    }()
    
    @objc func btnTapped( _ sender: UIButton) {
        switch sender.tag {
        case 0: print("from left")
        case 1: print("from right")
        case 2: print("from center")
        default: print("other")
        }
    }
    
    @objc func imgTapped(_ sender: ButtonWithInfo) {
        print("img Tapped,")
        print("title: \(sender.title)")
        print("direction: \(sender.direction)")
    
        print("sender.score: \(sender.score ?? 0)")
    }
    
    @objc func scoreTapped(_ sender: ButtonWithInfo) {
        print("score Tapped,")
        print("title: \(sender.title)")
        print("direction: \(sender.direction)")
    
        print("sender.score: \(sender.score ?? 0)")
    }
    
    let sessionButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Connect", for: .normal)
        btn.setTitleColor(.green, for: .normal)
        return btn
    }()
    
    
    // MARK: - UI PART
    private func setupLayout() {
        

        
        let allViews = [deepSquat, hurdleStep, inlineLunge, ankleClearing,
                        shoulderMobility, shoulderClearing, straightLegRaise,
                        stabilityPushup, extensionClearing, rotaryStability, flexionClearing]
        
        
        allViews.forEach { eachPosition in
            self.view.addSubview(eachPosition)
            eachPosition.isUserInteractionEnabled = true // do we need it ?
        }
        

        
        allViews.forEach { each in
            each.isUserInteractionEnabled = true
        }
        
        [topView].forEach { otherView in
            self.view.addSubview(otherView)
        }
        
        
        topView.snp.makeConstraints { make in
            make.left.top.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(40)
        }

        topView.addSubview(sessionButton)
        
        sessionButton.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.width.equalTo(100)
        }
        
        topView.addSubview(testImg)
        testImg.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(100)
        }
        
        deepSquat.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }
       
        hurdleStep.snp.makeConstraints { make in
            make.leading.equalTo(deepSquat.snp.trailing)
            make.top.equalTo(topView.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }

        inlineLunge.snp.makeConstraints { make in
            make.leading.equalTo(hurdleStep.snp.trailing)
            make.top.equalTo(topView.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }
        
        ankleClearing.snp.makeConstraints { make in
            make.leading.equalTo(inlineLunge.snp.trailing)
            make.top.equalTo(topView.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }
        
        
        
        shoulderMobility.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(deepSquat.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(3)
        }
//
        shoulderClearing.snp.makeConstraints { make in
            make.leading.equalTo(shoulderMobility.snp.trailing)
            make.top.equalTo(deepSquat.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(3)
        }
        
        straightLegRaise.snp.makeConstraints { make in
            make.leading.equalTo(shoulderClearing.snp.trailing)
            make.top.equalTo(deepSquat.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(3)
        }
        
        
        
        stabilityPushup.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(shoulderMobility.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }

        extensionClearing.snp.makeConstraints { make in
            make.leading.equalTo(stabilityPushup.snp.trailing)
            make.top.equalTo(shoulderMobility.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }
        
        rotaryStability.snp.makeConstraints { make in
            make.leading.equalTo(extensionClearing.snp.trailing)
            make.top.equalTo(shoulderMobility.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
        }
        
        flexionClearing.snp.makeConstraints { make in
            make.leading.equalTo(rotaryStability.snp.trailing)
            make.top.equalTo(shoulderMobility.snp.bottom)
            make.height.equalToSuperview().dividedBy(4)
            make.width.equalToSuperview().dividedBy(4)
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
