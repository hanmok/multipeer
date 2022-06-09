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
    
    var positionTitle: String
    var direction: MovementDirection
    
    var trialCore: TrialCore
    
    var systemSoundID: SystemSoundID = 1057

    var timeDifference: CGFloat = 0 // or CMTime
        
    var rank: Rank
    
    private var pressedBtnTitle = ""
    
    var updatingDurationTimer = Timer()
    var decreasingTimer = Timer()
    
    var count = 0
//    var decreasingCount = 3
    
    var isRecordingEnded = false
    
    weak var delegate: CameraControllerDelegate?
    
    var connectionManager: ConnectionManager
    
    private var picker = UIImagePickerController()
    
    var previewVC: PreviewController?
    
    private var scoreVC: ScoreController
    
    private var isRecording = false
    
    private let shouldRecordLater = false
    
    var variationName: String?
    var trialDetail: TrialDetail?
    var sequentialPainPosition: String?
    
    
    
    // MARK: - Life Cycle
    
//    deinit {
//        print("cameraController deinit")
//    }
    
    init(
        connectionManager: ConnectionManager,
//        screen: Screen,
        trialCore: TrialCore,
        rank: Rank) {
            
            self.connectionManager = connectionManager
            
//            self.screen = screen
            self.trialCore = trialCore
            self.positionTitle = trialCore.title
            
            guard let direction = MovementDirection(rawValue: trialCore.direction) else { fatalError() }
            
            self.direction = direction
            
            scoreVC = ScoreController(positionTitle: trialCore.title, direction: trialCore.direction)
            
            self.rank = rank
            
            super.init(nibName: nil, bundle: nil)
            connectionManager.delegate = self
            scoreVC.delegate = self
            scoreVC.parentController = self
            
            setupTrialDetail(with: trialCore)
            
            print("cameraController init")
        }


    private func setupTrialDetail(with core: TrialCore) {
        trialDetail = trialCore.returnFreshTrialDetail()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CameraController viewdidLoad triggered")
        updateNameLabel()
        setupAddTargets()
        setupLayout()
        addNotificationObservers()
        updateInitialConnectionState()
        
        setupCompleteView()
        
        updatePeerTitle()
    }
    
    
    private func updatePeerTitle() {

        let direction: MovementDirection = MovementDirection(rawValue: trialCore.direction) ?? .neutral
        
//        connectionManager.send(MsgWithMovementDetail(message: .updatePeerTitle, detailInfo: MovementDirectionScoreInfo(title: trialCore.title, direction: direction)))
        connectionManager.send(MsgWithMovementDetail(message: .updatePeerTitle, detailInfo: MovementDirectionScoreInfo(title: positionTitle, direction: direction)))
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("cameraController viewWillDisappear ")
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
    
    private func resetTimer() {
        durationLabel.text = "00:00"
    }
    
    
    func updateInitialConnectionState() {
        print(#file, #line)
        switch connectionManager.connectionState {
        case .connected:
            DispatchQueue.main.async {
                self.connectionStateLabel.text = "Connected!"
            }
        case .disconnected:
            DispatchQueue.main.async {
                self.connectionStateLabel.text = "Disconnected!"
            }
        }
    }
    
    // MARK: - Notification
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(startRecordingNowNoti(_:)),
                                               name: .startRecordingKey, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopRecordingNoti(_:)),
                                               name: .stopRecordingKey, object: nil)
        
        
//        NotificationCenter.default.addObserver(self, selector: #selector(startRecordingAtNoti(_:)),
//                                               name: .startRecordingAfterKey, object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(startCountdownAtNoti(_:)),
//                                               name: .startCountdownAfterKey, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateConnectionStateNoti(_:)),
                                               name: .updateConnectionStateKey, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(requestPostNoti(_:)), name: .requestPostKey, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePeerTitleNoti(_:)), name: .updatePeerTitleKey, object: nil)
    }
    
    @objc func updatePeerTitleNoti(_ notification: Notification) {

        guard let title = notification.userInfo?["title"] as? String,
              let direction = notification.userInfo?["direction"] as? MovementDirection
                
        else { return }
        
        DispatchQueue.main.async {
            if self.direction == .neutral {
                self.movementNameLabel.text = title
            } else {
                self.movementNameLabel.text = title + " " + direction.rawValue
            }
        }
    }
    
    @objc func requestPostNoti(_ notification: Notification) {
        
//        saveAction(core: <#T##TrialCore#>, detail: <#T##TrialDetail#>)
    
    }
    
    @objc func startRecordingNowNoti(_ notification: Notification) {
        print("startRecording has been triggered by observer. ")
        guard let title = notification.userInfo?["title"] as? String,
              let direction = notification.userInfo?["direction"] as? MovementDirection,
              let score = notification.userInfo?["score"] as? Int? else { return }
        
        // TODO: 정보는,, Score 가 알아야하나 Camera가 알아야하나.. ?? 굳이 따지면 Camera
        // TODO: 그런데, 몰라도 될 것 같음.
        
        // remove preview if master order recording
        removeChildrenVC()
        
        startRecording()
        changeBtnLookForRecording(animation: false)
//        recordingBtnAction()
        // duration update needed ??
    
    }
    
    
    @objc func stopRecordingNoti(_ notification: Notification) {
        print("stopRecording has been triggered by observer. ")
        
        guard let title = notification.userInfo?["title"] as? String,
              let direction = notification.userInfo?["direction"] as? MovementDirection,
              let score = notification.userInfo?["score"] as? Int? else { return }
        
        stopRecording()
        changeBtnLookForPreparing(animation: false)
    }
    
    
    // not recommended
    @objc func startCountdownAtNoti(_ notification: Notification) {
        guard let milliTime = notification.userInfo?["receivedTime"] as? Int,
              //              let msg = notification.userInfo?["msg"] as? RecordingType
              let msg = notification.userInfo?["msg"] as? MessageType
        else {
            print("success to convert receivedTime to Int", #line)
            // millisec since 1970
            return
        }
        
        let countdownTimer = Timer(fireAt: Date(milliseconds: milliTime), interval: 0, target: self, selector: #selector(triggerCountDownTimer), userInfo: nil, repeats: false)
        print("startCountdownAfter has triggered", #line)
    }
    
    // this one called!!
    @objc func updateConnectionStateNoti(_ notification: Notification) {
        print(#file, #line)
        guard let state = notification.userInfo?["connectionState"] as? ConnectionState else {
            print("failed to get connectionState normally")
            return }
        switch state {
        case .disconnected:
            DispatchQueue.main.async {
                self.connectionStateLabel.text = "Disconnected!"
                if self.connectionManager.isHost == false {
                    self.showReconnectionGuideAction()
                }
            }
        case .connected:
            DispatchQueue.main.async {
                self.connectionStateLabel.text = "Connected!"
            }
        }
    }
    
    
    
    // MARK: - Button Actions
    private func setupAddTargets() {
        dismissBtn.addTarget(self, action: #selector(dismissBtnTapped(_:)), for: .touchUpInside)
        recordingTimerBtn.addTarget(self, action: #selector(timerRecordingBtnTapped(_:)), for: .touchUpInside)
        nextBtn.addTarget(self, action: #selector(nextTapped(_:)), for: .touchUpInside)
        
        retryBtn.addTarget(self, action: #selector(retryTapped(_:)), for: .touchUpInside)
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
//            if positionTitle == MovementList.deepSquat.rawValue {
//                positionTitle = movementWithVariation[positionTitle]!
//            }
            
            variationName = movementWithVariation[positionTitle]
            print("variation : \(variationName)")
            if variationName != nil {
                print("variation is valid!!")
                self.positionTitle = variationName!
                updateNameLabel()
                
                count = 0
                updateDurationLabel()
                print("current title from nextTapped: \(positionTitle)")
                
                scoreVC.setupAgain(positionTitle: self.positionTitle, direction: direction)
                
                updatePeerTitle()
            } else { print("variation is valid!! nope!!") }
            
            hideCompleteMsgView()
        }
    }
    
    private func hideCompleteMsgView() {
        UIView.animate(withDuration: 0.4) {
            self.completeMsgView.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
        }
    }
    
    
    @objc func retryTapped(_ sender: UIButton) {
        retryAction()
    }
    
    
    
    @objc func recordingBtnTapped(_ sender: UIButton) {
        print("recordingBtn Tapped!!")
        
        recordingBtnAction()
    }
    
    private func changeBtnLookForRecording(animation: Bool) {
        if animation {
            UIView.animate(withDuration: 0.4) {
                self.outerRecCircle.backgroundColor = .lavenderGray900
                self.innerShape.layer.cornerRadius = 6
                self.recordingTimerBtn.setTitleColor(.gray900, for: .normal)
                
                self.leftShape.layer.cornerRadius = 2
                self.leftShape.backgroundColor = .lavenderGray400
            }
        } else {
            DispatchQueue.main.async {
                self.outerRecCircle.backgroundColor = .lavenderGray900
                self.innerShape.layer.cornerRadius = 6
                self.recordingTimerBtn.setTitleColor(.gray900, for: .normal)
                
                self.leftShape.layer.cornerRadius = 2
                self.leftShape.backgroundColor = .lavenderGray400
            }

        }
    }
    private func changeBtnLookForPreparing(animation: Bool ) {
        if animation {
        UIView.animate(withDuration: 0.4) {
            self.outerRecCircle.backgroundColor = .red
            self.innerShape.layer.cornerRadius = 18
            self.recordingTimerBtn.setTitleColor(.red, for: .normal)
            
            self.leftShape.layer.cornerRadius = 10
            self.leftShape.backgroundColor = .red
        }
        } else {
            DispatchQueue.main.async {
                self.outerRecCircle.backgroundColor = .red
                self.innerShape.layer.cornerRadius = 18
                self.recordingTimerBtn.setTitleColor(.red, for: .normal)
                
                self.leftShape.layer.cornerRadius = 10
                self.leftShape.backgroundColor = .red
            }
        }
    }
    
    @objc func recordingBtnAction() {
        // Start Recording!!
        removeChildrenVC()
        if !isRecording {
            
            connectionManager.send(MsgWithMovementDetail(message: .startRecordingMsg, detailInfo: MovementDirectionScoreInfo(title: positionTitle, direction: direction, score: nil)))
            
            
            startRecording()
            
            changeBtnLookForRecording(animation: true)
            
        } else {
            
            stopRecording()
            

            changeBtnLookForPreparing(animation: true)
            
            // Send Stop Msg
            // start, stop 할 때가 아닌,  Save 눌렀을 때 Core Info 를 전달해야함.
            
            connectionManager.send(MsgWithMovementDetail(message: .stopRecordingMsg, detailInfo: MovementDirectionScoreInfo(title: positionTitle, direction: direction, score: nil)))
        }
    }
    
    @objc func dismissBtnTapped(_ sender: UIButton) {
        print("dismiss btn tapped!")
        self.dismiss(animated: true)
        // 왜 dismiss 가 안되지?
        delegate?.dismissCamera() {
            self.dismiss(animated: true)
        }
//        self.dismiss(animated: true)
//        delegate
    }
    
    @objc func timerRecordingBtnTapped(_ sender: UIButton) {
        
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
    
    private func setupCompleteView() {
        
        view.addSubview(completeMsgView)
        
        completeMsgView.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
        

        [checkmarkLottieView,completeMsgLabel, retryBtn, nextBtn].forEach { completeMsgView.addSubview($0)}
        
        checkmarkLottieView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalToSuperview().dividedBy(10)
            make.centerY.equalToSuperview().offset(-70)
        }
        
        completeMsgLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalTo(40)
            make.top.equalTo(checkmarkLottieView.snp.bottom).offset(15)
        }
        
        retryBtn.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalToSuperview().dividedBy(3)
        }
        
        nextBtn.snp.makeConstraints { make in
            make.leading.equalTo(retryBtn.snp.trailing)
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(60)
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
    }
    
    // TODO: need to change trialCore of scoreVC here (why ?
    private func showScoreView() {
        if rank == .boss {
        scoreVC.setupTrialCore(with: trialCore )
        
        UIView.animate(withDuration: 0.4) {
            self.scoreVC.view.frame = CGRect(x: 0, y: screenHeight - 330, width: screenWidth, height: screenHeight)
        }
        }
    }
    
    private func hideScoreView() {
        if rank == .boss {
        UIView.animate(withDuration: 0.4) {
            self.scoreVC.view.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
        }
        }
    }
    
    
    
    
    // MARK: - Basic Functions
    @objc private func startRecording() {
        print("startRecording triggered!! ")
        if !isRecording {
            DispatchQueue.main.async {
                self.picker.startVideoCapture()

                let attributedTitle = NSMutableAttributedString(string: "STOP", attributes: [.font: UIFont.systemFont(ofSize: 12)])
                self.recordingTimerBtn.setAttributedTitle(attributedTitle, for: .normal)
                
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
                self.recordingTimerBtn.setAttributedTitle(attributedTitle, for: .normal)
            }
            
            self.isRecording = false
            stopTimer()
        }
    }
    
    
    /// updating durationLabel contained
    private func triggerDurationTimer() {
        count = 0
        
        //        print("timer triggered!!")
        // 여기까지 일을 하는데, 아래는 안가네 ? 왜지 ?? 몰러
        
        updatingDurationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let `self` = self else {
                print("self is nil in timer!!")
                return }
            
            //            print("trigger working!") // 왜.. 시행하는 쪽에서만 되냐 ?? 아님. 받는 쪽에서도 작동하넹.
            self.count += 1
            
            self.updateDurationLabel()
        }
    }
    

    private func updateDurationLabel() {
        
        let recordingDuration = convertIntoRecordingTimeFormat(count)
        
        DispatchQueue.main.async {
            self.durationLabel.text = recordingDuration // is this code working?
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
        
        
        
        
        //        decreasingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
        //            self?.delegate?.makeSound()
        ////            print("triggerCoundDownTimerFlag 1 called")
        //            guard let `self` = self else { return }
        //            print("triggerCoundDownTimerFlag 2 called")
        //
        //            if self.decreasingCount > 0 {
        //                print("triggerCoundDownTimerFlag 3 called")
        //                self.decreasingCount -= 1
        ////                SoundService.shard.someFunc()
        ////                AudioServicesPlaySystemSound(self.systemSoundID)
        //
        //
        //                print("triggerCoundDownTimerFlag 4 called")
        //
        //                if self.decreasingCount == 0 { // ????
        //                    print("triggerCoundDownTimerFlag 5 called")
        ////                    AudioServicesPlaySystemSound(self.systemSoundID)
        //                    DispatchQueue.main.async {
        //                        self.recordingTimerBtn.setTitle("Recording!", for: .normal)
        //                    }
        //                } else {
        //                    // 세번 호출되어야함
        //                        // 왜 두번밖에 호출되지 않았지 ?
        //                        print("triggerCoundDownTimerFlag 6 called, decreasingCount : \(self.decreasingCount)")
        //                        // make sound
        //
        ////                        AudioServicesPlaySystemSound(self.systemSoundID)
        ////                        AudioServicesPlaySystemSound(1104)
        //
        ////                        AudioServicesPlaySystemSound(1052)
        //                        DispatchQueue.main.async {
        //                        self.recordingTimerBtn.setTitle(String(self.decreasingCount), for: .normal)
        //                        }
        //                    }
        ////                }
        //            } else { // self.decreasingCount <= 0
        //                print("triggerCoundDownTimerFlag 7 called")
        //                self.decreasingTimer.invalidate()
        //                //                DispatchQueue.main.async {
        //                //                    self.timerRecordingBtn.setTitle("Recording!", for: .normal)
        //                //                }
        //                self.decreasingCount = 3
        //            }
        //        }
        
        
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
    
    private func presentPreview(with videoURL: URL) {
        
        previewVC = PreviewController(videoURL: videoURL)
        guard let previewVC = previewVC else {
            return
        }
        
        addChild(previewVC)
        view.addSubview(previewVC.view)
        previewVC.view.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
            make.width.height.equalTo(view.snp.width)
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
        
        self.view.addSubview(self.picker.view)
        self.picker.view.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        
        view.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo((screenHeight - screenWidth) / 2)
        }
        
        
        topView.addSubview(dismissBtn)
        dismissBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(90)
            make.leading.equalToSuperview().inset(16)
            make.height.width.equalTo(20)
        }
        
        
        topView.addSubview(movementNameLabel)
        movementNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(90)
            make.centerX.equalToSuperview()
            make.width.equalTo(250)
            make.height.equalTo(25)
        }
        
        
        topView.addSubview(durationLabel)
        durationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(30)
            make.height.equalTo(40)
            make.width.equalTo(200)
        }
        
        view.addSubview(bottomView)
        
        
        self.bottomView.addSubview(countDownLottieView)
        self.countDownLottieView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(30)
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        bottomView.addSubview(neighborLongBar)
        neighborLongBar.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
            make.height.equalTo(48)
        }
        
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
        outerRecCircle.addSubview(recordingTimerBtn)
        
        self.outerRecCircle.snp.makeConstraints { make in
            make.center.equalTo(self.bottomView.snp.center)
            make.height.width.equalTo(72)
        }
        
        self.innerShape.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        self.recordingTimerBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
    }
    
    
    //MARK: Reconnect! when it disconnected
    func showConnectivityAction() {
        let actionSheet = UIAlertController(title: "Connect Camera", message: "Do you want to Host or Join a session?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Host Session", style: .default, handler: { (action: UIAlertAction) in
            self.connectionManager.host()
            self.connectionManager.isHost = true
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Join Session", style: .default, handler: { (action: UIAlertAction) in
            self.connectionManager.join()
            self.connectionManager.isHost = false
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    // MARK: - UI Properties
    
    private let bottomView = UIView().then { $0.backgroundColor = .white }
    private let topView = UIView().then { $0.backgroundColor = .white }
    
    private let movementNameLabel = UILabel().then {
        $0.textColor = .black
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
        $0.layer.cornerRadius = 24
        $0.backgroundColor = .lavenderGray700
        $0.clipsToBounds = true
    }
    
    private let dismissBtn: UIButton = {
        let btn = UIButton()
        let innerImage = UIImageView(image: UIImage(systemName: "chevron.left"))
        innerImage.tintColor = .black
        btn.addSubview(innerImage)
        
        innerImage.snp.makeConstraints { make in
//            make.top.leading.trailing.bottom.equalToSuperview()
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
        $0.backgroundColor = .red
    }
    
    private let rightShape = UIView().then {
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .lavenderGray300
    }
    
    private let recordingTimerBtn = UIButton().then {
        let attributedTitle = NSMutableAttributedString(string: "REC", attributes: [.font: UIFont.systemFont(ofSize: 12)])
        $0.setAttributedTitle(attributedTitle, for: .normal)
        $0.setTitleColor(.red, for: .normal)
    }
    
    /// animation from Vikky
    private let countDownLottieView = AnimationView(name: "countDown").then {
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .playOnce
    }
    
    private let completeMsgView = UIView().then { $0.backgroundColor = .white }
    private let retryBtn = UIButton().then { $0.setTitle("Retry", for: .normal)
        $0.setTitleColor(.gray900, for: .normal)
        $0.layer.borderColor = UIColor.lavenderGray100.cgColor
        $0.layer.borderWidth = 1
    }
    
    private let nextBtn = UIButton().then { $0.setTitle("Next", for: .normal)
        $0.backgroundColor = .lavenderGray300
        $0.layer.borderColor = UIColor.lavenderGray100.cgColor
        $0.layer.borderWidth = 1
    }
    
    private let checkmarkLottieView = AnimationView(name: "checkmark").then {
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .playOnce
    }
    
    private let completeMsgLabel = UILabel().then {
//    private let completeMsgLabel = UITextView().then {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        var attrText = NSMutableAttributedString(string: "Upload Completed!\n", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .bold), .foregroundColor: UIColor.gray900, .paragraphStyle: paragraph])
        
        attrText.append(NSAttributedString(string: "Contrats!\nYour video has been successfully uploaded.", attributes: [
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
        
        //        var videoUrl: URL?
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
        UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, nil, nil)
        
        videoUrl = url

        guard let validUrl = videoUrl else { fatalError() }
        let cropController = CropController(url: validUrl, vc: self)
        cropController.exportVideo()

        print("url: \(url.path)")
        
        
        // TODO: Present Preview In a second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.presentPreview(with: url)
            self.prepareScoreView()
            self.showScoreView()
        }
    }
    
    
    private func updateTrialCore() {
        
    }
    
    private func updateTrialDetail() {
        
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
    func updateState(state: ConnectionState, connectedNum: Int) {
        switch state {
        case .disconnected:
            DispatchQueue.main.async {
                print(#file, #line)
                self.connectionStateLabel.text = "Disconnected!"
                //                self.showConnectivityAction()
                print("showReconnectionGuideAction!")
                if self.connectionManager.isHost == false {
                    self.showReconnectionGuideAction()
                }
            }
            
        case .connected:
            DispatchQueue.main.async {
                self.connectionStateLabel.text = "Connected!"
            }
        }
    }
    
    func updateDuration(in seconds: Int) {
        
    }
    
    private func showCompleteMsgView() {
        UIView.animate(withDuration: 0.4) {
            self.completeMsgView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        } completion: { done in
            if done {
            self.checkmarkLottieView.play()
            }
        }
    }
    
    
    private func hidePreview() {
        guard let previewVC = previewVC else {fatalError()}
        previewVC.view.isHidden = true
    }
}


extension CameraController: ScoreControllerDelegate {
    
    func orderRequest(core: TrialCore, detail: TrialDetail) {
//        connectionManager.send
        saveAction(core: core, detail: detail)
//        connectionManager.send
    }
    
    func navigateToSecondView() {
        print("navigateToSecondView Triggered")
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
        //TODO:  Upload to the Server, and Redo
        resetTimer()
        removeChildrenVC()
        prepareScoreView()
        makeTrialDetail()
        
        self.updateTrialDetail()
    }
    
    private func makeTrialDetail() {
        TrialDetail.save(belongTo: trialCore)
    }
    
    // TODO: Fix if necessary
    func deleteAction() {
        // 왜 제거가 안됨 ?? ;;; 글쎄다
        guard let validVideoUrl = videoUrl else { fatalError() }
        print("file exist ? 1 \(FileManager().fileExists(atPath: validVideoUrl.path))")
        do {
            try FileManager().removeItem(at: validVideoUrl)
            print("file exist ? 2 \(FileManager().fileExists(atPath: validVideoUrl.path))")
            print("successfully deleted video !") // ?? 삭제 안됐는데 ?
        } catch {
            print("error: \(error.localizedDescription)")
            print("file exist ? 3 \(FileManager().fileExists(atPath: validVideoUrl.path))")
        }
        // initialize selected score
        
        prepareRecording()
    }
    
    
    func saveAction(core: TrialCore, detail: TrialDetail) {
        
        guard let validVideoUrl = videoUrl else { return }
        
        let trialId = UUID()
        guard let direction = MovementDirection(rawValue: core.direction) else { return }
        
        let optionalScore = detail.score.scoreToInt()
        let optionalPain = detail.isPainful .painToBool()
        
//        print("Data to post \n title: \(core.title),\n direction: \(direction.rawValue), \n score: \(String(describing: optionalScore)), \n pain: \(optionalPain), \n trialCount: trialCount: \(detail.trialNo),\n trialId: trialId: \(trialId)")
        
        APIManager.shared.postRequest(
            movementDirectionScoreInfo: MovementDirectionScoreInfo(
                title: core.title, direction: direction, score: optionalScore, pain: optionalPain),
            trialCount: Int(detail.trialNo), trialId: trialId,
            videoUrl: validVideoUrl, angle: .front)
    }
    
    
    /// merge Position Title + Direction  into Unique Key
    private func mergeKeys(title: String, direction: String) -> String {
        return title + direction
    }
    
    // triggered if 'Next' Tapped
    
    
    
    func prepareRecording() {
        updateNameLabel()
        removeChildrenVC()
        resetTimer()
        hideScoreView()
    }
}
