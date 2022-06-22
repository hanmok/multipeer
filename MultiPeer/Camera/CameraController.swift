//
//  ViewController.swift
//  BasicCameraUsingPicker
//
//  Created by 핏투비 iOS on 2022/04/26.
//

import UIKit
import SnapKit
import MobileCoreServices
import Photos
import MultipeerConnectivity
import AVFoundation
import CoreData
import Lottie


protocol CameraControllerDelegate: AnyObject {
    func dismissCamera(closure: () -> Void)
    func makeSound()
}

// CameraController don't need to know 'score'
class CameraController: UIViewController {
    
    // MARK: - Properties

    private var videoUrl: URL?
    var shouldShowScoreView = true
    // TODO: Handle inside ConnectionManager
    // TODO: duplicate check, send msg if direction assigned.

    var croppedUrl: URL?
    
    var positionTitle: String
    
    var direction: MovementDirection
    
    var cameraDirection: CameraDirection?
    
//    var connectedAmount: Int = 0
    
    var trialCore: TrialCore
    
    var systemSoundID: SystemSoundID = 1057
// TODO: Cut Clip from the front as much as recording time diff
    var timeDifference: CGFloat = 0 // or CMTime
    
    let rank: Rank
    
    private var pressedBtnTitle = ""
    
    var updatingDurationTimer = Timer()
    
    var count = 0
    
    var isRecordingEnded = false

    weak var delegate: CameraControllerDelegate?
    
    var connectionManager: ConnectionManager
    
    private var picker = UIImagePickerController()
    
    var previewVC: PreviewController?
    
    private var scoreVC: ScoreController
    
    private var isRecording = false
    
    //    private let shouldRecordLater = false
    private let shouldRecordLater = false
    
    var variationName: String?
    
    var trialDetail: TrialDetail?
    
    var screen: Screen?
    
    // MARK: - Life Cycle
    
    init(
        connectionManager: ConnectionManager,
        trialCore: TrialCore,
        rank: Rank,
        screen: Screen?
    ) {
            self.connectionManager = connectionManager
            
            self.trialCore = trialCore
            self.positionTitle = trialCore.title
            
            self.direction = MovementDirection(rawValue: trialCore.direction)!
            
            scoreVC = ScoreController(positionTitle: trialCore.title, direction: trialCore.direction)
        self.screen = screen
        
            self.rank = rank
//            self.connectedAmount = connectedAmount
            super.init(nibName: nil, bundle: nil)
            connectionManager.delegate = self
            scoreVC.delegate = self
            scoreVC.parentController = self
//            setupTrialDetail()
            changeBtnLookForPreparing(animation: false)
        }
    
    // 왜 두번 생성하고 ㅈㄹ.. 필요 없어보임.
//    private func setupTrialDetail() {
//        trialDetail = trialCore.returnFreshTrialDetail()
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("CameraController viewdidLoad triggered")
        updateNameLabel()

        setupLayout()
        setupAddTargets()
        addNotificationObservers()

        setupCompleteView()
        
        updatePeerTitle()
        
        if let myDirection = connectionManager.mydirection {
            directionStackView.selectBtnAction(with: myDirection.rawValue)
        }
        
        setupInitialDirectionBtn()
    }
    
    private func setupInitialDirectionBtn() {
        if connectionManager.latestDirection != nil {
            let title = connectionManager.latestDirection!.rawValue
            directionStackView.selectBtnAction(with: title)
        }
    }
    
    
    private func updatePeerTitle() {
        
        let direction = MovementDirection(rawValue: trialCore.direction)!
        
//        connectionManager.send(MsgWithMovementDetail(message: .updatePeerTitle, detailInfo: MovementDirectionScoreInfo(title: positionTitle, direction: direction)))
        
        connectionManager.send(PeerInfo(msgType: .updatePeerTitle, info: Info(movementDetail: MovementDirectionScoreInfo(title: positionTitle, direction: direction))))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeChildrenVC()
    }
    
    // not triggered even if view disappears
    
    deinit {
        print("cameraController deinit triggered!")
        DispatchQueue.main.async {
            if self.children.count > 0 {
                let viewControllers: [UIViewController] = self.children
                for vc in viewControllers {
                    vc.willMove(toParent: nil)
                    vc.view.removeFromSuperview()
                    vc.removeFromParent()
                }
            }
        }
    }
    
    // MARK: - UI Funcs
    private func updateNameLabel() {
        print("updateNameLabel triggered!!")
        print("current title from updateNameLabel: \(positionTitle)")
        print("direction: \(direction)")
        DispatchQueue.main.async {
            if self.direction == .neutral {
                self.movementNameLabel.text = self.positionTitle
            } else {
                self.movementNameLabel.text = self.positionTitle + " " + self.direction.rawValue
            }
        }
    }
    
    public func resetTimer() {
        count = 0
        updatingDurationTimer.invalidate()
//        updatingDurationTimer = Timer()
        updateDurationLabel()
    }
    public func invalidateTimer() {
        print("invalidateTimer Called")
        updatingDurationTimer.invalidate()
    }
    
    // MARK: - Notification
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(startRecordingNowNoti(_:)),
            name: .startRecordingKey, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hidePreviewNoti(_:)),
            name: .hidePreviewKey, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(stopRecordingNoti(_:)),
            name: .stopRecordingKey, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateConnectionStateNoti(_:)),
            name: .updateConnectionStateKey, object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(requestPostNoti(_:)),
            name: .requestPostKey, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePeerTitleNoti(_:)),
            name: .updatePeerTitleKey, object: nil
        )
        
//        NotificationCenter.default.addobser
    }
    
    @objc func updatePeerTitleNoti(_ notification: Notification) {
        
        let title = (notification.userInfo?["title"])! as! String
        let direction = notification.userInfo?["direction"]! as! MovementDirection
        
        DispatchQueue.main.async {
            if self.direction == .neutral {
                self.movementNameLabel.text = title
            } else {
                self.movementNameLabel.text = title + " " + direction.rawValue
            }
        }
    }
    
    private let leftLine = UIView().then {
        $0.backgroundColor = UIColor(redInt: 225, greenInt: 225, blueInt: 230)
    }
    
    private let rightLine = UIView().then {
        $0.backgroundColor = UIColor(redInt: 225, greenInt: 225, blueInt: 230)
    }
    
    
    @objc func requestPostNoti(_ notification: Notification) {
        
        if croppedUrl != nil {
            print("croppedUrl is valid")
            self.saveVideoToLocal(with: croppedUrl!)
        } else {
            print("croppedUrl is nil")
        }
        
        printFlag(type: .peerRequest, count: 4)
        guard let title = notification.userInfo?["title"] as? String,
              let direction = notification.userInfo?["direction"] as? MovementDirection,
              let score = notification.userInfo?["score"] as? Int?,
              let pain = notification.userInfo?["pain"] as? Bool?,
//              let pain = notification
              let validVideoUrl = videoUrl else { return }
        printFlag(type: .peerRequest, count: 5)
        //TODO: 여기에서 막힘
        guard let cameraDirection = cameraDirection else {
            return
        }

        printFlag(type: .peerRequest, count: 6)
//        let tempPain: Bool? = nil
        let tempTrialCount = 0
        let tempTrialId = UUID()
        

        APIManager.shared.postRequest(movementDirectionScoreInfo: MovementDirectionScoreInfo(title: title, direction: direction, score: score, pain: pain), trialCount: tempTrialCount, trialId: tempTrialId, videoUrl: validVideoUrl, angle: cameraDirection) {
            self.printFlag(type: .peerRequest, count: 7)
            print("closure called after post request")
        }
    }
    
    @objc func hidePreviewNoti(_ notification: Notification) {
        hidePreview()
        resetTimer()
    }
    
    @objc func startRecordingNowNoti(_ notification: Notification) {
        print("startRecording has been triggered by observer. ")
        
        
        // remove preview if master order recording
        removeChildrenVC()
        // original
//        let recordingTimer = Timer(fireAt: Date(), interval: 0, target: self, selector: #selector(startRecording), userInfo: nil, repeats: false)
        
        resetTimer()
        
        updatingDurationTimer = Timer(fireAt: Date(), interval: 0, target: self, selector: #selector(startRecording), userInfo: nil, repeats: false)
        
        RunLoop.main.add(updatingDurationTimer, forMode: .common)
        
        changeBtnLookForRecording(animation: false)
        
        triggerDurationTimer()
        
    }
    public func stopDurationTimer() {
        updatingDurationTimer.invalidate()
    }
//    public func rese
    
    
    @objc func stopRecordingNoti(_ notification: Notification) {
        print("stopRecording has been triggered by observer. ")
        
        stopRecording()
        changeBtnLookForPreparing(animation: false)
        stopTimer()
    }
    
    // this one called!!
    @objc func updateConnectionStateNoti(_ notification: Notification) {
        print(#file, #line)
        guard let state = notification.userInfo?["connectionState"] as? ConnectionState else { return }
        
        switch state {
        case .disconnected:
            DispatchQueue.main.async {
                if self.connectionManager.isHost == false {
                    self.showReconnectionGuideAction()
                }
            }
            
        case .connected:
            DispatchQueue.main.async {
//                self.connectionStateLabel.text = "Connected!"
            }
        }
    }
    
    
    
    // MARK: - Button Actions
    private func setupAddTargets() {
        
        dismissBtn.addTarget(self, action: #selector(dismissBtnTapped(_:)), for: .touchUpInside)
        
        recordingBtn.addTarget(self, action: #selector(recordingBtnTapped(_:)), for: .touchUpInside)
        
        homeBtn.addTarget(self, action: #selector(nextTapped(_:)), for: .touchUpInside)
        
        retryBtn.addTarget(self, action: #selector(retryTapped(_:)), for: .touchUpInside)
        
        for btn in directionStackView.buttons {
            btn.addTarget(self, action: #selector(directionTapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc func directionTapped(_ sender: SelectableButton) {
        
        directionStackView.selectBtnAction(selected: sender.id)
        
        
        guard let selectedDirection = CameraDirection(rawValue: sender.title) else { fatalError() }
        connectionManager.latestDirection = selectedDirection
        
        cameraDirection = CameraDirection(rawValue: sender.title)

        
        guard let cameraDirection = cameraDirection else {
            fatalError("invalid camera direction")
        }

        connectionManager.cameraDirectionDic[connectionManager.myId] = cameraDirection
        
        connectionManager.mydirection = cameraDirection
        
        connectionManager.send(PeerInfo(msgType: .updatePeerCameraDirection, info: Info( idWithDirection: PeerIdWithCameraDirection(peerId: UIDevice.current.name, cameraDirection: cameraDirection))))
        
        // TODO: CameraDirection Check,
        // TODO: Show Alert If exist.
        for (peerId, direction) in connectionManager.cameraDirectionDic {
            if direction == cameraDirection && peerId != connectionManager.myId{
                showAlert("Duplicate Direction", "Please change camera direction of current device or the one with \"\(peerId)\"")
            }
        }
    }
    
    @objc func nextTapped(_ sender: UIButton) {
        // if pressedBtn is "Hold", update self.trialCore with Variation
        
        if pressedBtnTitle != "Hold" {
            delegate?.dismissCamera() {
                
                self.dismiss(animated: true)
            }
            // CameraController Delegate
        } else {
            // TODO: update Position for Variation
            
            variationName = movementWithVariation[positionTitle]
            
            if variationName != nil {
                
                // TODO: Update Core to Variation
                
                guard let screen = screen else { fatalError() }
                
                let nextCore = screen.trialCores.filter { $0.title == variationName! }.first!
                
                trialCore = nextCore
                
                
                self.positionTitle = variationName!
                updateNameLabel()
                
                resetTimer()
                
                scoreVC.setupAgain(positionTitle: self.positionTitle, direction: direction)
                
                updatePeerTitle()
                
            } else { print("no variation name exist !!") }
            
            hideCompleteMsgView()
            
            connectionManager.send(PeerInfo(msgType: .hidePreviewMsg, info: Info()))
            
            
        }
    }
    
    private func hideCompleteMsgView() {
        UIView.animate(withDuration: 0.4) {
            self.completeMsgView.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
        }
    }
    
    @objc func retryTapped(_ sender: UIButton) {
        retryAction()
        connectionManager.send(PeerInfo(msgType: .hidePreviewMsg, info: Info()))
    }
    
    
//    @objc func recordingBtnTapped(_ sender: UIButton) {
//
//        recordingBtnAction()
//
//    }
    
    private func changeMode(target: Side?, mode: Mode) {
        printFlag(type: .peerConnectivity, count: -1, message: "changeMode triggered")
        guard let target = target else {

            printFlag(type: .peerConnectivity, count: 0, message: "target is nil")
            DispatchQueue.main.async {
            self.leftShape.layer.cornerRadius = 10
            self.leftShape.backgroundColor = .lavenderGray400
            
            self.rightShape.layer.cornerRadius = 10
            self.rightShape.backgroundColor = .lavenderGray400
            }
            return
        }

        switch mode {
        case .onRecording:
            switch target {
                
            case .left:
                DispatchQueue.main.async {
                    self.leftShape.layer.cornerRadius = 10
                    self.leftShape.backgroundColor = .red
                }

            case .right:
                DispatchQueue.main.async {
                
                self.rightShape.layer.cornerRadius = 10
                self.rightShape.backgroundColor = .red
                }
            case .both:
                DispatchQueue.main.async {
                
                self.leftShape.layer.cornerRadius = 10
                self.leftShape.backgroundColor = .red
                self.rightShape.layer.cornerRadius = 10
                self.rightShape.backgroundColor = .red
            }
            }
            
        case .stop:
            switch target {
            case .left:
                DispatchQueue.main.async {
                
                self.leftShape.layer.cornerRadius = 2
                self.leftShape.backgroundColor = .lavenderGray400
                }
            case .right:
                DispatchQueue.main.async {
                
                self.rightShape.layer.cornerRadius = 2
                self.rightShape.backgroundColor = .lavenderGray400
                }
            case .both:
                DispatchQueue.main.async {
                
                self.leftShape.layer.cornerRadius = 2
                self.leftShape.backgroundColor = .lavenderGray400
                
                self.rightShape.layer.cornerRadius = 2
                self.rightShape.backgroundColor = .lavenderGray400
                }
                }
        }
    }
    
    private func changeBtnLookForRecording(animation: Bool) {
        if animation {
            //            if connectionMa
            UIView.animate(withDuration: 0.4) {
                self.outerRecCircle.backgroundColor = .lavenderGray900
                self.innerShape.layer.cornerRadius = 6
                self.recordingBtn.setTitleColor(.gray900, for: .normal)
                
//                self.changeMode(target: countToSideDic[self.connectedAmount]!, mode: .stop)
                self.changeMode(target: countToSideDic[self.connectionManager.numOfPeers]!, mode: .stop)
                //                self.leftShape.layer.cornerRadius = 2
                //                self.leftShape.backgroundColor = .lavenderGray400
            }
        } else {
            DispatchQueue.main.async {
                self.outerRecCircle.backgroundColor = .lavenderGray900
                self.innerShape.layer.cornerRadius = 6
                self.recordingBtn.setTitleColor(.gray900, for: .normal)
                
                //                self.leftShape.layer.cornerRadius = 2
                //                self.leftShape.backgroundColor = .lavenderGray400
//                self.changeMode(target: countToSideDic[self.connectedAmount]!, mode: .stop)
                self.changeMode(target: countToSideDic[self.connectionManager.numOfPeers]!, mode: .stop)
            }
        }
    }
    
    private func changeBtnLookForPreparing(animation: Bool ) {
        if animation {
            UIView.animate(withDuration: 0.4) {
                self.outerRecCircle.backgroundColor = .red
                self.innerShape.layer.cornerRadius = 18
                self.recordingBtn.setTitleColor(.red, for: .normal)
                
//                self.changeMode(target: countToSideDic[self.connectedAmount]!, mode: .onRecording)
                self.changeMode(target: countToSideDic[self.connectionManager.numOfPeers]!, mode: .onRecording)
            }
        } else {
            DispatchQueue.main.async {
                self.outerRecCircle.backgroundColor = .red
                self.innerShape.layer.cornerRadius = 18
                self.recordingBtn.setTitleColor(.red, for: .normal)
                
//                self.changeMode(target: countToSideDic[self.connectedAmount]!, mode: .onRecording)
                self.changeMode(target: countToSideDic[self.connectionManager.numOfPeers]!, mode: .onRecording)
            }
        }
    }
    
    @objc func recordingBtnAction() {
        // Start Recording!!
        
        removeChildrenVC()
        if !isRecording {
            
            connectionManager.send(PeerInfo(msgType: .startRecordingMsg, info: Info()))
            
            startRecording()
            
            changeBtnLookForRecording(animation: true)
            
        } else {
            
            stopRecording()
            
            
            changeBtnLookForPreparing(animation: true)
            
            connectionManager.send(PeerInfo(msgType: .stopRecordingMsg, info: Info()))
        }
    }
    
    @objc func dismissBtnTapped(_ sender: UIButton) {
        print("dismiss btn tapped!")
        self.dismiss(animated: true)
        // 왜 dismiss 가 안되지?
        delegate?.dismissCamera() {
            self.dismiss(animated: true)
        }
    }
    
    @objc func recordingBtnTapped(_ sender: UIButton) {
        // FIXME: Condition 이 약간 이상해보이는데. ?
//        if connectionManager.cameraDirectionDic
        
        // num of direction checked  ~ num of peers
        // cameraDirectionDic  은 최대 3개,
        // numOfPeers 는 최대 2 + 1 -> 3개
        if connectionManager.cameraDirectionDic.count < connectionManager.numOfPeers + 1 {
            showAlert("Direction not determined", "Please check camera direction. ")
            return
        }
        
        // Duplicate check
        var directionSet = Set<CameraDirection>()
        
        for (peerId, direction) in connectionManager.cameraDirectionDic {
            if directionSet.contains(direction) { // if duplicate
                showAlert("Duplicate Camera Direction", "\(direction.rawValue) are duplicate. ")
                return
            } else { // if new -> update
                directionSet.update(with: direction)
            }
        }
        
//        if connectionManager.mydirection == nil {
//            showAlert(<#T##title: String##String#>, <#T##message: String##String#>)
//        }
        
        
        
        if isRecording {
            //            startRecording()
            recordingBtnAction()
        } else {
            // MARK: - Testing Mode
            //             TODO: Uncomment after testing
            if shouldRecordLater {
                _ = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) {  [weak self] _ in
                    self?.recordingBtnAction()
                }
                playCountDownLottie()
            } else {
                self.recordingBtnAction()
            }
        }
    }
    
    // TODO: Score 에서 Hold -> Next
    // TODO:           그 외 -> Retry
    
    private func setupCompleteView(withNextTitle: Bool = false) {
        if withNextTitle {
            
            homeBtn.setTitle("Next", for: .normal)
        } else {
            homeBtn.setTitle("Home", for: .normal)
        }
        
        view.addSubview(completeMsgView)
        
        completeMsgView.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
        
        
        [completeLottieView,completeMsgLabel, retryBtn, homeBtn].forEach { completeMsgView.addSubview($0)}
        
        completeLottieView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalToSuperview().dividedBy(10)
            make.centerY.equalToSuperview().offset(-70)
        }
        
        completeMsgLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalTo(100)
            make.top.equalTo(completeLottieView.snp.bottom).offset(15)
        }
        
        retryBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(34)
            make.height.equalTo(48)
            make.width.equalTo(97)
        }
        
        homeBtn.snp.makeConstraints { make in
            make.leading.equalTo(retryBtn.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(34)
            make.height.equalTo(48)
        }
    }
    
    /// prepare scoreVC to the bottom (to come up later)
    @objc func prepareScoreView() {
        
        if rank == .boss {
            addChild(scoreVC)
            view.addSubview(scoreVC.view)
            scoreVC.view.layer.cornerRadius = 10
            
            self.scoreVC.view.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
        }
        
        // 점수 초기화 !
        scoreVC.scoreBtnStackView.setSelectedBtnNone()
        scoreVC.painBtnStackView.setSelectedBtnNone()
    }
    
    // TODO: need to change trialCore of scoreVC here (why ?
    private func showScoreView(size: ScoreViewSize = .large) {
        if rank == .boss {
            
            scoreVC.setupTrialCore(with: trialCore )
            
            if size == .large {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4) {
                        self.scoreVC.view.frame = CGRect(x: 0, y: screenHeight - 324, width: screenWidth, height: screenHeight)
                    }
                }

            } else {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4) {
                        self.scoreVC.view.frame = CGRect(x: 0, y: screenHeight - 219, width: screenWidth, height: screenHeight)
                    }
                }
            }
        }
    }
    
    private func hideScoreView() {
//        if rank == .boss {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.4) {
                    self.scoreVC.view.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
                }
            }
//        }
    }
    
    
    
    
    // MARK: - Basic Functions
    @objc private func startRecording() {
        shouldShowScoreView = true
        print("startRecording triggered!! ")
        if !isRecording {
            DispatchQueue.main.async {
                self.picker.startVideoCapture()
                
                let attributedTitle = NSMutableAttributedString(string: "STOP", attributes: [.font: UIFont.systemFont(ofSize: 12)])
                self.recordingBtn.setAttributedTitle(attributedTitle, for: .normal)
                
            }
            
            self.isRecording = true
            
            triggerDurationTimer()
            // 이것부터 해결하자.. ?? ??? What?
        }
    }
    
    private func stopRecording() {
        if isRecording {
            DispatchQueue.main.async {
                self.picker.stopVideoCapture()
                let attributedTitle = NSMutableAttributedString(string: "REC", attributes: [.font: UIFont.systemFont(ofSize: 12)])
                self.recordingBtn.setAttributedTitle(attributedTitle, for: .normal)
            }
            
            self.isRecording = false
//            stopTimer()
        }
//        stopTimer()
    }

    private func triggerDurationTimer() {
        
        count = 0
        
        updatingDurationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            
            guard let `self` = self else { return }
            self.count += 1
            
            self.updateDurationLabel()
        }
    }
    
    private func updateDurationLabel() {
        let recordingDuration = convertIntoRecordingTimeFormat(count)
        DispatchQueue.main.async {
            self.durationLabel.text = recordingDuration
        }
    }
    
    private func playLottie(type: LottieType) {
        switch type {
            
        case .countDown:
            countDownLottieView.play()
        }
    }
    
    private func playCountDownLottie() {
        countDownLottieView.play()
    }
    
    @objc private func triggerCountDownTimer() {
        
        DispatchQueue.main.async {
            self.durationLabel.text = "00:00"
        }
    }
    
    private func stopTimer() {
        updatingDurationTimer.invalidate()
    }
    
    private func showReconnectionGuideAction() {
        let actionSheet = UIAlertController(title: "Connection Lost", message: "Do you want to Host or Join a session?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Reconnect Session", style: .default, handler: { (action: UIAlertAction) in
            self.showConnectivityAction()
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // TODO: For now, it's ratio not accurate so that it looks weird.
    // TODO: Don't need to change for now.
    
    private func presentPreview(with videoURL: URL, size: ScoreViewSize = .large) {
        
        previewVC = PreviewController(videoURL: videoURL)
        guard let previewVC = previewVC else {
            return
        }
        let insetSize: CGFloat = size == .large ? 324 : 219
        
        addChild(previewVC)
        view.addSubview(previewVC.view)
        previewVC.view.snp.makeConstraints { make in
        
//            make.centerX.equalToSuperview()
//            make.bottom.equalTo(bottomView.snp.top)
//            make.width.height.equalTo(view.snp.width)

            make.top.equalToSuperview()
//            make.bottom.equalTo(bottomView.snp.top)
            // TODO: resize it depending on size of ScoreVC
            make.bottom.equalTo(view.snp.bottom).inset(insetSize)
            
            make.leading.trailing.equalToSuperview()
        }
    }

    private func removeChildrenVC() {
        DispatchQueue.main.async {
            guard let previewVC = self.previewVC else {
                return
            }
            
            if self.children.count > 0 {
                // 이거.. 하면 ScoreView 도 없어지는거 아님? 맞음. 이거로 방지가 되려나.. ??
                
                let viewcontrollers: [UIViewController] = self.children
                for vc in viewcontrollers {
                    
                    if vc != self.scoreVC {
                        vc.willMove(toParent: nil)
                        vc.view.removeFromSuperview()
                        vc.removeFromParent()
                    }
                }
            }
        }
    }
    
    
    func setupLayout() {
        print("present Picker!!")
        
        //        self.topView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: (screenHeight - screenWidth) / 2)
        
        
        self.bottomView.frame = CGRect(x:0, y: screenHeight - (screenHeight - screenWidth) / 2,
                                       width: screenWidth, height: (screenHeight - screenWidth) / 2)
        
        self.picker.allowsEditing = true
        self.picker.sourceType = .camera
        self.picker.delegate = self
        self.picker.mediaTypes = [kUTTypeMovie as String]
        self.picker.cameraOverlayView = self.bottomView
        self.picker.showsCameraControls = false
        self.picker.videoQuality = .typeHigh // 1080 1920
        
        self.view.addSubview(self.picker.view)
        self.picker.view.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        
        view.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo((screenHeight - screenWidth) / 2)
        }
        
        
//        topView.addSubview(dismissBtn)
//        dismissBtn.snp.makeConstraints { make in
//            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
//            make.leading.equalToSuperview().inset(16)
//            make.height.width.equalTo(24)
//        }
        
        
//        topView.addSubview(movementNameLabel)
//        movementNameLabel.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(90)
//            make.centerX.equalToSuperview()
//            make.width.equalTo(250)
//            make.height.equalTo(25)
//        }
        
        
        topView.addSubview(durationLabel)
        durationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            
//            make.bottom.equalToSuperview().inset(30)
//            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            
            make.top.equalToSuperview().offset(40)
            make.height.equalTo(40)
            make.width.equalTo(200)
        }
        
        view.addSubview(bottomView)
        
        

        

        
        bottomView.addSubview(neighborLongBar)
        neighborLongBar.snp.makeConstraints { make in
//            make.center.equalToSuperview()
            
            make.centerY.equalToSuperview().offset(5)
            make.centerX.equalToSuperview()
            
            make.width.equalToSuperview().dividedBy(2)
            make.height.equalTo(48)
        }
        
        [frontBtn, SideBtn, betweenBtn].forEach {
            //            directionStackView.addSubview($0)
            directionStackView.addArrangedButton($0)
        }
        
        bottomView.addSubview(stackViewContainer)
        stackViewContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            
            make.width.equalTo(230)
            make.height.equalTo(40)
        }
        
        
        stackViewContainer.addSubview(directionStackView)
        directionStackView.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview().inset(2)
//            make.top.equalToSuperview()
        }
        
        
        self.bottomView.addSubview(countDownLottieView)
        self.countDownLottieView.snp.makeConstraints { make in
            make.centerY.equalTo(directionStackView.snp.centerY)
            make.leading.equalToSuperview().offset(40)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        
//        directionStackView.addSubview(<#T##view: UIView##UIView#>)
//        [leftLine, rightLine].forEach { self.directionStackView.addSubview($0)}
        [leftLine, rightLine].forEach { self.stackViewContainer.addSubview($0)}
        
        
        leftLine.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(76)
//            make.leading.equalToSuperview().offset(77)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().dividedBy(2)
            make.width.equalTo(1)
        }
        
        rightLine.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-76)
//            make.trailing.equalToSuperview().offset(-77)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().dividedBy(2)
            make.width.equalTo(1)
        }
//        picker.
        
        
        
        [leftShape, rightShape].forEach { neighborLongBar.addSubview($0) }
        
        leftShape.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalTo(neighborLongBar.snp.leading).inset(24)
            make.width.height.equalTo(20)
        }
        
        rightShape.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalTo(neighborLongBar.snp.trailing).inset(24)
            make.width.height.equalTo(20)
        }
        
        bottomView.addSubview(outerRecCircle)
        outerRecCircle.addSubview(innerShape)
        outerRecCircle.addSubview(recordingBtn)
        
        self.outerRecCircle.snp.makeConstraints { make in
//            make.center.equalTo(self.bottomView.snp.center)
            make.centerY.equalToSuperview().offset(5)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(72)
        }
        
        self.innerShape.snp.makeConstraints { make in
            make.center.equalToSuperview()
            
//            make.centerY.equalToSuperview().offset(5)
//            make.centerX.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        self.recordingBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            
//            make.centerY.equalToSuperview().offset(5)
//            make.centerX.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        self.bottomView.addSubview(movementNameLabel)
        self.movementNameLabel.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(outerRecCircle.snp.bottom).offset(10)
            make.height.equalTo(30)
        }
        
        self.bottomView.addSubview(dismissBtn)
        self.dismissBtn.snp.makeConstraints { make in
            make.centerY.equalTo(outerRecCircle.snp.centerY)
            make.leading.equalToSuperview().inset(16)
            make.height.width.equalTo(24)
        }
        
    }
    
    
    //MARK: Reconnect! when it disconnected
    func showConnectivityAction() {
        let actionSheet = UIAlertController(title: "Connect Camera", message: "Do you want to Host or Join a session?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Host Session", style: .default, handler: { (action: UIAlertAction) in
            self.connectionManager.host()
            self.connectionManager.isHost = true
            self.connectionManager.numOfPeers = 0
            self.connectionManager.delegate?.updateState(state: .disconnected, connectedAmount: 0)
//            self.connectionManager.update
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Join Session", style: .default, handler: { (action: UIAlertAction) in
            self.connectionManager.join()
            self.connectionManager.isHost = false
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    // MARK: - UI Properties
    
//    private let bottomView = UIView().then { $0.backgroundColor = .white }
    private let bottomView = UIView().then { $0.backgroundColor = .clear }
    
//    private let topView = UIView().then { $0.backgroundColor = .white }
    private let topView = UIView().then { $0.backgroundColor = .clear }
        
    
    private let frontBtn = SelectableButton(title: "Front").then {
        $0.layer.cornerRadius = 4
    }
    private let SideBtn = SelectableButton(title: "Side").then {
        $0.layer.cornerRadius = 4
        $0.backgroundColor = .blue
    }
    private let betweenBtn = SelectableButton(title: "45°").then {
        $0.layer.cornerRadius = 4
        
    }
    
//    private let
    
//    private let directionStackView = SelectableButtonStackView(selectedBGColor: .purple500, defaultBGColor: .white, selectedTitleColor: .white, defaultTitleColor: .gray600, spacing: 2, cornerRadius: 6)
    
    private let directionStackView = SelectableButtonStackView(selectedBGColor: .transPurple500, defaultBGColor: UIColor(white: 0.9, alpha: 0.6), selectedTitleColor: .white, defaultTitleColor: .gray600, spacing: 2, cornerRadius: 6)
    
//        .then {
        //        $0.backgroundColor = .magenta
//        $0.layer.borderWidth = 1
//        $0.layer.borderColor = UIColor.blueGray200.cgColor
//        $0.clipsToBounds = true
//    }
    
    private let stackViewContainer = UIView().then {
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.blueGray200.cgColor
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 6
    }
    
    private let movementNameLabel = UILabel().then {
//        $0.textColor = .black
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 20)
        //        $0.numberOfLines = 0
        $0.adjustsFontSizeToFitWidth = true
    }
    
    private let imageView = UIImageView()
    
    private let connectionStateLabel = UILabel().then {
        $0.textColor = .white
    }
    
    private let durationLabel = UILabel().then {
        $0.textColor = .white
        $0.text = "00:00"
        $0.textAlignment = .center
        $0.layer.cornerRadius = 20
        $0.backgroundColor = .lavenderGray700
        $0.clipsToBounds = true
    }
    
    private let dismissBtn: UIButton = {
        let btn = UIButton()
        let innerImage = UIImageView(image: UIImage(systemName: "chevron.left"))
//        innerImage.tintColor = .black
        innerImage.tintColor = .white
        btn.addSubview(innerImage)
        
        innerImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
            make.height.equalToSuperview()
        }
        
        return btn
    }()
    
    private let outerRecCircle = UIView().then {
        $0.backgroundColor = .red
        $0.layer.cornerRadius = 36
    }
    
    private let innerShape = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 18
    }
    
    private let neighborLongBar = UIView().then {
        $0.backgroundColor = .lavenderGray100
        $0.layer.cornerRadius = 24
    }
    
    private let leftShape = UIView().then {
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .lavenderGray300
    }
    
    private let rightShape = UIView().then {
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .lavenderGray300
    }
    
    private let recordingBtn = UIButton().then {
        let attributedTitle = NSMutableAttributedString(string: "REC", attributes: [.font: UIFont.systemFont(ofSize: 12)])
        $0.setAttributedTitle(attributedTitle, for: .normal)
        $0.setTitleColor(.red, for: .normal)
    }
    
    /// animation from Vikky
//    private let countDownLottieView = AnimationView(name: "countDown").then {
    private let countDownLottieView = AnimationView(name: "countDownLottie").then {
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .playOnce
    }
    
    private let completeMsgView = UIView().then { $0.backgroundColor = .white }
    
    private let retryBtn = UIButton().then { $0.setTitle("Retry", for: .normal)
        $0.setTitleColor(.gray900, for: .normal)
        $0.layer.borderColor = UIColor.lavenderGray100.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .lavenderGray50
        $0.clipsToBounds = true
    }
    
    private let homeBtn = UIButton().then { $0.setTitle("Home", for: .normal)
        $0.backgroundColor = .lavenderGray300
        //        $0.layer.borderColor = UIColor.lavenderGray100.cgColor
        //        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.setTitleColor(.gray900, for: .normal)
    }
    
//    private let checkmarkLottieView = AnimationView(name: "checkmark").then {
    private let completeLottieView = AnimationView(name: "completeLottie2").then {
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .playOnce
//        $0.backgroundColor = .white
//        $0.backgroundColor = .magenta
    }
    
//    private let completeMsgLabel = UILabel().then {
//        //    private let completeMsgLabel = UITextView().then {
//        let paragraph = NSMutableParagraphStyle()
//        paragraph.alignment = .center
//
//        let attrText = NSMutableAttributedString(string: "Upload Completed!\n hihi", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .bold), .foregroundColor: UIColor.gray900, .paragraphStyle: paragraph])
//
//        attrText.append(NSAttributedString(string: "Contrats!\nYour video has been successfully uploaded.", attributes: [
//            .font: UIFont.systemFont(ofSize: 17),
//            .foregroundColor: UIColor.gray600,
//            .paragraphStyle: paragraph]))
//
//        attrText.append(NSAttributedString(string: "Your video has been successfully uploaded", attributes: [
//            .font: UIFont.systemFont(ofSize: 15),
//            .paragraphStyle: paragraph
//        ]))
//
//        $0.attributedText = attrText
//        $0.numberOfLines = 0
//    }
    
    private let completeMsgLabel = UILabel().then {
        //    private let completeMsgLabel = UITextView().then {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let attrText = NSMutableAttributedString(string: "Upload Completed\n", attributes: [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor.gray900,
            .paragraphStyle: paragraph]
        )
        
        attrText.append(NSAttributedString(string: "\n", attributes: [
            .font: UIFont.systemFont(ofSize: 10)
        ]))
        
        attrText.append(NSAttributedString(string: "Congrats!\n Video has been successfully uploaded.", attributes: [
            .font: UIFont.systemFont(ofSize: 17),
            .foregroundColor: UIColor.gray600,
            .paragraphStyle: paragraph]))
        
        $0.attributedText = attrText
        $0.numberOfLines = 0
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UIImagePickerController Delegate
extension CameraController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //        picker.dismiss(animated: true)
        self.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("imagePickerController didFinishPickingMedia called!")
        //        var videoUrl: URL?
        if shouldShowScoreView {
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
              mediaType == (kUTTypeMovie as String),
              let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
              UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
        else {
            print("failed to get url Path!")
            return
        }
        
        print("save success !")
        // Save Video To Photos Album
//        UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, nil, nil)

        UISaveVideoAtPathToSavedPhotosAlbum("hi", self, nil, nil)

        
        videoUrl = url
        
        guard let validUrl = videoUrl else { fatalError() }
        saveVideoToLocal(with: validUrl)
            
        let cropController = CropController(url: validUrl, vc: self)
        
            let size: ScoreViewSize = Dummy.getPainTestName(from: positionTitle, direction: direction) != nil ? .large : .small
            
//            DispatchQueue.main.async {
//                self.presentPreview(with: validUrl, size: size)
//                self.prepareScoreView()
//                self.showScoreView(size: size)
//            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.presentPreview(with: validUrl, size: size)
                                self.prepareScoreView()
                                self.showScoreView(size: size)
            }
            
        
        print("url: \(url.path)")
        
        
        // TODO: Present Preview In a second
        
//        let size: ScoreViewSize = Dummy.getPainTestName(from: positionTitle, direction: direction) != nil ? .large : .small
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.presentPreview(with: url)
//            self.prepareScoreView()
//
//            self.showScoreView(size: size)
        }
        } else {
            shouldShowScoreView.toggle()
        }
    }
}

// MARK: - Connection Manager Delegate


//    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
//      let title = (error == nil) ? "Success" : "Error"
//      let message = ( error == nil) ? "Video was saved" : "Video failed to save"
//
//      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//
//      alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
//      present(alert, animated: true)
//
//    }


extension CameraController: ConnectionManagerDelegate {
    func updateState(state: ConnectionState, connectedAmount: Int) {
        switch state {
        case .disconnected:
            print("disconnected!")
            connectionManager.numOfPeers = 0
            DispatchQueue.main.async {

//                self.connectionStateLabel.text = "Disconnected!"
                //                self.showConnectivityAction()
                if self.connectionManager.isHost == false {
                    print("disconnect flag 1")
                    self.showReconnectionGuideAction()
                    print("disconnect flag 2")
                }
                print("disconnect flag 3")
                // TODO: Update UI to notify disconnection
                self.changeMode(target: nil, mode: .onRecording)
                print("disconnect flag 4")
            }
            print("disconnect flag 5")
            resetRecording()
            print("disconnect flag 6")
        case .connected:
            print("connected!")
//            self.connectedAmount = connectedAmount
            self.connectionManager.numOfPeers = connectedAmount
//            switch connectedAmount {
            switch self.connectionManager.numOfPeers {
            case 1: self.changeMode(target: .left, mode: .stop)
            case 2: self.changeMode(target: .both, mode: .stop)
            default: break
            }
        }
    }
    
    private func showCompleteMsgView() {
        UIView.animate(withDuration: 0.4) {
            self.completeMsgView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        } completion: { done in
            if done {
                self.completeLottieView.play()
            }
        }
    }
    
    
    public func hidePreview() {
        guard let previewVC = previewVC else {
//            fatalError()
            return
        }
        DispatchQueue.main.async {
            previewVC.view.isHidden = true
        }

    }
    
}


extension CameraController: ScoreControllerDelegate {
    
    func presentCompleteMsgView(shouldShowNext: Bool) {
        
    }
    
    // TODO: Currently not being called ;; why ?
    func orderRequest(core: TrialCore, detail: TrialDetail) {
        
        printFlag(type: .peerRequest, count: 1)
        
        let title = core.title
        guard let direction = MovementDirection(rawValue: core.direction) else { fatalError() }
        
        let optionalScore = detail.score.scoreToInt()
        let optionalPain = detail.isPainful .painToBool()
        
        printFlag(type: .peerRequest, count: 2)
        // TODO: type 이 달라야함.
        
        connectionManager.send(PeerInfo(msgType: .requestPostMsg, info: Info(movementDetail: MovementDirectionScoreInfo(title: title, direction: direction, score: optionalScore, pain: optionalPain))))
    
        printFlag(type: .peerRequest, count: 3)

    }
    

    func navigateToSecondView(withNextTitle: Bool) {
        print("navigateToSecondView Triggered")
        setupCompleteView(withNextTitle: withNextTitle)
        showCompleteMsgView()
        hideScoreView()
        hidePreview()
    }
    
    
    func updatePressedBtnTitle(with btnTitle: String) {
        pressedBtnTitle = btnTitle
    }
    
    func nextAction() {
        // TODO: Dismiss Camera
    }
    
    func retryAction() {
        //
        //TODO:  Upload to the Server, and Redo
        
        resetTimer()
        removeChildrenVC()
        prepareScoreView()
//        makeTrialDetail()
        hideCompleteMsgView()
        scoreVC.changeSaveBtnColor()
//        self.updateTrialDetail()
    }
    
    private func makeTrialDetail() {
        TrialDetail.save(belongTo: trialCore)
    }
    
    private func resetRecording() {
        stopRecording()
        deleteAction()
        // TODO: DismissPreview
//        hidePreview()
    }
    
    // TODO: Fix if necessary
    func deleteAction() {
        connectionManager.send(PeerInfo(msgType: .hidePreviewMsg, info: Info()))
//        guard let validVideoUrl = videoUrl else { fatalError() }
        if let videoUrl = videoUrl {
            deleteVideo(with: videoUrl)
        }
        
        // initialize selected score
        
        prepareRecording()
//        updateNameLabel()
//        removeChildrenVC()
//        resetTimer()
        hideScoreView()
        
        self.shouldShowScoreView = false
    }
    
    
    private func deleteVideo(with url: URL) {
        do {
            try FileManager().removeItem(at: url)
//            print("file exist ? 2 \(FileManager().fileExists(atPath: url.path))")
//            print("successfully deleted video !") // ?? 삭제 안됐는데 ?
        } catch {
//            print("error: \(error.localizedDescription)")
//            print("file exist ? 3 \(FileManager().fileExists(atPath: url.path))")
        }
    }
    
    func saveVideoToLocal(with url: URL) {
        //        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //        let documentsDirectoryURL = paths[0]
//        print("duration: \(self.testDuration)")
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
//            PHAssetChangeRequest.
        }
    }
    
    func saveAction(core: TrialCore, detail: TrialDetail) {
        
        guard let validVideoUrl = videoUrl else { return }
        print("-----------CameraController trialCore Details -----------")
        print("trial : \(core.title), \(core.direction), \(detail.trialNo)")
        

        if croppedUrl != nil {
            print("croppedUrl is valid")
            self.saveVideoToLocal(with: croppedUrl!)
        } else {
            print("croppedUrl is nil")
        }
    
        let trialId = UUID()
        guard let direction = MovementDirection(rawValue: core.direction) else { return }
        
        let optionalScore = detail.score.scoreToInt()
        let optionalPain = detail.isPainful .painToBool()
        
        guard let cameraDirection = cameraDirection else { return }
        APIManager.shared.postRequest(
            movementDirectionScoreInfo:
                MovementDirectionScoreInfo(
                title: core.title, direction: direction, score: optionalScore, pain: optionalPain),
            trialCount: Int(detail.trialNo), trialId: trialId,
            videoUrl: validVideoUrl, angle: cameraDirection) {
                print("closure called after post request")
            }
    }
    
    
    /// merge Position Title + Direction  into Unique Key
    private func mergeKeys(title: String, direction: String) -> String {
        return title + direction
    }
    

    
    func prepareRecording() {
        updateNameLabel()
        removeChildrenVC()
        resetTimer()
//        hideScoreView()
//        hidePreview()
//        hidePreview2()
    }
}
