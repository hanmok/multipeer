//
//  ViewController.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/13.
//

import UIKit
import MultipeerConnectivity
import SnapKit
import AVFoundation
import MobileCoreServices

struct OrderMessage: Identifiable, Equatable, Codable {

    var id = UUID()

    var orderTypeString: String
}

public enum OrderMessageTypes {
    static let presentCamera = "presentCamera"
    static let startRecording = "startRecording"
    static let stopRecording = "stopRecording"
    static let save = "save"
}


protocol MainVCDelegate: NSObject {
    func startRecord()
    func stopRecord()
}


class MainViewController: UIViewController, UINavigationBarDelegate {

    weak var delegate: MainVCDelegate?
    
    var connectionManager = ConnectionManager()
    
//    let recordingVC = RecordingViewController(connectionManager: connectionmana)
    
    // MARK: - Properties
//    var videoHelper = VideoHelper()
    
    var count = 0
    var timer: Timer = Timer()
    
    let sessionButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Session", for: .normal)
        btn.setTitleColor(.green, for: .normal)
        return btn
    }()
    
    let cameraButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Camera Btn!", for: .normal)
        btn.setTitleColor(.green, for: .normal)
        return btn
    }()
    
    let startTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Start time "
        return label
    }()
    
    let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "Duration"
        return label
    }()
    
    let endTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "endTime "
        return label
    }()
    
    let connectionStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Connection State"
        return label
    }()
    
    let orderButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Order", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        return btn
    }()
    
    let receivedData:UILabel = {
        let label = UILabel()
        label.text = "Received Data"
        return label
    }()
    
    let triggerVideoButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Video", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        return btn
    }()
    
    deinit {
        print("MainVC deinitiated.")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("view has disappeared!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupTarget()
        
        connectionManager.delegate = self
//        videoHelper.delegate = self
        
        addNotifications()
    }
    
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(orderStartRecording(_:)), name: NSNotification.Name(NotificationKeys.startRecordingFromIPC), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(orderStopRecording(_:)), name: NSNotification.Name(NotificationKeys.stopRecordingFromIPC), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(orderSave(_:)), name: NSNotification.Name(NotificationKeys.saveFromIPC), object: nil)
    }
    
    @objc func orderStartRecording(_ notification: Notification) {
        print("flag4")
        print("orderStartRecording!")
        // 여기 코드가 문제임..
        connectionManager.send(OrderMessageTypes.startRecording)
    print("flag5")
    }

    @objc func orderStopRecording(_ notification: Notification) {
//        print("orderStopRecording!")
        connectionManager.send(OrderMessageTypes.stopRecording)
    }
    
    @objc func orderSave(_ notification: Notification) {
        
    }
    
    @objc func didReceiveTestNotification(_ notification: Notification) {
        print("Test succeed!")
    }
    
    
    
    
    
                              
    
    
    @objc func showConnectivityAction(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Todo Exchange", message: "Do you want to Host or Join a session?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Host Session", style: .default, handler: { (action: UIAlertAction) in
            self.connectionManager.host()
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Join Session", style: .default, handler: { (action: UIAlertAction) in
            self.connectionManager.join()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - Video
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
      let title = (error == nil) ? "Success" : "Error"
      let message = ( error == nil) ? "Video was saved" : "Video failed to save"
      
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
      present(alert, animated: true)
      
    }
    
    func setupTarget() {
        
        sessionButton.addTarget(self, action: #selector(showConnectivityAction(_:)), for: .touchUpInside)
        
        cameraButton.addTarget(self, action: #selector(cameraBtnTapped(_:)), for: .touchUpInside)
        
        orderButton.addTarget(self, action: #selector(orderAny(_:)), for: .touchUpInside)
        
        triggerVideoButton.addTarget(self, action: #selector(triggerVideo(_:)), for: .touchUpInside)
        
        triggerVideoButton.addTarget(self, action: #selector(triggerTimer(_:)), for: .touchUpInside)
        
}
    
    @objc func triggerTimer(_ sender: UIButton) {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
    }
    
    @objc func timerCounter() -> Void
    {
        count = count + 1
        receivedData.text = String(count)
    }
    
    
    // Start Recording! Btn
    @objc func cameraBtnTapped(_ sender: UIButton) {
        print("Camera Btn Tapped!")
        
//        videoHelper.startMediaBrowser2()
    }
    
    @objc func orderAny(_ sender: UIButton) {
        print("data has sent")

        connectionManager.send(OrderMessageTypes.presentCamera)
        // original Code
//        VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
//        videoHelper.startMediaBrowser2()
        let recordingVC = RecordingViewController(connectionManager: connectionManager)
        
        recordingVC.modalPresentationStyle = .fullScreen
        self.present(recordingVC, animated: true)
        
        receivedData.text = String(count)
        count += 1
        

        if let lastMsg = ConnectionManager.messages.last {
            receivedData.text = lastMsg.body
        }
    }
    
    @objc func triggerVideo(_ sender: UIButton) {
        print("video triggered!")
    }
    
    
    func setupLayout() {
        view.addSubview(sessionButton)
        sessionButton.snp.makeConstraints { make in
            make.centerY.equalTo(view)
            make.right.equalTo(view)
            make.height.width.equalTo(100)
        }
        
        view.addSubview(cameraButton)
        cameraButton.snp.makeConstraints { make in
            make.centerY.left.equalTo(view)
            make.width.equalTo(200)
            make.height.equalTo(100)
        }
        
        view.addSubview(startTimeLabel)
        startTimeLabel.snp.makeConstraints { make in
            make.top.left.equalTo(view.safeAreaLayoutGuide)
            make.height.width.equalTo(100)
        }
        
        view.addSubview(endTimeLabel)
        endTimeLabel.snp.makeConstraints { make in
            make.top.right.equalTo(view.safeAreaLayoutGuide)
            make.height.width.equalTo(100)
        }
        
        view.addSubview(durationLabel)

        durationLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.equalTo(startTimeLabel.snp.right)
            make.right.equalTo(endTimeLabel.snp.left)
            make.height.equalTo(100)
        }

        view.addSubview(connectionStateLabel)
        connectionStateLabel.snp.makeConstraints { make in
            make.top.equalTo(cameraButton.snp.bottom).offset(100)
            make.centerX.equalTo(view)
            make.height.equalTo(100)
            make.width.equalTo(200)
        }
        
        view.addSubview(orderButton)
        orderButton.snp.makeConstraints { make in
            make.top.equalTo(connectionStateLabel.snp.bottom)
            make.left.equalTo(view)
            make.height.equalTo(100)
            make.width.equalTo(200)
        }
        
        view.addSubview(receivedData)
        receivedData.snp.makeConstraints { make in
            make.bottom.equalTo(orderButton) // bottom 써야하나?
            make.left.equalTo(orderButton.snp.right)
            make.height.equalTo(100)
            make.width.equalTo(200)
        }
        
        view.addSubview(triggerVideoButton)
        triggerVideoButton.snp.makeConstraints { make in
            make.top.equalTo(orderButton.snp.bottom)
            make.left.equalTo(view)
            make.height.equalTo(100)
            make.width.equalTo(200)
        }
    }
}


// MARK: - ConnectionManagerDelegate
extension MainViewController: ConnectionManagerDelegate {
    

    func updateState(state: String) {
        DispatchQueue.main.async {
            self.connectionStateLabel.text = state
        }
    }
    
    func showDuration(_ startAt: Date, _ endAt: Date) {
        
        let startedTime = startAt.toString(dateFormat: "a HH:mm")
        let endTime = endAt.toString(dateFormat: "a HH:mm")
        DispatchQueue.main.async {
            self.startTimeLabel.text = startedTime
            self.endTimeLabel.text = endTime
            self.durationLabel.text = String((endAt.timeIntervalSince1970 - startAt.timeIntervalSince1970) / 60) + String("min")
        }
    }
    
    func disconnected(state: String, timeDuration: Int) {
        DispatchQueue.main.async {
            self.durationLabel.text = String("remained for ")+String(timeDuration) + String("s")
            self.connectionStateLabel.text = state
            self.endTimeLabel.text = String(Date().toString(dateFormat: "a HH:mm"))
        }
    }

    func showStart(_ startAt: Date) {
        let startedTime = startAt.toString(dateFormat: "a HH:mm")
        DispatchQueue.main.async {
            self.startTimeLabel.text = startedTime
            self.durationLabel.text = ""
            self.endTimeLabel.text = ""
        }
        
    }
    
    func updateDuration(_ startAt: Date, current: Date) {
        DispatchQueue.main.async {
            self.durationLabel.text = String((current.timeIntervalSince1970 - startAt.timeIntervalSince1970) ) + String("sec")
        }
        
    }
    
    func presentVideo() {
        print(#function, "PresentVideo called from ViewController")
        print("self: \(self)")
        
//        videoHelper.startMediaBrowser2()
        
    }
}



// MARK: - UIImagePickerControllerDelegate
extension MainViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        
    }
     func some() {
        print("extended custom implementation")
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("ended!")
      dismiss(animated: true)
      
      guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
              mediaType == (kUTTypeMovie as String),
            
              // the delegate method gives a URL pointing to the video
              let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
              
              // Verify that the app can save the file to the device's photo album
              UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
              
      else { return }
      
      // If it can, save it.
      UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)),
                                          nil)
    }
}

extension MainViewController: UINavigationControllerDelegate {
    
}
