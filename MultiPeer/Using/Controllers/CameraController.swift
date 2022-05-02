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
    
    var updatingDurationTimer = Timer()
    var decreasingTimer = Timer()
    var count = 0
    var decreasingCount = 3
    
    //    private var picker : UIImagePickerController?
    private var picker = UIImagePickerController()
    
    private var isRecording = false
    
    init(positionWithDirectionInfo: PositionWithDirectionInfo, connectionManager: ConnectionManager) {
        self.positionTitle = positionWithDirectionInfo.title
        self.direction = positionWithDirectionInfo.direction
        self.score = positionWithDirectionInfo.score
        self.connectionManager = connectionManager
        super.init(nibName: nil, bundle: nil)
        
        self.title = positionWithDirectionInfo.title
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
                                               name: .startRecordingKey, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopRecordingNotificationTriggered(_:)),
                                               name: .stopRecordingKey, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(startRecordingAfter(_:)),
                                               name: .startRecordingAfterKey, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(startCountdownAfter(_:)),
                                               name: .startCountdownAfterKey, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateConnectionState(_:)),
                                               name: .updateConnectionStateKey, object: nil)
    }
    
    @objc func startRecordingTriggered(_ notification: Notification) {
        print("flag1")
        print("startRecording has been triggered by observer. ")
        guard let title = notification.userInfo?["title"] as? String,
              let direction = notification.userInfo?["direction"] as? PositionDirection,
              let score = notification.userInfo?["score"] as? Int? else { return }
        
        startRecording()
        // duration update needed
    }
    
    
    @objc func stopRecordingNotificationTriggered(_ notification: Notification) {
        print("flag2")
        print("stopRecording has been triggered by observer. ")
        guard let title = notification.userInfo?["title"] as? String,
              let direction = notification.userInfo?["direction"] as? PositionDirection,
              let score = notification.userInfo?["score"] as? Int? else { return }
        
            stopRecording()
    }
    
    @objc func startRecordingAfter(_ notification: Notification) {
        print("flag3")
        print(#function, #line)
        guard let milliTime = notification.userInfo?["receivedTime"] as? Int,
//              let msg = notification.userInfo?["msg"] as? RecordingType
              let msg = notification.userInfo?["msg"] as? MessageType
        else {
            print("fail to convert receivedTime to Int", #line)
            // millisec since 1970
//            print(error?.localizedDescription)
            return
        }
        print(#function, #line)
        print("receivedMillisecData: \(milliTime)")
        print("currentMillisecData: \(Date().millisecondsSince1970)")
        
        let recordingTimer = Timer(fireAt: Date(milliseconds: milliTime), interval: 0, target: self, selector: #selector(startRecording), userInfo: nil, repeats: false)
        
        DispatchQueue.main.async {
            self.recordingTimerBtn.setTitle("\(milliTime)", for: .normal)
            
        }
        
        RunLoop.main.add(recordingTimer, forMode: .common)
        print("startRecordingAfter has ended", #line)
    }
    
    
    @objc func startCountdownAfter(_ notification: Notification) {
        print("flag4")
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
    
    
    @objc func updateConnectionState(_ notification: Notification) {
        print("flag5")
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
    
    
    
    // MARK: - Button Actions
    private func setupAddTargets() {
        recordingBtn.addTarget(self, action: #selector(recordingBtnTapped(_:)), for: .touchUpInside)
        dismissBtn.addTarget(self, action: #selector(dismissBtnTapped(_:)), for: .touchUpInside)
        recordingTimerBtn.addTarget(self, action: #selector(timerRecordingBtnTapped(_:)), for: .touchUpInside)
    }
    
    
    
    @objc func recordingBtnTapped(_ sender: UIButton) {
        print("recordingBtn Tapped!!")
        
        recordingBtnAction()
    }
    
    func recordingBtnAction() {
        // Start Recording!!
        if !isRecording {
            // Send Start Msg
            connectionManager.send(DetailPositionWIthMsgInfo(message: .startRecordingMsg, detailInfo: PositionWithDirectionInfo(title: positionTitle, direction: direction, score: score)))
            
            startRecording()
            // STOP Recording !!
        } else {
            
            stopRecording()
            // Send Stop Msg
            connectionManager.send(DetailPositionWIthMsgInfo(message: .stopRecordingMsg, detailInfo: PositionWithDirectionInfo(title: positionTitle, direction: direction, score: score)))
        }
    }
    
    
    @objc func dismissBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @objc func timerRecordingBtnTapped(_ sender: UIButton) {
        print(#function, #line)
        let dateIn1500ms = Date().millisecondsSince1970 + 1500 // give 1.5s to sync better
//        let dateIn1500ms = Date().millisecondsSince1970 + 3000 // give 1.5s to sync better
        let dateIn4500ms = Date().millisecondsSince1970 + 4500
        
        connectionManager.send(MsgWithTime(msg: .startCountDownMsg, timeInMilliSec: Int(dateIn1500ms)))
        
        connectionManager.send(MsgWithTime(msg: .startRecordingAfterMsg, timeInMilliSec: Int(dateIn4500ms)))
        
        // Make in sync with receiver
        
        let countdownTimer = Timer(fireAt: Date(milliseconds: Int(dateIn1500ms)), interval: 0, target: self, selector: #selector(triggerCountDownTimer), userInfo: nil, repeats: false)
        
        let recordingTimer = Timer(fireAt: Date(milliseconds: Int(dateIn4500ms)), interval: 0, target: self, selector: #selector(startRecording), userInfo: nil, repeats: false)
//        let recordingTimer = Timer(fireAt: Date(milliseconds: Int(dateIn1500ms)), interval: 0, target: self, selector: #selector(startRecording), userInfo: nil, repeats: false)
        

        DispatchQueue.main.async {
//            self.recordingTimerBtn.setTitle(String(Int(dateIn1500ms)), for: .normal)
        }
        
        RunLoop.main.add(countdownTimer, forMode: .common)
        RunLoop.main.add(recordingTimer, forMode: .common)
//        RunLoop.main.minimumTolerance = 0.01
//        print("tolerarnce: \(RunLoop.main.minimumTolerance)")
        
//        RunLoop.main.add(recordingTimer, forMode: .)

        
    }
    
    
    // MARK: - Basic Functions
    @objc private func startRecording() {
         print("startRecording triggered!! ")
        if !isRecording {
            DispatchQueue.main.async {
                self.picker.startVideoCapture()
                self.recordingBtn.setTitle("Stop", for: .normal)
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
                self.recordingBtn.setTitle("Record", for: .normal)
                self.recordingTimerBtn.setTitle("Record in 3s", for: .normal)
            }
            
            self.isRecording = false
            stopTimer()
        }
    }
    
    
    /// updating durationLabel contained
    private func triggerDurationTimer() {
        count = 0
        print("timer triggered!!")
        // 여기까지 일을 하는데, 아래는 안가네 ? 왜지 ??
        
        updatingDurationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let `self` = self else {
                print("self is nil in timer!!")
                return }
            
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
    
    @objc private func triggerCountDownTimer() {
        DispatchQueue.main.async {
//            self.recordingTimerBtn.setTitle(String(self.decreasingCount), for: .normal)
            self.durationLabel.text = "00:00"
            
        }
        
        decreasingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let `self` = self else { return }
            if self.decreasingCount > 0 {
                
                self.decreasingCount -= 1
                
                DispatchQueue.main.async {
                    if self.decreasingCount == 0 {
                        self.recordingTimerBtn.setTitle("Recording!", for: .normal)
                    } else {

                    self.recordingTimerBtn.setTitle(String(self.decreasingCount), for: .normal)
                    }
                }
            } else {
                self.decreasingTimer.invalidate()
//                DispatchQueue.main.async {
//                    self.timerRecordingBtn.setTitle("Recording!", for: .normal)
//                }
                self.decreasingCount = 3
            }
        }
    }
    
    private func stopTimer() {
        updatingDurationTimer.invalidate()
    }
    
    
    func setupLayout() {
        print("present Picker!!")
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
        self.topView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: (screenHeight - screenWidth) / 2)
        
//        view.addSubview(topView)
//        topView.snp.makeConstraints { make in
//            make.top.leading.trailing.equalToSuperview()
//            make.height.equalTo((screenHeight - screenWidth) / 2)
//        }
        
        
            self.bottomView.frame = CGRect(x:0, y: screenHeight - (screenHeight - screenWidth) / 2,
                                           width: screenWidth, height: (screenHeight - screenWidth) / 2)
            
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
            
            self.bottomView.addSubview(self.recordingTimerBtn)
            self.recordingTimerBtn.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(self.recordingBtn.snp.top).offset(-10)
                make.width.equalTo(150)
                make.height.equalTo(50)
            }
            
            self.bottomView.addSubview(self.durationLabel)
            self.durationLabel.snp.makeConstraints { make in
                make.centerY.equalTo(self.recordingTimerBtn.snp.centerY)
                make.height.equalTo(50)
                make.leading.equalTo(self.recordingTimerBtn.snp.trailing)
                make.trailing.equalToSuperview()
            }
            
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
            
        view.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo((screenHeight - screenWidth) / 2)
        }
//        }
    }
    
    // MARK: - UI Properties
    private let bottomView = UIView().then { $0.backgroundColor = .black }
    private let topView = UIView().then { $0.backgroundColor = .black }
    
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
    
    private let recordingTimerBtn = UIButton().then {
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
