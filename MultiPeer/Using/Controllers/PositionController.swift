//
//  PositionSelectingController.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/25.
//

import UIKit
import SnapKit
import Then



class PositionController: UIViewController {
    
    // MARK: - Properties
    
    var connectionManager = ConnectionManager()

    var count = 0
    var timer: Timer?
    
    private let deepSquat = PositionBlockView(PositionWithImageListEnum.deepsquat)
    private let hurdleStep = PositionBlockView(PositionWithImageListEnum.hurdleStep)
    private let inlineLunge = PositionBlockView(PositionWithImageListEnum.inlineLunge)
    private let ankleClearing = PositionBlockView(PositionWithImageListEnum.ankleClearing)
    
    private let shoulderMobility = PositionBlockView(PositionWithImageListEnum.shoulderMobility)
    private let shoulderClearing = PositionBlockView(PositionWithImageListEnum.shoulderClearing)
    private let straightLegRaise = PositionBlockView(PositionWithImageListEnum.straightLegRaise)
    
    private let stabilityPushup = PositionBlockView(PositionWithImageListEnum.stabilityPushup)
    private let extensionClearing = PositionBlockView(PositionWithImageListEnum.extensionClearing)
    private let rotaryStability = PositionBlockView(PositionWithImageListEnum.rotaryStability)
    private let flexionClearing = PositionBlockView(PositionWithImageListEnum.flexionClearing)
    

    private let topView = UIView().then { $0.backgroundColor = .systemPink}
    
    private let sessionButton = UIButton().then {
        $0.setTitle("Connect", for: .normal)
        $0.setTitleColor(.green, for: .normal)
    }
    
    private let connectionStateLabel = UILabel().then {
//        $0.textColor = .blue
        $0.textColor = .black
        $0.text = "Not Connected"
    }
    
    private let durationLabel = UILabel().then { $0.textColor = .black
        $0.text = "duration"
    }
    
//    private let timerTestBtn = UIButton().then { $0.setTitle("start Timer", for: .normal)
//        $0.setTitleColor(.yellow, for: .normal)
//
//    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupTargets()
        connectionManager.delegate = self
        addNotificationObservers()
//        testCode()
        
        print("PositionCOntorller has appeared!")
        print("-------------------------------\n\n\n")
        print("-------------------------------")
    }
    
    @objc func testBtnTapped(_ sender: UIButton) {
        testCode()
    }
    
    func testCode() {
        let date = Date().addingTimeInterval(5)
        print("hi!")
        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(runCode), userInfo: nil, repeats: false)
        // 잘 작동 하는구만!!!
        RunLoop.main.add(timer, forMode: .common)
    }
    
    @objc func runCode() {
        print("hello!")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear PositionController")
//        triggerTimer()
    }
 
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisAppear POsitionController")
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisAppear PositionConroller")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
     // MARK: - Targets
    
    private func setupTargets() {
        sessionButton.addTarget(self, action: #selector(showConnectivityAction(_:)), for: .touchUpInside)
//        timerTestBtn.addTarget(self, action: #selector(testBtnTapped(_:)), for: .touchUpInside)
    }
    
    @objc func showConnectivityAction(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Connect Camera", message: "Do you want to Host or Join a session?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Host Session", style: .default, handler: { (action: UIAlertAction) in
            self.connectionManager.host()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Join Session", style: .default, handler: { (action: UIAlertAction) in
            self.connectionManager.join()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
//    @objc func testBtnTapped(_ sender: UIButton) {
//        connectionManager.send("test message")
//        print("test Btn Tapped!!")
//        // trigger timer
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//            guard let `self` = self else {
//                print("self is nil ")
//                return }
//
//            print("hi!!!!!")
//            self.count += 1
//            DispatchQueue.main.async {
//                self.durationLabel.text = "\(self.count) s"
//            }
//        }
//
//        let cameraVC = CameraController(
//            positionTitle: "hi", direction: .left, score: 0,
//            connectionManager: connectionManager)
//
//        self.present(cameraVC, animated: true)
//    }
    
    func triggerTimer() {
        print("timer triggered!!")
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let `self` = self else {
                print("self is nil ")
                return }
            
            print("hi!!!!!")
            self.count += 1
            DispatchQueue.main.async {
                self.durationLabel.text = "\(self.count) s"
            }
        }
    }
    
//    @objc func triggerTimer(_ sender: UIButton) {
//    func triggerTimer() {
//        print("Timer triggered!")
////        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countUp), userInfo: nil, repeats: true)
//
//        // not Triggered
////        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
////            guard let `self` = self else {
////                print("self is nil!!")
////                return }
////            self.count += 1
////            print("helloo")
////            DispatchQueue.main.async {
////                self.durationLabel.text = String("\(self.count) s")
////                print("hihi")
////            }
////        })
//        // not triggered
////        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(PositionSelectingController.countUp), userInfo: nil, repeats: true)
//
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//            guard let `self` = self else { return }
//
//            print("hi!!!!!")
//            DispatchQueue.main.async {
//                self.durationLabel.text = String(self.count) + " s"
//                print("updating?")
//            }
//        }
//    }
    
    
    private func stopTimer() {
        timer?.invalidate()
    }
    
    @objc func countUp() {
        print("countUp triggered!!")
        count += 1
        
        DispatchQueue.main.async {
            self.durationLabel.text = String(self.count) + " s"
        }
    }
    
    @objc func btnTapped( _ sender: UIButton) {
        switch sender.tag {
        case 0: print("from left")
        case 1: print("from right")
        case 2: print("from center")
        default: print("other")
        }
    }
    
    
    @objc func imgTapped(_ sender: ButtonWithInfo) {
        // TODO: move to cameraView With Info
        print("img Tapped,")
        let positionWithDirectionInfo = sender.positionWithDirectionInfo
        
        let title = positionWithDirectionInfo.title
        let direction = positionWithDirectionInfo.direction
        let score = positionWithDirectionInfo.score
        
        connectionManager.send(DetailPositionWIthMsgInfo(message: .presentCamera, detailInfo: PositionWithDirectionInfo(title: title, direction: direction, score: score)))
        print("connectionManager has sent message")
//        print("title: \(sender.title)")
        print("title: \(sender.positionWithDirectionInfo.title)")
//        print("direction: \(sender.direction)")
        print("direction: \(sender.positionWithDirectionInfo.direction)")
//        print("sender.score: \(sender.score ?? 0)")
        print("sender.score: \(sender.positionWithDirectionInfo.score ?? 0)")
        
        
        DispatchQueue.main.async {
            let cameraVC = CameraController(positionWithDirectionInfo: positionWithDirectionInfo, connectionManager: self.connectionManager)
//            self.present(cameraVC, animated: true)
//            UINavigationController.pushViewController(cameraVC)
            self.navigationController?.pushViewController(cameraVC, animated: true)
        }
    }
    
    @objc func scoreTapped(_ sender: ButtonWithInfo) {
        // TODO: if none recorded, move to cameraView With Info
        // TODO: if Not, popup score Action to modify
        
        print("score Tapped,")
//        print("title: \(sender.title)")
        print("title: \(sender.positionWithDirectionInfo.title)")
//        print("direction: \(sender.direction)")
        print("direction: \(sender.positionWithDirectionInfo.direction)")
    
//        print("sender.score: \(sender.score ?? 0)")
        print("sender.score: \(sender.positionWithDirectionInfo.score ?? 0)")
    }
    // observer, add observer
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(presentCamera(_:)),
                                               name: .presentCameraKey, object: nil)
    }
    
    @objc func presentCamera(_ notification: Notification) {
        print("presentCamera triggered by observing notification")
        
        
        
        guard let title = notification.userInfo?["title"] as? String,
              let direction = notification.userInfo?["direction"] as? PositionDirection,
              let score = notification.userInfo?["score"] as? Int? else {
            print("failed to converting userInfo back.")
            return }
        
        let positionWithDirectionInfo = PositionWithDirectionInfo(title: title, direction: direction, score: score)


        DispatchQueue.main.async {
            let cameraVC = CameraController(positionWithDirectionInfo: positionWithDirectionInfo, connectionManager: self.connectionManager)

            self.present(cameraVC, animated: true)
        }
        
        
    }
    
    // MARK: - UI SETUP
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
        
        
        view.addSubview(topView)
        
        topView.snp.makeConstraints { make in
            make.left.top.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(40)
        }


        [sessionButton, connectionStateLabel, durationLabel].forEach { v in
            topView.addSubview(v)
        }
        
        sessionButton.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.width.equalTo(100)
        }
        
        connectionStateLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.width.equalTo(150)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(connectionStateLabel.snp.trailing)
            make.trailing.equalTo(sessionButton.snp.leading)
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
        
//        view.addSubview(timerTestBtn)
//        timerTestBtn.snp.makeConstraints { make in
//            make.leading.bottom.equalToSuperview()
//            make.top.equalTo(stabilityPushup.snp.bottom)
//            make.width.equalTo(150)
//        }
    }
    
    
    
}


extension PositionController: ConnectionManagerDelegate {
    
//    func presentVideo() {
        
//    }
    
    func updateState(state: ConnectionState) {
        switch state {
        case .connected:
        triggerTimer()
        case .disconnected:
            stopTimer()
//        case .connecting: break
        }

        DispatchQueue.main.async {
            self.connectionStateLabel.text = state.rawValue
        }
    }
    
    func updateDuration(in seconds: Int) {
        DispatchQueue.main.async {
            self.durationLabel.text = "\(seconds) s"
        }
    }
}


    
    

