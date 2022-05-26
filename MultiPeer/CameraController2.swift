////
////  ViewController.swift
////  BasicCameraUsingPicker
////
////  Created by 핏투비 iOS on 2022/04/26.
////
//
//import UIKit
//import SnapKit
//import MobileCoreServices
//import Photos
//import MultipeerConnectivity
//import AVFoundation
//import CoreData
//import Foundation
//
//// need to create TrialDetail when .. new Trial needed.
//
//protocol CameraControllerDelegate: AnyObject {
//    func dismissCamera()
//    func makeSound()
//}
//
//// CameraController don't need to know 'score'
//class CameraController: UIViewController {
//
////    var editorClass = EditorClass()
//
//    // MARK: - Properties
//    var positionTitle: String
//    var direction: PositionDirection
//    var trialCore: TrialCore
//    //    var systemSoundID: SystemSoundID = 1057
//    var systemSoundID: SystemSoundID = 1016
//
//    var screen: Screen
//
//    weak var delegate: CameraControllerDelegate?
//    //    let soundService = SoundService()
//    var connectionManager: ConnectionManager
//
//    var updatingDurationTimer = Timer()
//    var decreasingTimer = Timer()
//    var testTimer = Timer()
//    var runningTestTimer = false
////    var prevRunningModulo = 0
////    var currentRunningModulo = 0
//
//    var count = 0
//    var decreasingCount = 3
//
//    var isRecordingEnded = false
//
//    private var picker = UIImagePickerController()
//
//    private var isRecording = false
//
//    var previewVC: PreviewController?
//
//    private var scoreVC: ScoreController
//
//    var variationName: String?
//    var trialDetail: TrialDetail?
//    var sequentialPainPosition: String?
//
//    private var videoUrl: URL?
//
//    // PositionDirectionScoreInfo: title, direction, score, pain
//
//
//
//
//    // MARK: - LifeCycle
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    init(
//        positionDirectionScoreInfo: PositionDirectionScoreInfo,
//        connectionManager: ConnectionManager,
//        screen: Screen, trialCore: TrialCore) {
//
//            self.screen = screen
//            self.trialCore = trialCore
//            self.positionTitle = positionDirectionScoreInfo.title
//            self.direction = positionDirectionScoreInfo.direction
//            self.connectionManager = connectionManager
//
//            self.scoreVC = ScoreController(positionDirectionScoreInfo: positionDirectionScoreInfo)
//
//            super.init(nibName: nil, bundle: nil)
//            scoreVC.delegate = self
//            connectionManager.delegate = self
//
//            setupTrialDetail(with: trialCore)
//        }
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupNavigationBar()
//        setupAddTargets()
//        setupLayout()
//        addNotificationObservers()
//        updateInitialConnectionState()
//
//
//        //        SoundService.shard.someFunc()
////        SoundService.shard.makeSoundOne()
//    }
//
//    deinit {
//        print("cameraController deinit triggered!")
//        if self.children.count > 0 {
//            let viewControllers: [UIViewController] = self.children
//            for vc in viewControllers {
//                vc.willMove(toParent: nil)
//                vc.view.removeFromSuperview()
//                vc.removeFromParent()
//            }
//        }
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        removeChildrenVC()
//    }
//
//
//
//
//    // MARK: - TIMER
//    private func resetTimer() {
//        durationLabel.text = "00:00"
//    }
//
//    private func stopTimer() {
//        updatingDurationTimer.invalidate()
//    }
//
//    @objc private func triggerCountDownTimer() {
//        print("triggerCoundDownTimerFlag 0 called")
//
//        DispatchQueue.main.async {
//            self.durationLabel.text = "00:00"
//            self.recordingTimerBtn.setTitle(String(self.decreasingCount), for: .normal)
//        }
//
//        decreasingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//
//            //            self?.delegate?.makeSound()
//
//            guard let `self` = self else { return }
//
//            DispatchQueue.main.async {
//                self.recordingTimerBtn.setTitle("\(self.decreasingCount)", for: .normal)
//            }
//
//            if self.decreasingCount > 0 {
//                self.decreasingCount -= 1
////                SoundService.shard.makeSoundOne()
//            } else {
//
//                DispatchQueue.main.async {
//                    self.recordingTimerBtn.setTitle("Recording!", for: .normal)
//                }
//
//                self.decreasingCount = 3
//                self.decreasingTimer.invalidate()
//            }
//        }
//    }
//
//    /// updating durationLabel contained
//    private func triggerDurationTimer() {
//        count = 0
//        //        print("timer triggered!!")
//        // 여기까지 일을 하는데, 아래는 안가네 ? 왜지 ??
//
//        updatingDurationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//            guard let `self` = self else {
//                print("self is nil in timer!!")
//                return }
//
//            //            print("trigger working!") // 왜.. 시행하는 쪽에서만 되냐 ?? 아님. 받는 쪽에서도 작동하넹.
//            self.count += 1
//
//            self.updateDurationLabel()
//        }
//    }
//
//    private func updateDurationLabel() {
//        //        print("updateDuration Triggered!")
//
//        let recordingDuration = convertIntoRecordingTimeFormat(count)
//
//        DispatchQueue.main.async {
//            self.durationLabel.text = recordingDuration // is this code working?
//            //            print(#function, #line, "updating Duration Label!")
//        }
//    }
//
//
//    // MARK: - Connection
//    func updateInitialConnectionState() {
//        print(#file, #line)
//        switch connectionManager.connectionState {
//        case .connected:
//            DispatchQueue.main.async {
//                self.connectionStateLabel.text = "Connected!"
//            }
//        case .disconnected:
//            DispatchQueue.main.async {
//                self.connectionStateLabel.text = "Disconnected!"
//            }
//        }
//    }
//
//    /// Reconnect if needed .
//    func showConnectivityAction() {
//        let actionSheet = UIAlertController(title: "Connect Camera", message: "Do you want to Host or Join a session?", preferredStyle: .actionSheet)
//
//        actionSheet.addAction(UIAlertAction(title: "Host Session", style: .default, handler: { (action: UIAlertAction) in
//            self.connectionManager.host()
//        }))
//
//        actionSheet.addAction(UIAlertAction(title: "Join Session", style: .default, handler: { (action: UIAlertAction) in
//            self.connectionManager.join()
//        }))
//
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        self.present(actionSheet, animated: true, completion: nil)
//    }
//
//
//
//    // MARK: - Notification
//    private func addNotificationObservers() {
//        NotificationCenter.default.addObserver(self, selector: #selector(startRecordingNowNoti(_:)),
//                                               name: .startRecordingKey, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(stopRecordingNoti(_:)),
//                                               name: .stopRecordingKey, object: nil)
//
//
//        NotificationCenter.default.addObserver(self, selector: #selector(startRecordingAtNoti(_:)),
//                                               name: .startRecordingAfterKey, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(startCountdownAtNoti(_:)),
//                                               name: .startCountdownAfterKey, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(updateConnectionStateNoti(_:)),
//                                               name: .updateConnectionStateKey, object: nil)
//    }
//
//    @objc func startRecordingNowNoti(_ notification: Notification) {
//        //        print("flag1")
//        print("startRecording has been triggered by observer. ")
//        guard let title = notification.userInfo?["title"] as? String,
//              let direction = notification.userInfo?["direction"] as? PositionDirection,
//              let score = notification.userInfo?["score"] as? Int? else { return }
//
//        startRecording()
//        // duration update needed
//    }
//
//
//    @objc func stopRecordingNoti(_ notification: Notification) {
//        print("stopRecording has been triggered by observer. ")
//        guard let title = notification.userInfo?["title"] as? String,
//              let direction = notification.userInfo?["direction"] as? PositionDirection,
//              let score = notification.userInfo?["score"] as? Int? else { return }
//
//        stopRecording()
//    }
//
//    /// NotUsing
//    @objc func startRecordingAtNoti(_ notification: Notification) {
//        //        print("flag3")
//        print(#function, #line)
//        guard let dateToStartRecordingInMilliSec = notification.userInfo?["receivedTime"] as? Int
//              //              let msg = notification.userInfo?["msg"] as? RecordingType
//              , let msg = notification.userInfo?["msg"] as? MessageType
//        else {
//            fatalError("failed to convert received Time to Int")
//        }
//
//        print("receivedMillisecData: \(dateToStartRecordingInMilliSec)")
//        print("currentMillisecData: \(Date().millisecondsSince1970)")
//
//
//        startRecordingAt(dateToStartRecordingInMilliSec)
//
////        DispatchQueue.main.async {
////            self.recordingTimerBtn.setTitle("\(dateToStartRecordingInMilliSec)", for: .normal)
////        }
//
//        print("startRecordingAfter has ended", #line)
//    }
//
//    // triggered by noti
//    @objc func startCountdownAtNoti(_ notification: Notification) {
//
//        guard let milliTime = notification.userInfo?["receivedTime"] as? Int,
//                let msg = notification.userInfo?["msg"] as? MessageType
//        else {
//            fatalError("failed to convert receivedTime to Int")
//        }
//
//        startCountdownAt(milliTime)
//
//    }
//
//
//    @objc func updateConnectionStateNoti(_ notification: Notification) {
//        //        print("flag5")
//        print(#file, #line)
//        guard let state = notification.userInfo?["connectionState"] as? ConnectionState else {
//            print("failed to get connectionState normally")
//            return }
//        switch state {
//        case .disconnected:
//            DispatchQueue.main.async {
//                self.connectionStateLabel.text = "Disconnected!"
//                self.showReconnectionGuideAction()
//            }
//        case .connected:
//            DispatchQueue.main.async {
//                self.connectionStateLabel.text = "Connected!"
//            }
//        }
//    }
//
//
//    // MARK: - Button Actions
//    private func setupAddTargets() {
//        recordingBtn.addTarget(self, action: #selector(recordingBtnTapped(_:)), for: .touchUpInside)
//        dismissBtn.addTarget(self, action: #selector(dismissBtnTapped(_:)), for: .touchUpInside)
//        recordingTimerBtn.addTarget(self, action: #selector(timerRecordingBtnTapped(_:)), for: .touchUpInside)
//    }
//
//
//
//
//    @objc func recordingBtnTapped(_ sender: UIButton) {
//        print("recordingBtn Tapped!!")
//
//        recordingBtnAction()
//
//    }
//
//    @objc func recordingBtnAction() {
//        // Start Recording!!
//        removeChildrenVC()
//        if !isRecording {
//            //            removePreview()
//            // Send Start Msg
//            //            connectionManager.send(DetailPositionWIthMsgInfo(message: .startRecordingMsg, detailInfo: PositionDirectionScoreInfo(title: positionTitle, direction: direction, score: score)))
//
//            connectionManager.send(DetailPositionWIthMsgInfo(message: .startRecordingMsg, detailInfo: PositionDirectionScoreInfo(title: positionTitle, direction: direction, score: nil)))
//
//
//            startRecording()
//            // STOP Recording !!
//        } else {
//
//            stopRecording()
//            // Send Stop Msg
//            //            connectionManager.send(DetailPositionWIthMsgInfo(message: .stopRecordingMsg, detailInfo: PositionDirectionScoreInfo(title: positionTitle, direction: direction, score: score)))
//
//            connectionManager.send(DetailPositionWIthMsgInfo(message: .stopRecordingMsg, detailInfo: PositionDirectionScoreInfo(title: positionTitle, direction: direction, score: nil)))
//
//        }
//    }
//
//    @objc func dismissBtnTapped(_ sender: UIButton) {
//        delegate?.dismissCamera()
//    }
//
//    // sender
//    @objc func timerRecordingBtnTapped(_ sender: UIButton) {
//        timerRecordingBtnAction()
//    }
//
//    private func timerRecordingBtnAction() {
//        let dateIn1500ms = Date().millisecondsSince1970 + 1500
////        let dateIn1500ms = Date().millisecondsSince1970
//
////        let dateIn4500ms = Date().millisecondsSince1970 + 4500
//        let dateIn4500ms = Date().millisecondsSince1970 + 4500
//
////        connectionManager.send(MsgWithTime(msg: .startCountDownMsg, timeInMilliSec: Int(dateIn1500ms)))
////
////        connectionManager.send(MsgWithTime(msg: .startRecordingAfterMsg, timeInMilliSec: Int(dateIn4500ms)))
////
//        startCountdownAt(Int(dateIn1500ms))
////        startRecordingAt(Int(dateIn4500ms))
//
//
//        // Test Code it's much better ...
//        let someTimer = Timer(fireAt: Date(milliseconds: Int(dateIn4500ms)), interval: 0, target: self, selector: #selector(recordingBtnAction), userInfo: nil, repeats: false)
//
//        RunLoop.main.add(someTimer, forMode: .common)
//
//    }
//
//    private func startCountdownAt(_ dateInTime: Int) {
//
//
//        let countdownTimer = Timer(fireAt: Date(milliseconds: dateInTime), interval: 0, target: self, selector: #selector(triggerCountDownTimer), userInfo: nil, repeats: false)
//
//        RunLoop.main.add(countdownTimer, forMode: .common)
//
//
//    }
//
//    private func startRecordingAt(_ dateInTime: Int) {
//        print("startRecordingAt triggered!!!!, current Date: \(Date().millisecondsSince1970)")
//        //        let recordingTimer = Timer(fireAt: Date(milliseconds: dateInTime + 200), interval: 0, target: self, selector: #selector(startRecording), userInfo: nil, repeats: false)
//
//        DispatchQueue.main.async {
////            self.recordingTimerBtn.setTitle("\(dateInTime)", for: .normal)
//
//            self.timeTestLabel.text = "\(dateInTime)"
//            self.startTimeTestLabel.text = "\(Date().millisecondsSince1970)"
//        }
//
//        let recordingTimer = Timer(fireAt: Date(milliseconds: dateInTime), interval: 0, target: self, selector: #selector(startRecording), userInfo: nil, repeats: false)
//
//        // 왜 이럴까 ??
//
//        RunLoop.main.add(recordingTimer, forMode: .common)
//
//
//        testTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
//        print("test timer called !!")
//            guard let `self` = self else { return }
//
//            if Date().millisecondsSince1970 < dateInTime + 50 {
//                DispatchQueue.main.async {
//                    self.realtimeTestLabel.text = String(Date().millisecondsSince1970)
//                }
//            }
//        }
//    }
//
//    @objc func prepareScoreView() {
//
//        addChild(scoreVC)
//        view.addSubview(scoreVC.view)
//        // prepare scoreVC to the bottom (to come up later)
//        scoreVC.view.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
//    }
//
//    // TODO: need to change trialCore of scoreVC here
//    private func showScoreView() {
//        scoreVC.setupTrialCore(with: trialCore )
//        //        scoreVC.trialCore = trialCore
//
//        // TODO: Enable Animate (prevented for testing)
//        /*
//        UIView.animate(withDuration: 0.4) {
//            self.scoreVC.view.frame = CGRect(x: 0, y: screenHeight - 200, width: screenWidth, height: screenHeight)
//        }
//         */
//    }
//
//    private func setupTrialDetail(with core: TrialCore) {
//        trialDetail = trialCore.returnFreshTrialDetail()
//    }
//
//    private func showMore() {
//        UIView.animate(withDuration: 0.4) {
//            // TODO: Enable After sync test
////            self.scoreVC.view.frame = CGRect(
////                x: 0,               y: screenHeight - 500,
////                width: screenWidth, height: screenHeight)
//        }
//    }
//
//
//    // MARK: - Basic Functions
//    @objc private func startRecording() {
//        count = 0
//        updateDurationLabel()
//
//        print("startRecording triggered!! ")
//        if !isRecording {
//
//            DispatchQueue.main.async {
//                self.picker.startVideoCapture()
//                self.recordingBtn.setTitle("Stop", for: .normal)
//            }
//
//            self.isRecording = true
//
//            triggerDurationTimer()
//        }
//
//        guard let previewVC = previewVC else { return }
//
//        DispatchQueue.main.async {
//            previewVC.view.isHidden = true
//
//        }
//
//    }
//
//
//    private func stopRecording() {
//        if isRecording {
//            DispatchQueue.main.async {
//                self.picker.stopVideoCapture()
//                self.recordingBtn.setTitle("Record", for: .normal)
//                self.recordingTimerBtn.setTitle("Record in 3s", for: .normal)
//            }
//
//            self.isRecording = false
//            stopTimer()
//        }
//        guard let previewVC = previewVC else {
//            return
//        }
//        DispatchQueue.main.async {
//            previewVC.view.isHidden = false
//        }
//
//    }
//
//
//    // MARK: - UI Properties
//
//    private let bottomView = UIView().then { $0.backgroundColor = .black }
//    private let topView = UIView().then { $0.backgroundColor = .black }
//    private let positionNameLabel = UILabel().then {
//        $0.textColor = .white
//        $0.textAlignment = .left
//        $0.font = UIFont.systemFont(ofSize: 20)
//    }
//
//    private let timeTestLabel = UILabel().then {
//        $0.textColor = .white
//        $0.textAlignment = .right
////        $0.font = UIFont.systemFont(ofSize: 20)
//        $0.font = UIFont.monospacedSystemFont(ofSize: 15, weight: .regular)
//    }
//
//    private let realtimeTestLabel = UILabel().then {
//        $0.textColor = .green
//        $0.textAlignment = .right
////        $0.font = UIFont.systemFont(ofSize: 20)
//        $0.font = UIFont.monospacedSystemFont(ofSize: 15, weight: .regular)
//    }
//
//    private let startTimeTestLabel = UILabel().then {
//        $0.textColor = .green
//        $0.textAlignment = .right
////        $0.font = UIFont.systemFont(ofSize: 20)
//        $0.font = UIFont.monospacedSystemFont(ofSize: 15, weight: .regular)
//    }
//
//    private let imageView = UIImageView()
//
//    private let connectionStateLabel = UILabel().then {
//        $0.textColor = .white
//    }
//
//    private let recordingBtn = UIButton().then {
//        $0.setTitle("Record", for: .normal)
//        $0.setTitleColor(.white, for: .normal)
//    }
//
//    private let durationLabel = UILabel().then {
//        $0.textColor = .white
//        $0.text = "00:00"
//        $0.textAlignment = .center
//        $0.backgroundColor = .magenta
//    }
//
//    private let dismissBtn = UIButton().then {
//        $0.setTitle("Dismiss!", for: .normal)
//    }
//
//    private let recordingTimerBtn = UIButton().then {
//        $0.setTitle("Record in 3s", for: .normal)
//        $0.setTitleColor(.white, for: .normal)
//    }
//
//
//    // MARK: - UI func
//
//    private func setupNavigationBar() {
//        DispatchQueue.main.async {
//            if self.direction == .neutral {
//                self.positionNameLabel.text = self.positionTitle
//            } else {
//                self.positionNameLabel.text = self.positionTitle + " " + self.direction.rawValue
//            }
//        }
//    }
//
//    private func hideScoreView() {
//        UIView.animate(withDuration: 0.4) {
//            self.scoreVC.view.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
//            //            self.scoreNav.view.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: screenHeight)
//        }
//    }
//
//    private func presentPreview(with videoURL: URL) {
//
//        previewVC = PreviewController(videoURL: videoURL)
//        guard let previewVC = previewVC else {
//            return
//        }
//
//        addChild(previewVC)
//        view.addSubview(previewVC.view)
//        previewVC.view.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.bottom.equalTo(bottomView.snp.top)
//            make.width.height.equalTo(view.snp.width)
//        }
//        //        view.addSubview(testScoreView)
//        //        showScoreView()
//    }
//
//    private func removeChildrenVC() {
//
//        guard let previewVC = previewVC else {
//            return
//        }
//
//        if self.children.count > 0 {
//            // 이거.. 하면 ScoreView 도 없어지는거 아님? 맞음. 이거로 방지가 되려나.. ??
//
//            let viewcontrollers: [UIViewController] = self.children
//            for vc in viewcontrollers {
//
//                if vc != scoreVC {
//                    vc.willMove(toParent: nil)
//                    vc.view.removeFromSuperview()
//                    vc.removeFromParent()
//                }
//            }
//        }
//    }
//
//
//    func setupLayout() {
//        print("present Picker!!")
//
//        self.topView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: (screenHeight - screenWidth) / 2)
//
//
//        self.bottomView.frame = CGRect(x:0, y: screenHeight - (screenHeight - screenWidth) / 2,
//                                       width: screenWidth, height: (screenHeight - screenWidth) / 2)
//
//        self.bottomView.addSubview(self.recordingBtn)
//        self.recordingBtn.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//            make.height.equalTo(50)
//            make.width.equalTo(150)
//        }
//
//        self.bottomView.addSubview(self.connectionStateLabel)
//        self.connectionStateLabel.snp.makeConstraints { make in
//            make.top.bottom.equalToSuperview()
//            make.leading.equalToSuperview()
//            make.trailing.equalTo(self.recordingBtn.snp.leading)
//        }
//
//        self.bottomView.addSubview(self.dismissBtn)
//        self.dismissBtn.snp.makeConstraints { make in
//            make.right.equalToSuperview()
//            make.centerY.equalToSuperview()
//            make.height.equalTo(50)
//            make.width.equalTo(100)
//        }
//
//        self.bottomView.addSubview(self.recordingTimerBtn)
//        self.recordingTimerBtn.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.bottom.equalTo(self.recordingBtn.snp.top).offset(-10)
//            make.width.equalTo(150)
//            make.height.equalTo(50)
//        }
//
//        self.bottomView.addSubview(self.durationLabel)
//        self.durationLabel.snp.makeConstraints { make in
//            make.centerY.equalTo(self.recordingTimerBtn.snp.centerY)
//            make.height.equalTo(50)
//            make.leading.equalTo(self.recordingTimerBtn.snp.trailing)
//            make.trailing.equalToSuperview()
//        }
//
//        self.picker.allowsEditing = true
//        self.picker.sourceType = .camera
//        self.picker.delegate = self
//        self.picker.mediaTypes = [kUTTypeMovie as String]
//        self.picker.cameraOverlayView = self.bottomView
//        self.picker.showsCameraControls = false
//        self.picker.preferredContentSize = CGSize(width: self.view.frame.width,
//                                                  height: self.view.frame.width)
//
//        self.view.addSubview(self.picker.view)
//        self.picker.view.snp.makeConstraints { make in
//            make.leading.top.trailing.bottom.equalToSuperview()
//        }
//
//        view.addSubview(topView)
//        topView.snp.makeConstraints { make in
//            make.top.leading.trailing.equalToSuperview()
//            make.height.equalTo((screenHeight - screenWidth) / 2)
//        }
//
//
//        topView.addSubview(positionNameLabel)
//        positionNameLabel.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(60)
////            make.centerX.equalToSuperview()
////            make.leading.trailing.equalToSuperview().inset(30)
//            make.leading.equalToSuperview().inset(30)
//            make.width.equalToSuperview().dividedBy(2)
//            make.height.equalTo(50)
//        }
//
//        topView.addSubview(timeTestLabel)
//        timeTestLabel.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(30)
//            make.trailing.equalToSuperview().inset(30)
//            make.width.equalToSuperview().dividedBy(2)
//            make.height.equalTo(20)
//        }
//
//        topView.addSubview(realtimeTestLabel)
//        realtimeTestLabel.snp.makeConstraints { make in
//            make.top.equalTo(timeTestLabel.snp.bottom)
//            make.trailing.equalToSuperview().inset(30)
//            make.width.equalToSuperview().dividedBy(2)
//            make.height.equalTo(20)
//        }
//
//        topView.addSubview(startTimeTestLabel)
//        startTimeTestLabel.snp.makeConstraints { make in
//            make.top.equalTo(realtimeTestLabel.snp.bottom)
//            make.trailing.equalToSuperview().inset(30)
//            make.width.equalToSuperview().dividedBy(2)
//            make.height.equalTo(20)
//        }
//    }
//}
//
//// MARK: - PICKER Delegate
//extension CameraController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        //        picker.dismiss(animated: true)
//        DispatchQueue.main.async {
//            self.dismiss(animated: true)
//        }
//
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
//              mediaType == (kUTTypeMovie as String),
//              //            let crop = info[UIImagePickerController.InfoKey.cropRect], // makes fail.. TT..
//              // the delegate method gives a URL pointing to the video
//                let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
//
//                // Verify that the app can save the file to the device's photo album
//
//                UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
//        else {
//            print("failed to get url Path!")
//            return
//        }
//
//        print("save success !")
//        // Save Video To Photos Album
//        UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, nil, nil)
//        videoUrl = url
//
//        print("url: \(url.path)")
//
//
//        // TODO: Present Preview In a second
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            //            self.present(VideoPlayerViewController(videoURL: url), animated: true)
//            self.presentPreview(with: url)
//            self.prepareScoreView()
//            self.showScoreView()
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            self.showMore()
//        }
//    }
//
//    private func showReconnectionGuideAction() {
//        let actionSheet = UIAlertController(title: "Connection Lost", message: "Do you want to Host or Join a session?", preferredStyle: .actionSheet)
//
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//
//        actionSheet.addAction(UIAlertAction(title: "Reconnect Session", style: .default, handler: { (action: UIAlertAction) in
//            self.showConnectivityAction()
//        }))
//
//        self.present(actionSheet, animated: true, completion: nil)
//    }
//
//    //    private func updateTrialCore() {
//    //
//    //    }
//
//    //    private func updateTrialDetail() {
//    //
//    //    }
//}
//
//// MARK: - Connection Manager Delegate
//extension CameraController: ConnectionManagerDelegate {
//    func updateState(state: ConnectionState) {
//        switch state {
//        case .disconnected:
//            DispatchQueue.main.async {
//                print(#file, #line)
//                self.connectionStateLabel.text = "Disconnected!"
//                //                self.showConnectivityAction()
//                print("showReconnectionGuideAction!")
//                self.showReconnectionGuideAction()
//            }
//
//        case .connected:
//            DispatchQueue.main.async {
//                self.connectionStateLabel.text = "Connected!"
//            }
//        }
//    }
//
//    func updateDuration(in seconds: Int) {
//
//    }
//}
//
//
//
//
//// MARK: - Score Delegate
//extension CameraController: ScoreControllerDelegate {
//
//
//    func nextAction() {
//        // TODO: Dismiss Camera
//    }
//
//
//    func retryAction() {
//        //TODO:  Upload to the Server, and Redo
//        resetTimer()
//        removeChildrenVC()
//        prepareScoreView()
//        makeTrialDetail()
//        self.scoreVC.navigateBackToFirstView()
//
//        //        self.updateTrialCore()
//        //        self.updateTrialDetail()
//    }
//
//    private func makeTrialDetail() {
//        TrialDetail.save(belongTo: trialCore)
//    }
//
//    func deleteAction() {
//        // 왜 제거가 안됨 ?? ;;; 글쎄다
//        guard let validVideoUrl = videoUrl else { return }
//        print("file exist ? 1 \(FileManager().fileExists(atPath: validVideoUrl.path))")
//        do {
//            try FileManager().removeItem(at: validVideoUrl)
//            print("file exist ? 2 \(FileManager().fileExists(atPath: validVideoUrl.path))")
//            print("successfully deleted video !") // ?? 삭제 안됐는데 ?
//        } catch {
//            print("error: \(error.localizedDescription)")
//            print("file exist ? 3 \(FileManager().fileExists(atPath: validVideoUrl.path))")
//        }
//        // initialize selected score
//
//        prepareRecording()
//    }
//
//
//    func saveAction(core: TrialCore, detail: TrialDetail) {
//
//        guard let validVideoUrl = videoUrl else { return }
//
//        let trialId = UUID()
//        guard let direction = PositionDirection(rawValue: core.direction) else { return }
//
//        let optionalScore = detail.score.scoreToInt()
//        let optionalPain = detail.isPainful .painToBool()
//
//        print("Data to post \n title: \(core.title),\n direction: \(direction.rawValue), \n score: \(String(describing: optionalScore)), \n pain: \(optionalPain), \n trialCount: trialCount: \(detail.trialNo),\n trialId: trialId: \(trialId)")
//
//        APIManager.shared.postRequest(
//            positionDirectionScoreInfo: PositionDirectionScoreInfo(
//                title: trialCore.title, direction: direction, score: optionalScore, pain: optionalPain),
//            trialCount: Int(detail.trialNo), trialId: trialId,
//            videoUrl: validVideoUrl, angle: .front)
//
//
//    }
//
//
//    /// merge Position Title + Direction  into Unique Key
//    private func mergeKeys(title: String, direction: String) -> String {
//        return title + direction
//    }
//
//
//    //    func moveUp() {
//    //        // TODO: Move ScoreController up
//    //    }
//
//    // triggered when 'Next' Tapped
//    func updatePosition(with positionDirectionScoreInfo: PositionDirectionScoreInfo) {
//        self.positionTitle = positionDirectionScoreInfo.title
//        print("positition updated to \(self.positionTitle)")
//
//        self.direction = positionDirectionScoreInfo.direction
//
//        self.scoreVC.setupAgain(with: positionDirectionScoreInfo)
//        self.scoreVC.navigateBackToFirstView()
//
//    }
//
//
//
//
//    func hideScoreController() {
//        hideScoreView()
//    }
//
//    func prepareRecording() {
//        print("prepareRecording called from CameraController")
//        setupNavigationBar()
//        removeChildrenVC()
//        resetTimer()
//        hideScoreView()
//    }
//
//    func dismissCameraController() {
//        delegate?.dismissCamera() // CameraController Delegate
//    }
//}
