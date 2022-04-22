//
//  RecordingViewController.swift
//  VideoRecordingPractice
//
//  Created by 태우 on 2020/03/24.
//  Copyright © 2020 taewoo. All rights reserved.
//

import AVFoundation
import UIKit
import RxCocoa
import RxSwift
import CoreMotion
import Then
import SnapKit

//class RecordingViewController: UIViewController, ConnectionManagerDelegate {
class RecordingViewController: UIViewController {
    /*
    func presentVideo() {
        <#code#>
    }
    
    func showDuration(_ startAt: Date, _ endAt: Date) {
        <#code#>
    }
    
    func showStart(_ startAt: Date) {
        <#code#>
    }
    
    func updateDuration(_ startAt: Date, current: Date) {
        <#code#>
    }
    
    func updateState(state: String) {
        <#code#>
    }
    
    func disconnected(state: String, timeDuration: Int) {
        <#code#>
    }
    */
    
    // MARK:- Properties
    
    var disposeBag = DisposeBag()
    
    let captureSession = AVCaptureSession()
    
    var videoDevice: AVCaptureDevice!
    
    var videoInput: AVCaptureDeviceInput!
    
    var audioInput: AVCaptureDeviceInput!
    
    var videoOutput: AVCaptureMovieFileOutput!
    
    var connectionManager: ConnectionManager?
//    weak var delegate: ConnectionManagerDelegate?
    init(connectionManager: ConnectionManager) {
//        super.init()
//        initwithnib
        super.init(nibName: nil, bundle: nil)
        self.connectionManager = connectionManager
//        self.delegate = connectionManager
//        connectionManager.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession).then {
        $0.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.width)
        $0.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        $0.videoGravity = .resizeAspectFill
    }
    
    //  let topContainer = UIView()
    
    let topContainer: UIView = {
        let view = UIView()
        
        view.backgroundColor = .darkGray
        return view
    }()
    
    let swapButton = UIButton().then { $0.setTitle("Swap", for: .normal) }
    let recordButton = UIButton().then { $0.setTitle("Record", for: .normal) }
    
    let recordPoint = UIView().then {
        $0.backgroundColor = UIColor(red: 1.0, green: 0.75, blue: 0.01, alpha: 1)
        $0.layer.cornerRadius = 3
        $0.alpha = 0
    }
    
    let timerLabel = UILabel().then {
        $0.text = "00:00:00"
        $0.textColor = .white
    }
    
    let topHalfContainer: UIView = {
        let view = UIView()
//        view.backgroundColor = .orange
        view.backgroundColor = .black
        return view
    }()
    
    let bottomHalfContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPink
        return view
    }()
    
    var outputURL: URL?
    var motionManager: CMMotionManager!
    var deviceOrientation: AVCaptureVideoOrientation = .portrait
    
    var timer: Timer?
    var secondsOfTimer = 0
    let dismissBtn = UIButton().then {
        $0.setTitle("Dismiss!", for: .normal)
    }
    
    // MARK:- LifeCycle Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initMotionManager()
        
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        motionManager.stopAccelerometerUpdates()
        stopTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
        bind()
        videoDevice = bestDevice(in: .back)
        setupSession()
        
        addNotificationListener()
    
    }
    
    func addNotificationListener() {
        // Start
        NotificationCenter.default.addObserver(self, selector: #selector(receiveStartRecording(_:)), name: NSNotification.Name(NotificationKeys.startRecordingFromVC), object: nil)
        // Stop
        NotificationCenter.default.addObserver(self, selector: #selector(receiveStopRecording(_:)), name: NSNotification.Name(NotificationKeys.startRecordingFromVC), object: nil)
        // Dismiss
        NotificationCenter.default.addObserver(self, selector: #selector(receiveDismissCamera(_:)), name: NSNotification.Name(NotificationKeys.startRecordingFromVC), object: nil)
    }
    
    @objc func receiveStartRecording(_ sender: UIButton) {
        self.startRecording()
    }
    
    @objc func receiveStopRecording(_ sender: UIButton) {
        self.stopRecording()
    }
    
    @objc func receiveDismissCamera(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    // MARK:- View Rendering
    
    private func layout() {
        self.view.layer.addSublayer(previewLayer)
        
        self.view.addSubview(topHalfContainer)
        topHalfContainer.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo((view.frame.height - view.frame.width) / 2)

        }
        
        topHalfContainer.addSubview(topContainer)
        
        topContainer.snp.makeConstraints {
            $0.top.equalTo(topHalfContainer).offset(30) // safeArea
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        topContainer.addSubview(swapButton)
        swapButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-15)
            $0.height.equalTo(40)
        }
        
        topContainer.addSubview(timerLabel)
        timerLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        topContainer.addSubview(recordPoint)
        recordPoint.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(timerLabel.snp.leading).offset(-5)
            $0.width.height.equalTo(6)
        }
        
        self.view.addSubview(recordButton)
        recordButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
            $0.height.equalTo(40)
            $0.width.equalTo(150)
        }
        
        self.view.addSubview(dismissBtn)
        dismissBtn.snp.makeConstraints { make in
            make.right.equalTo(recordButton.snp.left)
            make.height.equalTo(40)
            make.width.equalTo(150)
            make.centerY.equalTo(recordButton)
        }
    }
    
    
    // MARK:- Rx Binding
    
    private func bind() {
        recordButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                
                if self.videoOutput.isRecording {
                    // TODO: Order Stop Recording
                    NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.stopRecordingFromIPC), object: nil)
                    self.stopRecording()

                    
                    self.secondsOfTimer = 0 // initiate Timer count
                    self.recordButton.setTitle("Record", for: .normal)
                } else {
                    // TODO: Order Start Recording
                    NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.startRecordingFromIPC), object: nil)
                    
                    self.startRecording()
                    self.recordButton.setTitle("Stop", for: .normal)
                }
            })
            .disposed(by: self.disposeBag)
        
        swapButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.swapCameraType()
            })
            .disposed(by: self.disposeBag)
        
        dismissBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                print("tap has pressed!")
//                self.dismiss(animated: true)
                if self.videoOutput.isRecording {
                    self.stopRecording()
                    //TODO: Order Stop Recording
                }
                
                DispatchQueue.main.async {
                    //TODO: Order Dismiss!
                    self.dismiss(animated: true)
                }
                
            }).disposed(by: disposeBag)
    }
    
    private func setupSession() {
        do {
            captureSession.beginConfiguration()
            
            videoInput = try AVCaptureDeviceInput(device: videoDevice!)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
            
            let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)!
            audioInput = try AVCaptureDeviceInput(device: audioDevice)
            if captureSession.canAddInput(audioInput) {
                captureSession.addInput(audioInput)
            }
            
            videoOutput = AVCaptureMovieFileOutput()
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            
            captureSession.commitConfiguration()
        }
        catch let error as NSError {
            NSLog("\(error), \(error.localizedDescription)")
        }
    }
    
    private func bestDevice(in position: AVCaptureDevice.Position) -> AVCaptureDevice {
        var deviceTypes: [AVCaptureDevice.DeviceType]!
        
        if #available(iOS 11.1, *) {
            deviceTypes = [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera]
        } else {
            deviceTypes = [.builtInDualCamera, .builtInWideAngleCamera]
        }
        
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: .unspecified
        )
        
        let devices = discoverySession.devices
        guard !devices.isEmpty else { fatalError("Missing capture devices.")}
        
        return devices.first(where: { device in device.position == position })!
    }
    
    private func swapCameraType() {
        guard let input = captureSession.inputs.first(where: { input in
            guard let input = input as? AVCaptureDeviceInput else { return false }
            return input.device.hasMediaType(.video)
        }) as? AVCaptureDeviceInput else { return }
        
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        // Create new capture device
        var newDevice: AVCaptureDevice?
        if input.device.position == .back {
            newDevice = bestDevice(in: .front)
        } else {
            newDevice = bestDevice(in: .back)
        }
        
        do {
            videoInput = try AVCaptureDeviceInput(device: newDevice!)
        } catch let error {
            NSLog("\(error), \(error.localizedDescription)")
            return
        }
        
        // Swap capture device inputs
        captureSession.removeInput(input)
        captureSession.addInput(videoInput!)
    }
    
    
    // MARK:- Recording Methods
    
    private func startRecording() {
        let connection = videoOutput.connection(with: AVMediaType.video)
        
        // orientation을 설정해야 가로/세로 방향에 따른 레코딩 출력이 잘 나옴.
        if (connection?.isVideoOrientationSupported)! {
            connection?.videoOrientation = self.deviceOrientation
        }
        
        let device = videoInput.device
        if (device.isSmoothAutoFocusSupported) {
            do {
                try device.lockForConfiguration()
                device.isSmoothAutoFocusEnabled = false
                device.unlockForConfiguration()
            } catch {
                print("Error setting configuration: \(error)")
            }
        }
        
        // recording point, timerString에 대한 핸들링
        recordPoint.alpha = 1
        self.fadeViewInThenOut(view: recordPoint, delay: 0)
        self.startTimer()
        
        outputURL = tempURL()
        videoOutput.startRecording(to: outputURL!, recordingDelegate: self)
    }
    
    private func stopRecording() {
        if videoOutput.isRecording {
            self.stopTimer()
            videoOutput.stopRecording()
            recordPoint.layer.removeAllAnimations()
        }
    }
    
    private func fadeViewInThenOut(view : UIView, delay: TimeInterval) {
        let animationDuration = 0.5
        
        UIView.animate(withDuration: animationDuration, delay: delay, options: [UIView.AnimationOptions.autoreverse, UIView.AnimationOptions.repeat], animations: {
            view.alpha = 0
        }, completion: nil)
    }
    
    private func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    // 가속도계(자이로스코프)를 측정해서 화면이 Lock 상태에서도 orientation 구하기.
    private func initMotionManager() {
        motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.gyroUpdateInterval = 0.2
        
        motionManager.startAccelerometerUpdates( to: OperationQueue() ) { [weak self] accelerometerData, _ in
            guard let data = accelerometerData else { return }
            
            if abs(data.acceleration.y) < abs(data.acceleration.x) {
                if data.acceleration.x > 0 {
                    self?.deviceOrientation = .landscapeLeft
                } else {
                    self?.deviceOrientation = .landscapeRight
                }
            } else {
                if data.acceleration.y > 0 {
                    self?.deviceOrientation = .portraitUpsideDown
                } else {
                    self?.deviceOrientation = .portrait
                }
            }
        }
    }
    
    
    // MARK:- Timer methods
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let `self` = self else { return }
            
            self.secondsOfTimer += 1
            self.timerLabel.text = Double(self.secondsOfTimer).format(units: [.hour ,.minute, .second])
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        self.timerLabel.text = "00:00:00"
    }
    
}


extension RecordingViewController: AVCaptureFileOutputRecordingDelegate {
    
    // 레코딩이 시작되면 호출
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
    }
    
    // 레코딩이 끝나면 호출
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            let videoRecorded = outputURL! as URL
            UISaveVideoAtPathToSavedPhotosAlbum(videoRecorded.path, nil, nil, nil)
        }
    }
    
}

extension Double {
    func format(units: NSCalendar.Unit) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = units
        formatter.zeroFormattingBehavior = [ .pad ]
        
        return formatter.string(from: self)!
    }
}
