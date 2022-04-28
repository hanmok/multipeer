////
////  RecordingViewController.swift
////  VideoRecordingPractice
////
////  Created by 태우 on 2020/03/24.
////  Copyright © 2020 taewoo. All rights reserved.
////
//
//import AVFoundation
//import UIKit
//import RxCocoa
//import RxSwift
//import CoreMotion
//import Then
//import SnapKit
//
////class RecordingViewController: UIViewController, ConnectionManagerDelegate {
//
//
//
//class RecordingViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate {
//
//    // MARK:- Properties
//
//    var disposeBag = DisposeBag()
//
//    let captureSession = AVCaptureSession()
//
//    var videoDevice: AVCaptureDevice!
//
//    var videoInput: AVCaptureDeviceInput!
//
//    var audioInput: AVCaptureDeviceInput!
//
////    var videoOutput: AVCaptureMovieFileOutput!
//
//    var connectionManager: ConnectionManager!
//
//    var outputURL: URL?
//    var motionManager: CMMotionManager!
//    var deviceOrientation: AVCaptureVideoOrientation = .portrait
//
//    var recordTimer: Timer?
//    var sessionTimer: Timer?
//
//    var recordDuration = 0
//    var sessionDuration = 0
//
//    var maxSessionDuration = 0
//
//    private let captureButton: SwiftyRecordButton = {
//        let btn = SwiftyRecordButton()
//        return btn
//    }()
//
////    lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession).then {
////        $0.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.width)
////        $0.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
////        $0.videoGravity = .resizeAspectFill
////    }
//
//    lazy var topContainer: UIView = {
//        let view = UIView()
//        view.backgroundColor = .darkGray
//        return view
//    }()
//
//
//
//    lazy var recordButton = UIButton().then { $0.setTitle("Record", for: .normal) }
//
//    lazy var connectionState = UILabel().then { $0.text = "Connection state"}
//
//    lazy var connectionDurationLabel = UILabel().then { $0.text = "Connection Duration"}
//
////    lazy var disconnectBtn = UIButton().then { $0.setTitle("Disconnect", for: .normal)}
//
//    lazy var recordPoint = UIView().then {
//        $0.backgroundColor = UIColor(red: 1.0, green: 0.75, blue: 0.01, alpha: 1)
//        $0.layer.cornerRadius = 3
//        $0.alpha = 0
//
//    }
//
//    lazy var timerLabel = UILabel().then {
//        $0.text = "00:00:00"
//        $0.textColor = .white
//    }
//
//    lazy var topHalfContainer: UIView = {
//        let view = UIView()
//        view.backgroundColor = .black
//        return view
//    }()
//
//    lazy var bottomHalfContainer: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemPink
//        return view
//    }()
//
//    lazy var dismissBtn = UIButton().then {
//        $0.setTitle("Dismiss!", for: .normal)
//    }
//
//    var vcTimer: Int = 0
//
//    // MARK: - LifeCycle Methods
//
//
//    init(connectionManager: ConnectionManager, vcTimer: Int) {
//        //        DispatchQueue.main.async {
//        super.init(nibName: nil, bundle: nil)
//        //        }
//        self.connectionManager = connectionManager
//        self.vcTimer = vcTimer
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        initMotionManager()
//
//        if !captureSession.isRunning {
//            captureSession.startRunning()
//        }
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        motionManager.stopAccelerometerUpdates()
//        stopRecordTimer()
////        startVideoRecording()
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // 여기에 타이머 추가하기.
//        print("viewdidLoad from RecordingVC")
//        cameraDelegate = self
//        print("view from RecordingVC : \(view.frame.width), \(view.frame.height)")
//
//        layout()
//        bind()
//        videoDevice = bestDevice(in: .back)
//
////        setupSession()
//
//        addNotificationListener()
//
//        if connectionManager.connectionState == .connected {
//            startSessionTimer()
//            connectionState.text = "Connected"
//        } else {
//            connectionState.text = "Disconnected"
//        }
//    }
//
//    func addNotificationListener() {
//        // Start
//        NotificationCenter.default.addObserver(self, selector: #selector(receiveStartRecording(_:)), name: NSNotification.Name(NotificationKeys.startRecordingKey), object: nil)
//        // Stop
//        NotificationCenter.default.addObserver(self, selector: #selector(receiveStopRecording(_:)), name: NSNotification.Name(NotificationKeys.stopRecordingKey), object: nil)
//        // Dismiss
//        NotificationCenter.default.addObserver(self, selector: #selector(receiveDismissCamera(_:)), name: NSNotification.Name(NotificationKeys.startRecordingFromVC), object: nil)
//        print("addNotification listener called!")
//
//        NotificationCenter.default.addObserver(self, selector: #selector(disconnectedAction(_:)), name: NSNotification.Name(NotificationKeys.disconnectedKey), object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(connectedAction(_:)), name: NSNotification.Name(NotificationKeys.connectedKey), object: nil)
//
//    }
//
//
//    // not called!
//    @objc func receiveStartRecording(_ notification: Notification) {
//        print("receiveStartRecording ! ", #file, #function)
//        DispatchQueue.main.async {
////            self.startRecording()
//            self.startVideoRecording()
//
//        }
//    }
//
//    @objc func receiveStopRecording(_ notification: Notification) {
//
////        self.stopRecording()
//        self.stopVideoRecording()
//    }
//
//    @objc func receiveDismissCamera(_ notification: Notification) {
//        self.dismiss(animated: true)
//    }
//
//    @objc func disconnectedAction(_ notification: Notification) {
//        print("disconectedAction Called!!!")
//
//        disconnectAction()
//
//        sessionTimer?.invalidate()
//
//    }
//
//    func disconnectAction() {
//
//        print("Session disconnected!")
//        maxSessionDuration = sessionDuration
//        DispatchQueue.main.async {
//            self.connectionState.text = "disconnected!"
//            self.connectionDurationLabel.text = "remained for \(self.maxSessionDuration) s"
//        }
//
//        connectionManager.sessionTimer?.invalidate()
//
//    }
//
//    @objc func connectedAction(_ notification: Notification) {
//        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
//            DispatchQueue.main.async {
//                self?.connectionDurationLabel.text = String((self?.sessionDuration)!)
//            }
//
//        })
//
//    }
//
//
//
//    // MARK:- Rx Binding
//
//    private func bind() {
//        recordButton.rx.tap
//            .subscribe(onNext: { [weak self] in
//                guard let `self` = self else { return }
//
////                if self.videoOutput.isRecording {
//
////                if self.movieFileOutput?.isRecording {
//                if self.movieFileOutput.isRecording {
//
//                    // TODO: Order Stop Recording
////                    self.stopRecording()
//                    self.stopVideoRecording()
//
//                    if let connectionManager = self.connectionManager {
//                        connectionManager.send(OrderMessageTypes.stopRecording)
//                        print("connectionManager is valid, stop")
//                    } else {
//                        fatalError("connectionManager is nil")
//                    }
//                    print("Stop Recording !!")
//                } else {
//                    // TODO: Order Start Recording
//
//                    if let connectionManager = self.connectionManager {
//                        connectionManager.send(OrderMessageTypes.startRecording)
//                        print("connectionManager is valid, start")
//                    } else {
//                        fatalError("connectionManager is nil, start")
//                    }
//                print("Start Recording !!")
////                    self.startRecording()
//                    self.startVideoRecording()
//
//                }
//            })
//            .disposed(by: self.disposeBag)
//
//
//
//        dismissBtn.rx.tap
//            .subscribe(onNext: { [weak self] in
//                guard let `self` = self else { return }
//                print("tap has pressed!")
//                //                self.dismiss(animated: true)
////                if self.videoOutput.isRecording {
//                if self.movieFileOutput.isRecording {
////                    self.stopRecording()
//                    self.stopVideoRecording()
//                    //TODO: Order Stop Recording
//                }
//
//                DispatchQueue.main.async {
//                    //TODO: Order Dismiss!
//                    self.dismiss(animated: true)
//                }
//
//            }).disposed(by: disposeBag)
//
////        disconnectBtn.rx.tap
////            .subscribe(onNext: { [weak self] in
////                self?.disconnectAction()
////            })
////            .disposed(by: disposeBag)
//
//    }
//
////    private func setupSession() {
////        do {
////            captureSession.beginConfiguration()
////
////            videoInput = try AVCaptureDeviceInput(device: videoDevice!)
////            if captureSession.canAddInput(videoInput) {
////                captureSession.addInput(videoInput)
////            }
////
////            let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)!
////            audioInput = try AVCaptureDeviceInput(device: audioDevice)
////            if captureSession.canAddInput(audioInput) {
////                captureSession.addInput(audioInput)
////            }
////
////            videoOutput = AVCaptureMovieFileOutput()
////            if captureSession.canAddOutput(videoOutput) {
////                captureSession.addOutput(videoOutput)
////            }
////
////            captureSession.commitConfiguration()
////        }
////        catch let error as NSError {
////            NSLog("\(error), \(error.localizedDescription)")
////        }
////    }
//
//    private func bestDevice(in position: AVCaptureDevice.Position) -> AVCaptureDevice {
//        var deviceTypes: [AVCaptureDevice.DeviceType]!
//
////        if #available(iOS 13.0, *) {
////            deviceTypes = [.builtInUltraWideCamera]
////            let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: AVMediaType.video, position: position)
////
////            return discoverySession.devices.first(where: { device in device.position == position})! // trigger fatalError
////        }
//
//        if #available(iOS 11.1, *) {
//            deviceTypes = [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera]
//        } else {
//            deviceTypes = [.builtInDualCamera, .builtInWideAngleCamera]
//        }
//
//        let discoverySession = AVCaptureDevice.DiscoverySession(
//            deviceTypes: deviceTypes,
//            mediaType: .video,
//            position: .unspecified
//        )
//
//        let devices = discoverySession.devices
//        guard !devices.isEmpty else { fatalError("Missing capture devices.")}
//
//        return devices.first(where: { device in device.position == position })!
//    }
//
//    private func swapCameraType() {
//        guard let input = captureSession.inputs.first(where: { input in
//            guard let input = input as? AVCaptureDeviceInput else { return false }
//            return input.device.hasMediaType(.video)
//        }) as? AVCaptureDeviceInput else { return }
//
//        captureSession.beginConfiguration()
//        defer { captureSession.commitConfiguration() }
//
//        // Create new capture device
//        var newDevice: AVCaptureDevice?
//        if input.device.position == .back {
//            newDevice = bestDevice(in: .front)
//        } else {
//            newDevice = bestDevice(in: .back)
//        }
//
//        do {
//            videoInput = try AVCaptureDeviceInput(device: newDevice!)
//        } catch let error {
//            NSLog("\(error), \(error.localizedDescription)")
//            return
//        }
//
//        // Swap capture device inputs
//        captureSession.removeInput(input)
//        captureSession.addInput(videoInput!)
//    }
//
//
//    // MARK:- Recording Methods
//    override func startVideoRecording() {
//        super.startVideoRecording()
//        self.fadeViewInThenOut(view: recordPoint, delay: 0)
//        self.startRecordTimer()
//        self.recordDuration = 0 // initiate Timer count
//        DispatchQueue.main.async {
//            self.recordButton.setTitle("Stop", for: .normal)
//        }
//    }
//
//    override func stopVideoRecording() {
//        super.stopVideoRecording()
//        self.stopRecordTimer()
//        DispatchQueue.main.async {
//            self.recordButton.setTitle("Record", for: .normal)
//        }
//    }
//
////    private func startRecording() {
////        let connection = videoOutput.connection(with: AVMediaType.video)
////
////        // orientation을 설정해야 가로/세로 방향에 따른 레코딩 출력이 잘 나옴.
////        if (connection?.isVideoOrientationSupported)! {
////            connection?.videoOrientation = self.deviceOrientation
////        }
////
////        let device = videoInput.device
////        if (device.isSmoothAutoFocusSupported) {
////            do {
////                try device.lockForConfiguration()
////                device.isSmoothAutoFocusEnabled = false
////                device.unlockForConfiguration()
////            } catch {
////                print("Error setting configuration: \(error)")
////            }
////        }
////
////        // recording point, timerString에 대한 핸들링
////        DispatchQueue.main.async {
////            self.recordPoint.alpha = 1
////            self.recordButton.setTitle("Stop", for: .normal)
////        }
////        self.fadeViewInThenOut(view: recordPoint, delay: 0)
////        self.startRecordTimer()
////
////        outputURL = tempURL()
////        videoOutput.startRecording(to: outputURL!, recordingDelegate: self)
////
////        self.recordDuration = 0 // initiate Timer count
////
////    }
//
////    private func stopRecording() {
//////        swifty
////        if videoOutput.isRecording {
////            self.stopRecordTimer()
////            videoOutput.stopRecording()
////            DispatchQueue.main.async {
////
////                self.recordPoint.layer.removeAllAnimations()
////                self.recordButton.setTitle("Record", for: .normal)
////
////            }
////        }
////    }
//
//    private func fadeViewInThenOut(view : UIView, delay: TimeInterval) {
//        let animationDuration = 0.5
//
//        UIView.animate(withDuration: animationDuration, delay: delay, options: [UIView.AnimationOptions.autoreverse, UIView.AnimationOptions.repeat], animations: {
//            view.alpha = 0
//        }, completion: nil)
//    }
//
//    private func tempURL() -> URL? {
//        let directory = NSTemporaryDirectory() as NSString
//
//        if directory != "" {
//            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
//            return URL(fileURLWithPath: path)
//        }
//
//        return nil
//    }
//
//    // 가속도계(자이로스코프)를 측정해서 화면이 Lock 상태에서도 orientation 구하기.
//    private func initMotionManager() {
//        motionManager = CMMotionManager()
//        motionManager.accelerometerUpdateInterval = 0.2
//        motionManager.gyroUpdateInterval = 0.2
//
//        motionManager.startAccelerometerUpdates( to: OperationQueue() ) { [weak self] accelerometerData, _ in
//            guard let data = accelerometerData else { return }
//
//            if abs(data.acceleration.y) < abs(data.acceleration.x) {
//                if data.acceleration.x > 0 {
//                    self?.deviceOrientation = .landscapeLeft
//                } else {
//                    self?.deviceOrientation = .landscapeRight
//                }
//            } else {
//                if data.acceleration.y > 0 {
//                    self?.deviceOrientation = .portraitUpsideDown
//                } else {
//                    self?.deviceOrientation = .portrait
//                }
//            }
//        }
//    }
//
//
//    // MARK:- Timer methods
//
//    private func startRecordTimer() {
//        recordTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//            guard let `self` = self else { return }
//
//            self.recordDuration += 1
//            self.timerLabel.text = Double(self.recordDuration).format(units: [.hour ,.minute, .second])
//        }
//    }
//
//    private func stopRecordTimer() {
//        recordTimer?.invalidate()
//        DispatchQueue.main.async {
//
//            self.timerLabel.text = "00:00:00"
//        }
//    }
//
//    private func startSessionTimer() {
//        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//            guard let `self` = self else { return }
////            if connection
//            self.sessionDuration += 1
//            self.connectionDurationLabel.text =  String(self.sessionDuration) + "s"
//
//            self.connectionDurationLabel.text = "for \(self.sessionDuration) s"
//
//        }
//    }
//
//    private func stopSessionTimer() {
//        sessionTimer?.invalidate()
//        DispatchQueue.main.async {
//
//
//            self.connectionDurationLabel.text = "00"
//        }
//    }
//
//
//    private func layout() {
////        self.view.layer.addSublayer(previewLayer)
//
//        self.view.addSubview(topHalfContainer)
//        topHalfContainer.snp.makeConstraints { make in
//            make.leading.top.trailing.equalToSuperview()
//            make.height.equalTo((view.frame.height - view.frame.width) / 2)
//
//        }
//
//        topHalfContainer.addSubview(topContainer)
//
//        topContainer.snp.makeConstraints {
//            $0.top.equalTo(topHalfContainer).offset(35) // safeArea
//            $0.leading.trailing.equalToSuperview()
//            $0.height.equalTo(50)
//        }
//
//
//        topContainer.addSubview(timerLabel)
//        timerLabel.snp.makeConstraints {
//            $0.centerX.centerY.equalToSuperview()
//        }
//
//
//
//        topContainer.addSubview(recordPoint)
//        recordPoint.snp.makeConstraints {
//            $0.centerY.equalToSuperview()
//            $0.trailing.equalTo(timerLabel.snp.leading).offset(-5)
//            $0.width.height.equalTo(6)
//        }
//
//        //        self.view.addSubview(connectionState)
//        topHalfContainer.addSubview(connectionState)
//        connectionState.snp.makeConstraints { make in
//            make.left.equalToSuperview()
//            make.height.equalTo(40)
//            make.width.equalTo(150)
//            make.top.equalTo(topContainer.snp.bottom).offset(30)
//        }
//
//        //        self.view.addSubview(connectionDurationLabel)
//        topHalfContainer.addSubview(connectionDurationLabel)
//
//        connectionDurationLabel.snp.makeConstraints { make in
//            make.right.equalToSuperview()
//            make.height.equalTo(40)
//            make.width.equalTo(200)
//            make.top.equalTo(topContainer.snp.bottom).offset(30)
//        }
//
//
//        self.view.addSubview(recordButton)
//        recordButton.snp.makeConstraints {
//            $0.centerX.equalToSuperview()
//            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
//            $0.height.equalTo(40)
//            $0.width.equalTo(150)
//        }
//
//
//
//
////        self.view.addSubview(disconnectBtn)
////        disconnectBtn.snp.makeConstraints { make in
////            make.left.equalTo(recordButton.snp.right)
////            make.height.equalTo(40)
////            make.width.equalTo(150)
////            make.centerY.equalTo(recordButton.snp.centerY)
////        }
//
//        self.view.addSubview(dismissBtn)
//        dismissBtn.snp.makeConstraints { make in
//            make.right.equalTo(recordButton.snp.left)
//            make.height.equalTo(40)
//            make.width.equalTo(150)
//            make.centerY.equalTo(recordButton)
//        }
//
//
//
//    }
//
//}
//
//
//extension RecordingViewController {
//
//    // 레코딩이 시작되면 호출
//    override func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
////        connections.videoScaleAndCropFactor = .min
//
//        for connection in connections {
////            connection.videoScaleAndCropFactor = 2
//            connection.videoScaleAndCropFactor = connection.videoMaxScaleAndCropFactor
//        }
//
////        if let connection = connections.first {
////            connection.videoScaleAndCropFactor = 0.5
////            print("capture connection is valid!")
////        } else {
////            print("capture connection is invalid!")
////        }
//        print("hello")
//    }
//
//    // videoScaleAndCropFactor
//
//    // 레코딩이 끝나면 호출
////    override func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
////        if (error != nil) {
////            print("Error recording movie: \(error!.localizedDescription)")
////        } else {
////            let videoRecorded = outputURL! as URL
////            UISaveVideoAtPathToSavedPhotosAlbum(videoRecorded.path, nil, nil, nil)
////        }
////    }
//
//}
//
//extension Double {
//    func format(units: NSCalendar.Unit) -> String {
//        let formatter = DateComponentsFormatter()
//        formatter.unitsStyle = .positional
//        formatter.allowedUnits = units
//        formatter.zeroFormattingBehavior = [ .pad ]
//
//        return formatter.string(from: self)!
//    }
//}
