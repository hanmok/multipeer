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
// need to create TrialDetail when .. new Trial needed.

protocol CameraControllerDelegate: AnyObject {
    func dismissCamera()
    func makeSound()
}

// CameraController don't need to know 'score'
class CameraController: UIViewController {

    // MARK: - Properties
    var positionTitle: String
    var direction: PositionDirection
    var trialCore: TrialCore
    var systemSoundID: SystemSoundID = 1057
//    var systemSoundID: SystemSoundID = 1016
    var timeDifference: CGFloat = 0 // Could be CMTime

    var screen: Screen

    weak var delegate: CameraControllerDelegate?
//    let soundService = SoundService()
    var connectionManager: ConnectionManager

    var updatingDurationTimer = Timer()
    var decreasingTimer = Timer()
    var count = 0
    var decreasingCount = 3

    var isRecordingEnded = false

    private var picker = UIImagePickerController()

    private var isRecording = false

    var previewVC: PreviewController?

    private var scoreVC: ScoreController

    var variationName: String?
    var trialDetail: TrialDetail?
    var sequentialPainPosition: String?

    // PositionDirectionScoreInfo: title, direction, score, pain

    init(
        positionDirectionScoreInfo: PositionDirectionScoreInfo,
        connectionManager: ConnectionManager,
        screen: Screen, trialCore: TrialCore) {

        self.screen = screen
        self.trialCore = trialCore
        self.positionTitle = positionDirectionScoreInfo.title
        self.direction = positionDirectionScoreInfo.direction
        self.connectionManager = connectionManager

        self.scoreVC = ScoreController(positionDirectionScoreInfo: positionDirectionScoreInfo)

        super.init(nibName: nil, bundle: nil)
        scoreVC.delegate = self
        connectionManager.delegate = self

        setupTrialDetail(with: trialCore)
    }

    private func setupTrialDetail(with core: TrialCore) {
        trialDetail = trialCore.returnFreshTrialDetail()
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupAddTargets()
        setupLayout()
        addNotificationObservers()
        updateInitialConnectionState()

//        SoundService.shard.someFunc()
    }





    private func setupNavigationBar() {
        DispatchQueue.main.async {
            if self.direction == .neutral {
                self.positionNameLabel.text = self.positionTitle
            } else {
                self.positionNameLabel.text = self.positionTitle + " " + self.direction.rawValue
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


        NotificationCenter.default.addObserver(self, selector: #selector(startRecordingAtNoti(_:)),
                                               name: .startRecordingAfterKey, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(startCountdownAtNoti(_:)),
                                               name: .startCountdownAfterKey, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updateConnectionStateNoti(_:)),
                                               name: .updateConnectionStateKey, object: nil)
    }

    @objc func startRecordingNowNoti(_ notification: Notification) {
        //        print("flag1")
        print("startRecording has been triggered by observer. ")
        guard let title = notification.userInfo?["title"] as? String,
              let direction = notification.userInfo?["direction"] as? PositionDirection,
              let score = notification.userInfo?["score"] as? Int? else { return }

        startRecording()
        // duration update needed
        // start
    }


    @objc func stopRecordingNoti(_ notification: Notification) {
        //        print("flag2")
        print("stopRecording has been triggered by observer. ")
        guard let title = notification.userInfo?["title"] as? String,
              let direction = notification.userInfo?["direction"] as? PositionDirection,
              let score = notification.userInfo?["score"] as? Int? else { return }

        stopRecording()
    }

    // not recommended
    @objc func startRecordingAtNoti(_ notification: Notification) {
        //        print("flag3")
        print(#function, #line)
        guard let dateToStartRecordingInMilliSec = notification.userInfo?["receivedTime"] as? Int,
              //              let msg = notification.userInfo?["msg"] as? RecordingType
              let msg = notification.userInfo?["msg"] as? MessageType
        else {
            print("fail to convert receivedTime to Int", #line)
            // millisec since 1970
            //            print(error?.localizedDescription)
            return
        }
        print(#function, #line)
        print("receivedMillisecData: \(dateToStartRecordingInMilliSec)")
        print("currentMillisecData: \(Date().millisecondsSince1970)")
// 이거 뭐지 ?
        let recordingTimer = Timer(fireAt: Date(milliseconds: dateToStartRecordingInMilliSec), interval: 0, target: self, selector: #selector(startRecording), userInfo: nil, repeats: false)
//TimeInterval(
        DispatchQueue.main.async {
//            self.recordingTimerBtn.setTitle("\(dateToStartRecordingInMilliSec)", for: .normal)

        }

        RunLoop.main.add(recordingTimer, forMode: .common)
        print("startRecordingAfter has ended", #line)
    }

    // not recommended
    @objc func startCountdownAtNoti(_ notification: Notification) {
        //        print("flag4")
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
        //        print("flag5")
        print(#file, #line)
        guard let state = notification.userInfo?["connectionState"] as? ConnectionState else {
            print("failed to get connectionState normally")
            return }
        switch state {
        case .disconnected:
            DispatchQueue.main.async {
                self.connectionStateLabel.text = "Disconnected!"
                self.showReconnectionGuideAction()
            }
        case .connected:
            DispatchQueue.main.async {
                self.connectionStateLabel.text = "Connected!"
            }
        }
    }

    deinit {
        print("cameraController deinit triggered!")
        if self.children.count > 0 {
            let viewControllers: [UIViewController] = self.children
            for vc in viewControllers {
                vc.willMove(toParent: nil)
                vc.view.removeFromSuperview()
                vc.removeFromParent()
            }
        }
    }

    // MARK: - Button Actions
    private func setupAddTargets() {
//        recordingBtn.addTarget(self, action: #selector(recordingBtnTapped(_:)), for: .touchUpInside)
        dismissBtn.addTarget(self, action: #selector(dismissBtnTapped(_:)), for: .touchUpInside)
        recordingTimerBtn.addTarget(self, action: #selector(timerRecordingBtnTapped(_:)), for: .touchUpInside)
        //        testScoreView.addTarget(self, action: #selector(showMore(_:)), for: .touchUpInside)
    }




    @objc func recordingBtnTapped(_ sender: UIButton) {
        print("recordingBtn Tapped!!")

        recordingBtnAction()

    }

    @objc func recordingBtnAction() {
        // Start Recording!!
        removeChildrenVC()
        if !isRecording {
            //            removePreview()
            // Send Start Msg
            //            connectionManager.send(DetailPositionWIthMsgInfo(message: .startRecordingMsg, detailInfo: PositionDirectionScoreInfo(title: positionTitle, direction: direction, score: score)))

            connectionManager.send(DetailPositionWIthMsgInfo(message: .startRecordingMsg, detailInfo: PositionDirectionScoreInfo(title: positionTitle, direction: direction, score: nil)))


            startRecording()
//            DispatchQueue.main.async {
            UIView.animate(withDuration: 0.4) {
                self.outerRecCircle.backgroundColor = UIColor(red: 71/255, green: 69/255, blue: 78/255, alpha: 1)
                self.innerShape.layer.cornerRadius = 6
//                self.recordingTimerBtn.setTitleColor(.black, for: .normal)
                self.recordingTimerBtn.setTitleColor(UIColor(red: 21/255, green: 21/255, blue: 21/255, alpha: 1), for: .normal)
                
                self.leftShape.layer.cornerRadius = 2
                self.leftShape.backgroundColor = UIColor(red: 181/255, green: 179/255, blue: 192/255, alpha: 1)
            }
//            }

            // STOP Recording !!
        } else {

            stopRecording()
            
            
//            DispatchQueue.main.async {
            UIView.animate(withDuration: 0.4) {
                self.outerRecCircle.backgroundColor = .red
                self.innerShape.layer.cornerRadius = 18
                self.recordingTimerBtn.setTitleColor(.red, for: .normal)
                
                self.leftShape.layer.cornerRadius = 10
                self.leftShape.backgroundColor = .red
            }
            
            // Send Stop Msg
            //            connectionManager.send(DetailPositionWIthMsgInfo(message: .stopRecordingMsg, detailInfo: PositionDirectionScoreInfo(title: positionTitle, direction: direction, score: score)))

            connectionManager.send(DetailPositionWIthMsgInfo(message: .stopRecordingMsg, detailInfo: PositionDirectionScoreInfo(title: positionTitle, direction: direction, score: nil)))

        }
    }

    @objc func prepareScoreView() {

        addChild(scoreVC)
        view.addSubview(scoreVC.view)
        scoreVC.view.layer.cornerRadius = 10
        scoreVC.view.layer.borderWidth = 2
        // prepare scoreVC to the bottom (to come up later)
        scoreVC.view.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
    }

    // TODO: need to change trialCore of scoreVC here
    private func showScoreView() {
        scoreVC.setupTrialCore(with: trialCore )
//        scoreVC.trialCore = trialCore

        UIView.animate(withDuration: 0.4) {
//            self.scoreVC.view.frame = CGRect(x: 0, y: screenHeight - 200, width: screenWidth, height: screenHeight)
            self.scoreVC.view.frame = CGRect(x: 0, y: screenHeight - 330, width: screenWidth, height: screenHeight)
        }
    }

//    private func showMore() {
//        UIView.animate(withDuration: 0.4) {
//
//            self.scoreVC.view.frame = CGRect(
////                x: 0,               y: screenHeight - 500,
//                x: 0,               y: screenHeight - 250,
//                width: screenWidth, height: screenHeight)
//        }
//    }

    private func hideScoreView() {
        UIView.animate(withDuration: 0.4) {
            self.scoreVC.view.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
            //            self.scoreNav.view.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
        }
    }

    @objc func dismissBtnTapped(_ sender: UIButton) {
        print("dismiss btn tapped!")
        delegate?.dismissCamera()
    }

    @objc func timerRecordingBtnTapped(_ sender: UIButton) {
        
        if isRecording {
            //            startRecording()
            recordingBtnAction()
        } else {
            _ = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) {  [weak self] _ in
                self?.recordingBtnAction()
            }
            
            playCountDownLottie()
        }

    }


    // MARK: - Basic Functions
    @objc private func startRecording() {
        print("startRecording triggered!! ")
        if !isRecording {
            DispatchQueue.main.async {
                self.picker.startVideoCapture()
//                self.recordingBtn.setTitle("Stop", for: .normal)
//                self.recordingTimerBtn.setTitle("Stop", for: .normal)
                
                let attributedTitle = NSMutableAttributedString(string: "STOP", attributes: [.font: UIFont.systemFont(ofSize: 12)])
                self.recordingTimerBtn.setAttributedTitle(attributedTitle, for: .normal)
                
            }

            self.isRecording = true

            triggerDurationTimer()
            // 이것부터 해결하자..
        }
    }

    private func stopRecording() {
        if isRecording {
            DispatchQueue.main.async {
                self.picker.stopVideoCapture()
//                self.recordingTimerBtn.setTitle("REC", for: .normal)
                let attributedTitle = NSMutableAttributedString(string: "REC", attributes: [.font: UIFont.systemFont(ofSize: 12)])
                self.recordingTimerBtn.setAttributedTitle(attributedTitle, for: .normal)
//                $0.setTitleColor(.red, for: .normal)
            }

            self.isRecording = false
            stopTimer()
        }
    }


    /// updating durationLabel contained
    private func triggerDurationTimer() {
        count = 0
        //        print("timer triggered!!")
        // 여기까지 일을 하는데, 아래는 안가네 ? 왜지 ??

        updatingDurationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let `self` = self else {
                print("self is nil in timer!!")
                return }

            //            print("trigger working!") // 왜.. 시행하는 쪽에서만 되냐 ?? 아님. 받는 쪽에서도 작동하넹.
            self.count += 1

            self.updateDurationLabel()
        }
    }
    
    // only func changes DurationLabel
    private func updateDurationLabel() {
        //        print("updateDuration Triggered!")

        let recordingDuration = convertIntoRecordingTimeFormat(count)

        DispatchQueue.main.async {
            self.durationLabel.text = recordingDuration // is this code working?
            //            print(#function, #line, "updating Duration Label!")
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
        print("triggerCoundDownTimerFlag 0 called")
        
        
        
        DispatchQueue.main.async {
            self.durationLabel.text = "00:00"
//            self.recordingTimerBtn.setTitle(String(self.decreasingCount), for: .normal)
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

    // TODO: For now, it's ratio not accurate, so it looks weird.
    // TODO: Don't need to change for now.


    //    private func preparePreview() {
    //
    //    }

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
        //        view.addSubview(testScoreView)
        //        showScoreView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        removeChildrenVC()
    }

    private func removeChildrenVC() {

        guard let previewVC = previewVC else {
            return
        }

        if self.children.count > 0 {
            // 이거.. 하면 ScoreView 도 없어지는거 아님? 맞음. 이거로 방지가 되려나.. ??

            let viewcontrollers: [UIViewController] = self.children
            for vc in viewcontrollers {

                if vc != scoreVC {
                    vc.willMove(toParent: nil)
                    vc.view.removeFromSuperview()
                    vc.removeFromParent()
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
        
        
        topView.addSubview(positionNameLabel)
        positionNameLabel.snp.makeConstraints { make in
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

    //MARK: Reconnect! when it ends.
    func showConnectivityAction() {
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


    // MARK: - UI Properties

//    private let testScoreView = UIButton(frame: CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)).then { $0.backgroundColor = .orange }

    private let bottomView = UIView().then { $0.backgroundColor = .white }
    private let topView = UIView().then { $0.backgroundColor = .white }
    
    private let positionNameLabel = UILabel().then {
//        $0.textColor = .white
        $0.textColor = .black
        //        $0.textAlignment = .center
        $0.textAlignment = .center
        $0.font = UIFont.systemFont(ofSize: 20)
//        $0.backgroundColor = .green
    }

    private let imageView = UIImageView()

    private var videoUrl: URL?

    private let connectionStateLabel = UILabel().then {

        $0.textColor = .white
    }


    private let durationLabel = UILabel().then {
        $0.textColor = .white
        $0.text = "00:00"
        $0.textAlignment = .center
        $0.layer.cornerRadius = 24
        $0.backgroundColor = UIColor(red: 109 / 255, green: 107 / 255, blue: 115 / 255, alpha: 1)
        $0.clipsToBounds = true
    }

//    private let dismissBtn = UIButton().then {
////        $0.setTitle("<", for: .normal)
//        $0.setTitleColor(.black, for: .normal)
//        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
//    }
    
    private let dismissBtn: UIButton = {
        let btn = UIButton()
        let innerImage = UIImageView(image: UIImage(systemName: "chevron.left"))
        innerImage.tintColor = .black
        btn.addSubview(innerImage)
        innerImage.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
            make.center.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
            make.height.equalToSuperview()
        }
//        let image = UIImage(systemName: "chevron.left")!.withTintColor(.black)
//        image?.withTintColor(<#T##color: UIColor##UIColor#>)
        
//        btn.setBackgroundImage(UIImage(systemName: "chevron.left"), for: .normal)
//        btn.setBackgroundImage(image, for: .normal)
        btn.addTarget(self, action: #selector(dismissBtnTapped(_:)), for: .touchUpInside)
//        btn.backgroundColor = .magenta
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
        $0.backgroundColor = UIColor(red: 237 / 255, green: 236/255, blue: 239/255, alpha: 1)
        $0.layer.cornerRadius = 24
    }
    
    private let leftShape = UIView().then {
        $0.layer.cornerRadius = 10
        $0.backgroundColor = .red
    }
    
    private let rightShape = UIView().then {
        $0.layer.cornerRadius = 10
        $0.backgroundColor = UIColor(red: 203/255, green: 202/255, blue: 211/255, alpha: 1)
    }
    
    private let recordingTimerBtn = UIButton().then {
//        $0.setTitle("REC", for: .normal)
        let attributedTitle = NSMutableAttributedString(string: "REC", attributes: [.font: UIFont.systemFont(ofSize: 12)])
        $0.setAttributedTitle(attributedTitle, for: .normal)
        $0.setTitleColor(.red, for: .normal)
    }

    /// animation from Vikky
    private let countDownLottieView = AnimationView(name: "countDown").then {
        $0.contentMode = .scaleAspectFit
        $0.loopMode = .playOnce
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
              //            let crop = info[UIImagePickerController.InfoKey.cropRect], // makes fail.. TT..
              // the delegate method gives a URL pointing to the video
                let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
//              videoUrl = url
                // Verify that the app can save the file to the device's photo album

                UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
        else {
            print("failed to get url Path!")
            return
        }

        print("save success !")
        // Save Video To Photos Album
        UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, nil, nil)




        videoUrl = url
//        guard url != nil else {return }

//        CropperController.cropVideo(from: url, presentOn: self)
        guard let validUrl = videoUrl else { fatalError() }
        let testController2 = TestController2(url: validUrl, vc: self)
        testController2.exportVideo()
//        test
        
//        TestController.cropVideoWithGivenSize(asset: <#T##AVAsset#>, baseSize: <#T##CGSize#>, completionHandler: <#T##TestController.CropTaskCompletion##TestController.CropTaskCompletion##(Result<URL, Error>) -> Void#>)
//        guard let
//        CropperController.cropVideo(from: videoUrl)



        //        removeItem(at: <#T##URL#>)
        print("url: \(url.path)")

        //        do {
        //            try FileManager().removeItem(at: url)
        //            print("success to remove URL!! ")
        //        } catch {
        //            print("failed to remove URL !!")
        //            print(error.localizedDescription)
        //        }

        // TODO: Present Preview In a second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //            self.present(VideoPlayerViewController(videoURL: url), animated: true)
            self.presentPreview(with: url)
            self.prepareScoreView()
            self.showScoreView()
        }

//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            self.showMore()
//        }
    }

    private func showReconnectionGuideAction() {
        let actionSheet = UIAlertController(title: "Connection Lost", message: "Do you want to Host or Join a session?", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        actionSheet.addAction(UIAlertAction(title: "Reconnect Session", style: .default, handler: { (action: UIAlertAction) in
            self.showConnectivityAction()
        }))

        self.present(actionSheet, animated: true, completion: nil)
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
    func updateState(state: ConnectionState) {
        switch state {
        case .disconnected:
            DispatchQueue.main.async {
                print(#file, #line)
                self.connectionStateLabel.text = "Disconnected!"
                //                self.showConnectivityAction()
                print("showReconnectionGuideAction!")
                self.showReconnectionGuideAction()
            }

        case .connected:
            DispatchQueue.main.async {
                self.connectionStateLabel.text = "Connected!"
            }
        }
    }

    func updateDuration(in seconds: Int) {

    }
}


extension CameraController: ScoreControllerDelegate {
    func nextAction() {
        // TODO: Dismiss Camera
    }


    func retryAction() {
        //TODO:  Upload to the Server, and Redo
        resetTimer()
        removeChildrenVC()
        prepareScoreView()
        makeTrialDetail()
        self.scoreVC.navigateBackToFirstView()

//        self.updateTrialCore()
        self.updateTrialDetail()
    }

    private func makeTrialDetail() {
        TrialDetail.save(belongTo: trialCore)
    }

    func deleteAction() {
        // 왜 제거가 안됨 ?? ;;; 글쎄다
        guard let validVideoUrl = videoUrl else { return }
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
        guard let direction = PositionDirection(rawValue: core.direction) else { return }

        let optionalScore = detail.score.scoreToInt()
        let optionalPain = detail.isPainful .painToBool()

        print("Data to post \n title: \(core.title),\n direction: \(direction.rawValue), \n score: \(String(describing: optionalScore)), \n pain: \(optionalPain), \n trialCount: trialCount: \(detail.trialNo),\n trialId: trialId: \(trialId)")

        APIManager.shared.postRequest(
            positionDirectionScoreInfo: PositionDirectionScoreInfo(
                title: trialCore.title, direction: direction, score: optionalScore, pain: optionalPain),
            trialCount: Int(detail.trialNo), trialId: trialId,
            videoUrl: validVideoUrl, angle: .front)


    }


    /// merge Position Title + Direction  into Unique Key
    private func mergeKeys(title: String, direction: String) -> String {
        return title + direction
    }


//    func moveUp() {
//        // TODO: Move ScoreController up
//    }

    // triggered when 'Next' Tapped
    func updatePosition(with positionDirectionScoreInfo: PositionDirectionScoreInfo) {
        self.positionTitle = positionDirectionScoreInfo.title
        print("positition updated to \(self.positionTitle)")

        self.direction = positionDirectionScoreInfo.direction

        self.scoreVC.setupAgain(with: positionDirectionScoreInfo)
        self.scoreVC.navigateBackToFirstView()

    }




    func hideScoreController() {
        hideScoreView()
    }

    func prepareRecording() {
        print("prepareRecording called from CameraController")
        setupNavigationBar()
        removeChildrenVC()
        resetTimer()
        hideScoreView()
    }

    func dismissCameraController() {
        delegate?.dismissCamera() // CameraController Delegate
    }
}
