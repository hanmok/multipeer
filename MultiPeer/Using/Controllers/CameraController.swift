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







class CameraController: UIViewController {
    
    // MARK: - Properties
    let positionTitle: String
    let direction: PositionDirection
    var score: Int?
    
    var connectionManager: ConnectionManager
    
    var timer = Timer()
    var count = 0
    
    //    private var picker : UIImagePickerController?
    private var picker = UIImagePickerController()
    
    private var isRecording = false
    
    init(positionWithDirectionInfo: PositionWithDirectionInfo, connectionManager: ConnectionManager) {
        self.positionTitle = positionWithDirectionInfo.title
        self.direction = positionWithDirectionInfo.direction
        self.score = positionWithDirectionInfo.score
        self.connectionManager = connectionManager
        super.init(nibName: nil, bundle: nil)
    }
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAddTargets()
        setupLayout()
        addNotificationObservers()
        updateInitialConnectionState()
    }
    
    func updateInitialConnectionState() {
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(startRecordingTriggered(_:)),
                                               name: .startRecording, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopRecordingNotificationTriggered(_:)),
                                               name: .stopRecording, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateConnectionState(_:)),
                                               name: .updateConnectionState, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(startRecordingAt(_:)),
                                               name: .startRecordingAt, object: nil)
        
    }
    
    @objc func startRecordingAt(_ notification: Notification) {
        guard let milliTime = notification.userInfo?["receivedTime"] as? Int,
              let msg = notification.userInfo?["msg"] as? RecordingType
        else {
            print("fail to convert receivedTime to Int")
            // millisec since 1970
            return
        }
        print("received Msg: \(msg.rawValue)")
        
        print("receivedMillisecData: \(milliTime)")
        print("currentMillisecData: \(Date().millisecondsSince1970)")
        
        
        let recordingTimer = Timer(fireAt: Date(milliseconds: milliTime), interval: 0, target: self, selector: #selector(startRecording), userInfo: nil, repeats: false)
        
        RunLoop.main.add(recordingTimer, forMode: .common)
        
    }
    
    @objc func updateConnectionState(_ notification: Notification) {
        
        guard let state = notification.userInfo?["connectionState"] as? ConnectionState else {
            print("failed to get connectionState normally")
            return }
        switch state {
        case .disconnected:
            DispatchQueue.main.async {
                self.connectionStateLabel.text = "Disconnected!"
            }
        case .connected:
            DispatchQueue.main.async {
                self.connectionStateLabel.text = "Connected!"
            }
        }
    }
    
    @objc func startRecordingTriggered(_ notification: Notification) {
        print("startRecording has been triggered by observer. ")
        guard let title = notification.userInfo?["title"] as? String,
              let direction = notification.userInfo?["direction"] as? PositionDirection,
              let score = notification.userInfo?["score"] as? Int? else { return }
        
        startRecording()
        // duration update needed
    }
    
    
    @objc private func startRecording() {
        
        //        startVideoCapture
        if !isRecording {
            DispatchQueue.main.async {
                self.picker.startVideoCapture()
                self.recordingBtn.setTitle("Stop", for: .normal)
            }
            
            self.isRecording = true
            print("started Video Capturing! ")
        
            triggerDurationTimer() // 이거 왜 안돼..? 몰라.. 안되면 카운트다운은 애초에 어떻게 해 ? // not working
            // 이것부터 해결하자..
        }
    }
    
    
    
    @objc func stopRecordingNotificationTriggered(_ notification: Notification) {
        print("startRecording has been triggered by observer. ")
        guard let title = notification.userInfo?["title"] as? String,
              let direction = notification.userInfo?["direction"] as? PositionDirection,
              let score = notification.userInfo?["score"] as? Int? else { return }
        
        
        if isRecording {
            DispatchQueue.main.async {
                self.picker.stopVideoCapture()
                self.isRecording = false
                print("started Video Capturing! ")
                self.recordingBtn.setTitle("Record", for: .normal)
            }
            
            stopTimer()
        }
    }
    
    /// updating durationLabel contained
    private func triggerDurationTimer() {
        count = 0
        print("timer triggered!!")
        // 여기까지 일을 하는데, 아래는 안가네 ? 왜지 ??
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let `self` = self else { return }
            
            print("trigger working!") // 왜.. 시행하는 쪽에서만 되냐 ?? 아님. 받는 쪽에서도 작동하넹.
            self.count += 1
            
            self.updateDurationLabel()
        }
    }
    
    private func updateDurationLabel() {
        print("updateDuration Triggered!")
        
        let recordingDuration = convertIntoRecordingTimeFormat(count)
        
        DispatchQueue.main.async {
            self.durationLabel.text = recordingDuration // is this code working?
            print(#function, #line, "updating Duration Label!")
        }
    }
    
    
    
    // MARK: - Button Actions
    private func setupAddTargets() {
        
        recordingBtn.addTarget(self, action: #selector(recordingBtnTapped(_:)), for: .touchUpInside)
        dismissBtn.addTarget(self, action: #selector(dismissBtnTapped(_:)), for: .touchUpInside)
        timerRecordingBtn.addTarget(self, action: #selector(timerRecordingBtnTapped(_:)), for: .touchUpInside)
    }
    
    @objc func dismissBtnTapped(_ sender: UIButton) {
        //        DispatchQueue.main.async {
        //            self.picker.dismiss(animated: true)
        //        }
        self.dismiss(animated: true)
    }
    
    @objc func timerRecordingBtnTapped(_ sender: UIButton) {
        // 정보를 보내기만 하고 여기서 뭘 안하네..
        // TODO: - Trigger Video Recording
        startRecording()
        let dateInMilliSec = Date().millisecondsSince1970 + 1500 // give 1.5s to sync better
        connectionManager.send(MsgWithTime(msg: .startRecording, timeInMilliSec: Int(dateInMilliSec)))
        
    }
    
    
    
    @objc func recordingBtnTapped(_ sender: UIButton) {
        print("recordingBtn Tapped!!")
        
        recordingBtnAction()
    }
    
    
    private func sendRecordingMsg() {
        connectionManager.send(DetailPositionWIthMsgInfo(message: .startRecording, detailInfo: PositionWithDirectionInfo(title: positionTitle, direction: direction, score: score)))
    }
    
    private func sendStopMsg() {
        connectionManager.send(DetailPositionWIthMsgInfo(message: .stopRecording, detailInfo: PositionWithDirectionInfo(title: positionTitle, direction: direction, score: score)))
    }
    
    
    func recordingBtnAction() {
        // Start Recording!!
        if !isRecording {
            
            DispatchQueue.main.async {
                self.picker.startVideoCapture()
            }
            
            sendRecordingMsg()
            
            DispatchQueue.main.async {
                self.recordingBtn.setTitle("Stop", for: .normal)
            }
            
            print("START Recording")
            triggerDurationTimer() // working fine
            // STOP Recording !!
        } else {
            DispatchQueue.main.async {
                self.picker.stopVideoCapture()
                self.recordingBtn.setTitle("Record", for: .normal)
                self.stopTimer()
            }
            sendStopMsg()
            
            print("STOP Recording")
        }
        
        isRecording.toggle()
    }
    
    private func stopTimer() {
        timer.invalidate()
    }
    
    func setupLayout() {
        print("present Picker!!")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
            self.bottomView.frame = CGRect(x:0, y: screenHeight - (screenHeight - screenWidth) / 2, width: screenWidth, height: (screenHeight - screenWidth) / 2)
            
            self.bottomView.addSubview(self.recordingBtn)
            self.recordingBtn.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.height.equalTo(50)
                make.width.equalTo(150)
            }
            
            self.bottomView.addSubview(self.connectionStateLabel)
            self.connectionStateLabel.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalTo(self.recordingBtn.snp.leading)
            }
            
            self.bottomView.addSubview(self.dismissBtn)
            self.dismissBtn.snp.makeConstraints { make in
                make.right.equalToSuperview()
                make.centerY.equalToSuperview()
                make.height.equalTo(50)
                make.width.equalTo(100)
            }
            
            self.bottomView.addSubview(self.timerRecordingBtn)
            self.timerRecordingBtn.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(self.recordingBtn.snp.top).offset(-10)
                //                make.width.equalToSuperview()
                make.width.equalTo(150)
                make.height.equalTo(50)
            }
            
            self.bottomView.addSubview(self.durationLabel)
            self.durationLabel.snp.makeConstraints { make in
                //                make.centerX.equalToSuperview()
                make.centerY.equalTo(self.timerRecordingBtn.snp.centerY)
                make.height.equalTo(50)
                make.leading.equalTo(self.timerRecordingBtn.snp.trailing)
                make.trailing.equalToSuperview()
            }
            
            
            //            self.picker = UIImagePickerController()
            
            //            guard let picker = self.picker else { return }
            
            self.picker.allowsEditing = true
            self.picker.sourceType = .camera
            self.picker.delegate = self
            self.picker.mediaTypes = [kUTTypeMovie as String]
            self.picker.cameraOverlayView = self.bottomView
            self.picker.showsCameraControls = false
            self.picker.preferredContentSize = CGSize(width: self.view.frame.width,
                                                      height: self.view.frame.width)
            
            self.view.addSubview(self.picker.view)
            self.picker.view.snp.makeConstraints { make in
                make.leading.top.trailing.bottom.equalToSuperview()
            }
            
            //            self.present(picker, animated: true)
        }
    }
    
    // MARK: - UI Properties
    private let bottomView = UIView().then { $0.backgroundColor = .black }
    
    //    private let testView = UIView().then {
    //
    //        $0.backgroundColor = .magenta
    //        $0.frame = CGRect(x: 300, y: screenHeight - 100, width: 400.0, height: 100)
    //    }
    
    private let imageView = UIImageView()
    
    private let connectionStateLabel = UILabel().then {
        
        $0.textColor = .white
    }
    
    private let recordingBtn = UIButton().then {
        $0.setTitle("Record", for: .normal)
        $0.setTitleColor(.white, for: .normal)
    }
    
    private let durationLabel = UILabel().then {
        $0.textColor = .white
        $0.text = "00:00"
        $0.textAlignment = .center
        $0.backgroundColor = .magenta
    }
    
    private let dismissBtn = UIButton().then {
        $0.setTitle("Dismiss!", for: .normal)
    }
    
    private let timerRecordingBtn = UIButton().then {
        $0.setTitle("Record in 3s", for: .normal)
        $0.setTitleColor(.white, for: .normal)
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
        
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
              mediaType == (kUTTypeMovie as String),
              //            let crop = info[UIImagePickerController.InfoKey.cropRect], // makes fail.. TT..
              // the delegate method gives a URL pointing to the video
                let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
              
                // Verify that the app can save the file to the device's photo album
              
                UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
                
        else {
            print("failed to get url Path!")
            return
        }
        print("save success !")
        // Save Video To Photos Album
        UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, nil, nil)
        
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
                self.connectionStateLabel.text = "Disconnected!"
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
