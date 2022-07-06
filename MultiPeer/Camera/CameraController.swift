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

extension CameraController: FileManagerDelegate {
    
}

//CameraController don't need to know 'score'
class CameraController: UIViewController {
    
    // MARK: - Properties
    //    let sampleInspector = Inspector(name: "hanmok", phoneNumber: "01090417421")
    
    private var videoUrl: URL?
    var shouldShowScoreView = true
    // TODO: Handle inside ConnectionManager
    // TODO: duplicate check, send msg if direction assigned.
    
    var croppedUrl: URL?
    
    var currentDeviceStartedCapturingTime: Int64?
    var timeDiff: Int64?
    var positionTitle: String
    
    var direction: MovementDirection
    
    var cameraDirection: CameraDirection?
    
    var trimmingController: TrimmingController?
    
    //    var connectedAmount: Int = 0
    
    var trialCore: TrialCore?
    
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
    
    private var scoreVC: ScoreController?
    
    private var isRecording = false
    
    //    private let shouldRecordLater = false
    private let shouldRecordLater = false
    
    var variationName: String?
    
    var trialDetail: TrialDetail?
    
    var screen: Screen?
    
    var subjectName: String?
//    var subjectName: String
    // MARK: - Life Cycle
    
    public func updateLabel(title: String, direction: MovementDirection) {
        movementNameLabel.text = "\(title) \(direction.rawValue)"
    }
    
    init(
        connectionManager: ConnectionManager,
        screen: Screen?,
        trialCore: TrialCore?,
        
        positionTitle: String,
        direction: MovementDirection,
        
        rank: Rank
    ) {
        self.connectionManager = connectionManager
        
        self.trialCore = trialCore
        self.direction = direction
        // scoreVC 는, boss 에게만 필요함 ..
        if rank == .boss {
            scoreVC = ScoreController(positionTitle: trialCore!.title, direction: trialCore!.direction, screen: screen!)
            print("-----------------received screen-----------------\n \(screen!)") // parentScreen is nil;
            print("subject: \(screen!.parentSubject)")
        }
        
        self.screen = screen
        self.positionTitle = positionTitle
        self.rank = rank
        
        super.init(nibName: nil, bundle: nil)
        
        
        self.direction = direction
        
        connectionManager.delegate = self
        if rank == .boss {
            scoreVC!.delegate = self
            scoreVC!.parentController = self
        }
        
        changeBtnLookForPreparing(animation: false)
    }
    
    // 왜 두번 생성하고 ㅈㄹ.. 필요 없어보임.
    //    private func setupTrialDetail() {
    //        trialDetail = trialCore.returnFreshTrialDetail()
    //    }
    
    public func prepareScoreController(trialCore: TrialCore, screen: Screen) {
        scoreVC = ScoreController(positionTitle: trialCore.title, direction: trialCore.direction, screen: screen)
        scoreVC?.delegate = self
        self.screen = screen
        
    }
    
    
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
        
        print("screen from CameraController: \(screen)")
        
//        let screenIndex = 1
        
//        guard let screen = screen else { fatalError() }
//        guard let subject = screen.parentSubject else { fatalError() }
        
//        createAlbumIfNotExist(albumName: "\(screen.screenIndex)_\(subject.name)")
    }
        
    private func setupInitialDirectionBtn() {
        if connectionManager.latestDirection != nil {
            let title = connectionManager.latestDirection!.rawValue
            directionStackView.selectBtnAction(with: title)
        }
    }
    
    // 처음 동작 띄울 때, Variation 으로 이동할 때 호출.
    private func updatePeerTitle() {
        
        
        //        let direction = MovementDirection(rawValue: trialCore.direction)!
        
        //        connectionManager.send(MsgWithMovementDetail(message: .updatePeerTitle, detailInfo: MovementDirectionScoreInfo(title: positionTitle, direction: direction)))
        
        //        connectionManager.send(PeerInfo(msgType: .updatePeerTitleMsg, info: Info(movementDetail: MovementDirectionScoreInfo(title: positionTitle, direction: direction))))
        connectionManager.send(PeerInfo(msgType: .updatePeerTitleMsg, info: Info(movementTitleDirection: MovementTitleDirectionInfo(title: positionTitle, direction: direction))))
        
        //        connectionManager.send(PeerInfo(msgType: .presentCameraMsg, info: Info(movementTitleDirection: MovementTitleDirectionInfo(title: positionTitle, direction: direction))))
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(calculateTimeDiff(_:)), name: .capturingStartedTime, object: nil)
        
        //        NotificationCenter.default.addobser
    }
    
    @objc func calculateTimeDiff(_ notification: Notification) {
        let peerStartedTime = (notification.userInfo?["peerStartedTime"])! as! Int64
        
        guard let currentDeviceStartedCapturingTime = currentDeviceStartedCapturingTime else {
            fatalError()
        }

        timeDiff = peerStartedTime - currentDeviceStartedCapturingTime
        if timeDiff! < 0 { timeDiff = 0 }
    
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
    
    @objc func requestPostNoti(_ notification: Notification) {
        
        let fileName = (notification.userInfo?["fileName"])! as! String
        


        
        makeFileNameThenPost(fileName: fileName)
    }
    
    private let leftLine = UIView().then {
        $0.backgroundColor = UIColor(redInt: 225, greenInt: 225, blueInt: 230)
    }
    
    private let rightLine = UIView().then {
        $0.backgroundColor = UIColor(redInt: 225, greenInt: 225, blueInt: 230)
    }
    
    
    @objc func hidePreviewNoti(_ notification: Notification) {
        hidePreview()
        stopTimer()
        resetTimer()
        
    }
    
    @objc func startRecordingNowNoti(_ notification: Notification) {
        print("startRecording has been triggered by observer. ")
        
        stopTimer()
        // remove preview if master order recording
        removeChildrenVC()
        // original
        //        let recordingTimer = Timer(fireAt: Date(), interval: 0, target: self, selector: #selector(startRecording), userInfo: nil, repeats: false)
        
        resetTimer()
        //FIXME: ?? 왜 updatingDurationTimer 에 recording 이 들어가있는거야?
        
        updatingDurationTimer = Timer(fireAt: Date(), interval: 0, target: self, selector: #selector(startRecording), userInfo: nil, repeats: false)
        
        RunLoop.main.add(updatingDurationTimer, forMode: .common)
        
        if rank == .follower {
            currentDeviceStartedCapturingTime = Date().millisecondsSince1970
        }
        
        let peerStartedCapturingTime = Date().millisecondsSince1970
        
        connectionManager.send(PeerInfo(msgType: .sendCapturingStartedTime, info: Info(capturingTime: CapturingTime(timeInInt64: peerStartedCapturingTime))))
        
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
        
        homeBtn.addTarget(self, action: #selector(homeOrNextTapped(_:)), for: .touchUpInside)
        
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
        
        connectionManager.send(PeerInfo(msgType: .updatePeerCameraDirectionMsg, info: Info( idWithDirection: DeviceNameWithCameraDirection(peerId: UIDevice.current.name, cameraDirection: cameraDirection))))
        
        // TODO: CameraDirection Check,
        // TODO: Show Alert If exist.
        for (peerId, direction) in connectionManager.cameraDirectionDic {
            if direction == cameraDirection && peerId != connectionManager.myId{
                showAlert("Duplicate Direction", "Please change camera direction of current device or the one with \"\(peerId)\"")
            }
        }
    }
    
    @objc func homeOrNextTapped(_ sender: UIButton) {
        // if pressedBtn is "Hold", update self.trialCore with Variation
        
        if pressedBtnTitle != "Hold" {
            
            hideCompleteMsgView()
            
            delegate?.dismissCamera() {
                self.dismiss(animated: true)
            }
            // CameraController Delegate
        } else { // pressedBtnTitle == "Hold"
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
                
                scoreVC!.setupAgain(positionTitle: self.positionTitle, direction: direction)
                
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
        
        //        scoreVC = nil
        
        //        self.dismiss(animated: true)
        // 왜 dismiss 가 안되지?
        
        delegate?.dismissCamera() {
            //            self.dismiss(animated: true)
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

        
        if isRecording {

            recordingBtnAction()
            
        } else {
            // Start Recording !
            //  -shouldRecordLater == false ==> Testing Mode
            if shouldRecordLater {
                _ = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) {  [weak self] _ in
                    self?.recordingBtnAction()
                    self?.currentDeviceStartedCapturingTime = Date().millisecondsSince1970
                }
                playCountDownLottie()
            } else {
                currentDeviceStartedCapturingTime = Date().millisecondsSince1970
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
            guard let scoreVC = scoreVC else {
                fatalError()
            }
            
            addChild(scoreVC)
            view.addSubview(scoreVC.view)
            scoreVC.view.layer.cornerRadius = 10
            
            //            self.scoreVC.view.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
            scoreVC.view.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
            
            // 점수 초기화 !
            scoreVC.scoreBtnStackView.setSelectedBtnNone()
            scoreVC.painBtnStackView.setSelectedBtnNone()
            
        }
        
        
    }
    
    // TODO: need to change trialCore of scoreVC here (why ?
    private func showScoreView(size: ScoreViewSize = .large) {
        if rank == .boss {
            guard let trialCore = trialCore else {
                return
            }
            guard let scoreVC = scoreVC else {
                return
            }
            
            
            scoreVC.setupTrialCore(with: trialCore )
            
            if size == .large {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4) {
                        self.scoreVC!.view.frame = CGRect(x: 0, y: screenHeight - 324, width: screenWidth, height: screenHeight)
                    }
                }
                
            } else {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4) {
                        self.scoreVC!.view.frame = CGRect(x: 0, y: screenHeight - 219, width: screenWidth, height: screenHeight)
                    }
                }
            }
        }
    }
    
    private func hideScoreView() {
        //        if rank == .boss {
        //        Thread 1: Fatal error: Unexpectedly found nil while unwrapping an Optional value
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.4) {
                self.scoreVC!.view.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
            }
        }
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
        
        var insetSize: CGFloat
        
        //        if size != nil {
        //            insetSize = size == .large ? 324 : 219
        //        }
        
        addChild(previewVC)
        view.addSubview(previewVC.view)
        
        
        switch size {
        case .none: insetSize = 0
        case .small: insetSize = 219
        case .large: insetSize = 324
        }
        
        stopTimer()
        
        previewVC.view.snp.makeConstraints { make in
            make.top.equalToSuperview()
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
//        self.picker.videoQuality = .typeHigh // 1080 1920
        self.picker.videoQuality = .typeIFrame960x540
        self.picker.cameraFlashMode = .off
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
    
    func renameRecording(from:URL, to:URL) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //        let toURL = documentsDirectory.URLByAppendingPathComponent(to.lastPathComponent!)
        let toURL = documentsDirectory.appendingPathComponent(to.lastPathComponent)
        
        print("renaming file \(from.absoluteString) to \(to) url \(toURL)")
        //        let fileManager = FileManager.defaultManager()
        let fileManager = FileManager.default.self
        fileManager.delegate = self
        do {
            try fileManager.moveItem(at: from, to: toURL)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("error renaming recording")
        }
        
        DispatchQueue.main.async {
            self.listRecordings()
        }
    }
    
    func listRecordings() {
        
        //            let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let documentsDirectory = FileManager.default.urls(for: .documentationDirectory, in: .userDomainMask)[0]
        do {
            //                let urls = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsDirectory, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
            let urls = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            
            //                self.arrayRecordingsURL = urls.filter( { (name: URL) -> Bool in
            //                    return name.lastPathComponent!.hasSuffix("m4a")
            //                })
            
        } catch let error as NSError {
            print(error.localizedDescription)
        } catch {
            print("something went wrong listing recordings")
        }
    }
    
}

// MARK: - UIImagePickerController Delegate
extension CameraController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //        picker.dismiss(animated: true)
        self.dismiss(animated: true)
    }
    
    /// 여기 함수 내에서 기다리게 할 수 있나..??
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("imagePickerController didFinishPickingMedia called!")
        
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
            
            videoUrl = url
            
            guard let validUrl = videoUrl else { fatalError() }
            
            let fileName = "my some test Name"
            
//            guard let timeDiff = timeDiff else { fatalError() }
            if timeDiff == nil { timeDiff = 0 }
            guard let timeDiff = timeDiff else { fatalError() }

//            guard let subjectName = subjectName else { fatalError() }
//            trimmingController = TrimmingController(url: validUrl, vc: self, timeDiff: timeDiff, subjectName: subjectName)
            
//            guard let screen = screen else { fatalError() }
            
//            trimmingController = TrimmingController(url: validUrl, vc: self, timeDiff: timeDiff, subjectName: "someName", screenIndex: screen.screenIndex )
            
            trimmingController = TrimmingController(url: validUrl, vc: self, timeDiff: timeDiff, subjectName: connectionManager.subjectName, screenIndex: Int64(connectionManager.screenIndex))
            
            let size: ScoreViewSize = Dummy.getPainTestName(from: positionTitle, direction: direction) != nil ? .large : .small
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.rank == .boss {
                    self.presentPreview(with: validUrl, size: size)
                } else {
                    self.presentPreview(with: validUrl, size: .none)
                }
                self.prepareScoreView()
                self.showScoreView(size: size)
            }
            
            print("url: \(url.path)")
            
            // TODO: Present Preview In a second
            
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
            return
        }
        DispatchQueue.main.async {
            previewVC.view.isHidden = true
        }
        stopTimer()
        resetTimer()
    }
    
    private func makeFileNameThenPost(fileName: String) {
        
        guard let validVideoURL = videoUrl else { return }
        
        var cameraDirectionInt: Int
        switch cameraDirection {
        case .front: cameraDirectionInt = 1
        case .side: cameraDirectionInt = 2
        case .between: cameraDirectionInt = 3
        case .none: cameraDirectionInt = 0
        }
        
        let videoFileName = fileName + "_\(cameraDirectionInt)"
        
        guard let cropController = trimmingController else {
            fatalError()
        }
        
        cropController.exportVideo(fileName: videoFileName) { CroppedUrl in
            print("fileName flag2: \(fileName)")
        }
        
        
        //        let cropController = CropController(url: validVideoURL, vc: self)
        
        //        cropController.exportVideo { CroppedUrl in
        //            print("url Name: \(CroppedUrl.absoluteString)")
        //        }
        
        //        cropController.exportVideo(fileName: videoFileName) { CroppedUrl in
        //            print("file Name: \(CroppedUrl.absoluteString)")
        //        }
        
        
        
        // TODO: change videoUrl' fileName to `videoFileName`
        FTPManager.shared.postRequest(videoURL: validVideoURL) {
            print("--------------- fileName ---------------\n \(videoFileName)")
        }
        
    }
    
    private func makeFTPInfoString(trialCore:TrialCore, trialDetail: TrialDetail, additionalInfo: String = "") -> FtpInfoString {
        
        guard let screen = screen else { fatalError() }
        guard let subject = screen.parentSubject else { fatalError() } // parentSubject 가 없나?
        
        let date = Date()
        let formattedDateStr = date.getFormattedDate()
        //        let inspectorName = "someName"
        
        
        let inspectorName = screen.parentSubject!.inspector!.name
        
        let subjectName = subject.name
        
        let screenIndex = screen.screenIndex + 1
        
        let titleShort = Dummy.shortForFileName[trialCore.title]!
        
        let directionShort: String
        
        switch trialCore.direction {
        case "Left": directionShort = "l"
        case "Right": directionShort = "r"
        default: directionShort = ""
        }
        
        let trialNo = trialDetail.trialNo
        let phoneNumber = subject.phoneNumber
        let genderInt = subject.isMale ? 1 : 2
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: subject.birthday)
        
        guard let birthYear = components.year else { fatalError() }
        
        let kneeLength = subject.kneeLength
        let palmLength = subject.palmLength
//        1.0
//        let kneeStr =
        
        let fileName = "\(formattedDateStr)_\(inspectorName)_\(subjectName)_\(screenIndex)_\(titleShort)\(directionShort)\(trialNo)_\(phoneNumber)_\(genderInt)_\(birthYear)_\(kneeLength)_\(palmLength)"
        
        let ftpInfoString = FtpInfoString(fileName: fileName)
        return ftpInfoString
    }
}


//YYYY.MM.DD_HH.MM.SS_검사자명_피험자명_1_ds1_01012341234_성별_탄생년도_무릅길이_손바닥길이_앵글

extension CameraController: ScoreControllerDelegate {
    func postAction(ftpInfoString: FtpInfoString) {
        
//        guard let validVideoURL = videoUrl else { return }
        let receivedFileName = ftpInfoString.fileName
        
//        guard let cropController = cropController else { fatalError() }
//        cropController.exportVideo( fileName: receivedFileName) { CroppedUrl in
//            print("fileName flag1: \(receivedFileName)")
//        }
        
        
        makeFileNameThenPost(fileName: receivedFileName)
    }
    
    
    func orderRequest(ftpInfoString: FtpInfoString) {
        connectionManager.send(PeerInfo(msgType: .requestPostMsg, info: Info(ftpInfoString: ftpInfoString)))
    }
    
    // TODO: Currently not being called ;; why ?
    func orderRequest(ftpInfo: FTPInfo) {
        connectionManager.send(PeerInfo(msgType: .requestPostMsg, info: Info(ftpInfo: ftpInfo)))
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
        scoreVC!.changeSaveBtnColor()
        //        self.updateTrialDetail()
    }
    
    public func updateTrialCore(with trialCore: TrialCore) {
        self.trialCore = trialCore
        self.positionTitle = trialCore.title
        self.direction = MovementDirection(rawValue: trialCore.direction) ?? .neutral
        updateNameLabel()
    }
    
    
    
    private func makeTrialDetail() {
        guard let trialCore = trialCore else {fatalError()}
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
    
    func saveVideoToLocal(with videoURL: URL) {
        
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL) // url for a video file
        }
//        UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(<#T##videoPath: String##String#>)
//        UISaveVideoAtPathToSavedPhotosAlbum("mymyTest", nil, nil, <#T##void?#>)
    }
   
//    func saveToAlbum(named: String, image: UIImage) {
////        let album = customalbum/
//        let album = CustomAlbum(name: named)
////        album.save(video: image, completion: { (result) in })
//        album.save(video: <#T##URL#>, completion: <#T##(Result<Bool, Error>)#>)
//    }
    
    func checkAuthorizationWithHandler(completion: @escaping (Result<Bool, Error>) -> ()) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                self.checkAuthorizationWithHandler(completion: completion)
            })
        }
        else if PHPhotoLibrary.authorizationStatus() == .authorized {
//            self.createAlbumIfNeeded { (success) in
//                completion(success)
//            }
        }
        else {
//            completion(.failure(CustomAlbumError.notAuthorized))
        }
    }
    
    // TODO: post, makePeersPost
    func postAction(ftpInfo: FTPInfo) {
        
        guard let validVideoUrl = videoUrl else { return }
        
        print("-----------CameraController trialCore Details -----------")
        
        //        let cropController = CropController(url: validVideoUrl, vc: self)
        
        //        cropController.exportVideo { CroppedUrl in
        //            print("url Name: \(CroppedUrl.absoluteString)")
        //        }
        //        cropController.exportVideo(fileName: ftpInfo, closure: <#T##(URL) -> Void##(URL) -> Void##(_ CroppedUrl: URL) -> Void#>)
        //        self.post(postReqInfo: ftpInfo)
        
        //        connectionManager.send(PeerInfo(msgType: .requestPostMsg, info: Info(postReqInfo: ftpInfo)))
        
        
        
        
    }
    
    private func convert() {
        
    }
    
    
    
    private func makeCall(title: String, direction: String, score: Int, pain: Int, trialCount: Int, videoURL: URL, cameraDirection: String, screenKey: UUID ) {
        
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



//extension UIViewController {
//    func makeFTPInfoString(trialCore:TrialCore, trialDetail: TrialDetail, additionalInfo: String = "") -> FtpInfoString {
//
//        guard let screen = screen else { fatalError() }
//        guard let subject = screen.parentSubject else { fatalError() } // parentSubject 가 없나?
//
//        let date = Date()
//        let formattedDateStr = date.getFormattedDate()
//        //        let inspectorName = "someName"
//
//
//        let inspectorName = screen.parentSubject!.inspector!.name
//
//        let subjectName = subject.name
//
//        let screenIndex = screen.screenIndex + 1
//
//        let titleShort = Dummy.shortForFileName[trialCore.title]!
//
//        let directionShort: String
//
//        switch trialCore.direction {
//        case "Left": directionShort = "l"
//        case "Right": directionShort = "r"
//        default: directionShort = ""
//        }
//
//        let trialNo = trialDetail.trialNo
//        let phoneNumber = subject.phoneNumber
//        let genderInt = subject.isMale ? 1 : 2
//
//        let calendar = Calendar.current
//        let components = calendar.dateComponents([.year], from: subject.birthday)
//
//        guard let birthYear = components.year else { fatalError() }
//
//        let kneeLength = subject.kneeLength
//        let palmLength = subject.palmLength
////        1.0
////        let kneeStr =
//
//        let fileName = "\(formattedDateStr)_\(inspectorName)_\(subjectName)_\(screenIndex)_\(titleShort)\(directionShort)\(trialNo)_\(phoneNumber)_\(genderInt)_\(birthYear)_\(kneeLength)_\(palmLength)"
//
//        let ftpInfoString = FtpInfoString(fileName: fileName)
//        return ftpInfoString
//    }
//}
