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


class CameraController: UIViewController {
    
// MARK: - Properties
    let positionTitle: String
    let direction: PositionDirection
    var score: Int?
    
    var connectionManger: ConnectionManager
        
    var timer = Timer()
    var count = 0
    
    private var picker : UIImagePickerController?
    
    private var isRecording = false
    
    init(positionWithDirectionInfo: PositionWithDirectionInfo, connectionManager: ConnectionManager) {
        self.positionTitle = positionWithDirectionInfo.title
        self.direction = positionWithDirectionInfo.direction
        self.score = positionWithDirectionInfo.score
        self.connectionManger = connectionManager
        super.init(nibName: nil, bundle: nil)
    }
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAddTargets()
        presentPicker()
        addNotificationObservers()
    }
    
    
    // MARK: - Notification
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(startRecording(_:)),
                                               name: NotificationKeys.startRecording, object: nil)
    }
    
    @objc func startRecording(_ notification: Notification) {
        print("startRecording has been triggered by observer. ")
        guard let title = notification.userInfo?["title"] as? String,
              let direction = notification.userInfo?["direction"] as? PositionDirection,
              let score = notification.userInfo?["score"] as? Int? else { return }
        
        let positionWithDirectionInfo = PositionWithDirectionInfo(title: title, direction: direction, score: score)
        
        print("positionInfo -> title: \(title) , direction: \(direction), score: \(score)")
//        startVideoCapture
        DispatchQueue.main.async {
            self.picker?.startVideoCapture()
        }
    }
    
    
    // Duration
    private func triggerTimer() {
        count = 0
        print("timer triggered!!")
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let `self` = self else { return }
            
            print("trigger working!")
            self.count += 1
            self.updateDurationLabel()
        }
    }
    
    private func updateDurationLabel() {
        print("updateDuration Triggered!")
        
        let recordingDuration = convertIntoFormat(count)
        
        DispatchQueue.main.async {
            self.durationLabel.text = recordingDuration
        }
    }
    
   
    
    
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

    // MARK: - Button Actions
    private func setupAddTargets() {

        recordingBtn.addTarget(self, action: #selector(recordingBtnTapped(_:)), for: .touchUpInside)
        dismissBtn.addTarget(self, action: #selector(dismissBtnTapped(_:)), for: .touchUpInside)
    }
    
    @objc func dismissBtnTapped(_ sender: UIButton) {
        picker?.dismiss(animated: true)
    }
    
    @objc func recordingBtnTapped(_ sender: UIButton) {
        print("recordingBtn Tapped!!")
        recordingBtnAction()
    }
    

    
    func recordingBtnAction() {
        // Start Recording!!
        if !isRecording {
            
            DispatchQueue.main.async {
                self.picker?.startVideoCapture()
            }
             
            connectionManger.send(DetailPositionWIthMsgInfo(message: .startRecording, detailInfo: PositionWithDirectionInfo(title: positionTitle, direction: direction, score: score)))
            
            DispatchQueue.main.async {
                self.recordingBtn.setTitle("Stop", for: .normal)
            }
            
            print("START Recording")
            triggerTimer()
        // STOP Recording !!
        } else {
            DispatchQueue.main.async {
                self.picker?.stopVideoCapture()
                self.recordingBtn.setTitle("Record", for: .normal)
                self.stopTimer()
            }
            
            print("STOP Recording")
        }
        
        isRecording.toggle()
    }
    
    private func stopTimer() {
        timer.invalidate()
    }
    
    func presentPicker() {
        print("present Picker!!")
        
//        let customHeight: CGFloat = (screenHeight - screenWidth) / 2
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
            self.bottomView.frame = CGRect(x:0, y: screenHeight - (screenHeight - screenWidth) / 2, width: screenWidth, height: (screenHeight - screenWidth) / 2)
            
            self.bottomView.addSubview(self.recordingBtn)
            self.recordingBtn.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.height.equalTo(50)
                make.width.equalTo(200)
            }
            
            self.bottomView.addSubview(self.durationLabel)
            self.durationLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(self.recordingBtn.snp.bottom).offset(10)
                make.height.equalTo(50)
                make.width.equalTo(100)
            }
            
            self.bottomView.addSubview(self.connectionStateLabel)
            self.connectionStateLabel.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.leading.equalToSuperview().offset(10)
                make.trailing.equalTo(self.recordingBtn.snp.leading)
            }
            
            self.bottomView.addSubview(self.dismissBtn)
            self.dismissBtn.snp.makeConstraints { make in
                make.right.equalToSuperview()
                make.centerY.equalToSuperview()
                make.height.equalTo(50)
                make.width.equalTo(100)
            }
            
            self.picker = UIImagePickerController()
            
            guard let picker = self.picker else { return }
            picker.allowsEditing = true
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = [kUTTypeMovie as String]
            picker.cameraOverlayView = self.bottomView
            picker.showsCameraControls = false
            picker.preferredContentSize = CGSize(width: self.view.frame.width, height: self.view.frame.width)
            
                self.present(picker, animated: true)
        }
    }
    
    // MARK: - UI Properties
    private let bottomView = UIView().then { $0.backgroundColor = .black }

    private let testView = UIView().then {
        $0.backgroundColor = .magenta
        $0.frame = CGRect(x: 300, y: screenHeight - 100, width: 400.0, height: 100)
    }
    
    private let imageView = UIImageView()

    private let connectionStateLabel = UILabel().then {
        
        $0.textColor = .black
    }
    
    private let recordingBtn = UIButton().then {
        $0.setTitle("Record", for: .normal)
        $0.setTitleColor(.white, for: .normal)
    }
    
    private let durationLabel = UILabel().then {
        $0.textColor = .white
        $0.text = "00:00"
        $0.textAlignment = .center
    }
    
    private let dismissBtn = UIButton().then {
        $0.setTitle("Dismiss!", for: .normal)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UIImagePickerController Delegate
extension CameraController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
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
          print("fail!")
          return
      }
        print("save success !")
        // Save Video To Photos Album
        UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, nil, nil)
        
//        dismiss(animated: true)
    }
}

// MARK: - Connection Manager Delegate
extension CameraController: ConnectionManagerDelegate {
    func updateDuration(in seconds: Int) {
        
    }
    
    func presentVideo() {
        
    }
    
    func updateState(state: ConnectionState) {
        
        switch state {
        case .disconnected:
            DispatchQueue.main.async {
                self.connectionStateLabel.text = "DisConnected!"
            }
        case .connected:
            DispatchQueue.main.async {
                self.connectionStateLabel.text = "Connected!"
            }
        case .connecting:
            break
        }
    }
}
