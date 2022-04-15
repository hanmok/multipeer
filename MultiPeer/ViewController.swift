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

extension ViewController: ConnectionManagerDelegate {
    
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
//            self.durationLabel.text = String((current.timeIntervalSince1970 - startAt.timeIntervalSince1970) / 60) + String("min")
            self.durationLabel.text = String((current.timeIntervalSince1970 - startAt.timeIntervalSince1970) ) + String("sec")
        }
        
    }
    
    func presentVideo() {
        print(#function, "PresentVideo called from ViewController")
        print("self: \(self)")
        VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
        
    }
}

class ViewController: UIViewController {
    
    var connectionManager = ConnectionManager()
    // MARK: - Properties
    
    var count = 0
    

    let sessionButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Session", for: .normal)
        btn.setTitleColor(.green, for: .normal)
        return btn
    }()
    
    let cameraButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Start Recording!", for: .normal)
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
        btn.setTitle("Video ", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupLayout()
        setupTarget()
        
        connectionManager.delegate = self
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
}
    // Start Recording! Btn
    @objc func cameraBtnTapped(_ sender: UIButton) {
        print("Camera Btn Tapped!")
          VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
    }
    
    @objc func orderAny(_ sender: UIButton) {
        print("data has sent")
        connectionManager.send(String(count))
        // original Code
        //        VideoHelper.startMediaBrowser(delegate: self, sourceType: .camera)
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
        sessionButton.translatesAutoresizingMaskIntoConstraints = false
        sessionButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        sessionButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        sessionButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        sessionButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        view.addSubview(cameraButton)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        cameraButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        cameraButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        cameraButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        view.addSubview(startTimeLabel)
        startTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        startTimeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        startTimeLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        startTimeLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        startTimeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        view.addSubview(endTimeLabel)
        endTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        endTimeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        endTimeLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        endTimeLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        endTimeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        view.addSubview(durationLabel)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        durationLabel.leftAnchor.constraint(equalTo: startTimeLabel.rightAnchor).isActive = true
        durationLabel.rightAnchor.constraint(equalTo: endTimeLabel.leftAnchor).isActive = true
        durationLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true

        
        
        view.addSubview(connectionStateLabel)
        connectionStateLabel.translatesAutoresizingMaskIntoConstraints = false
//        connectionStateLabel.topAnchor.constraint(equalTo: endTimeLabel.bottomAnchor).isActive = true
        connectionStateLabel.topAnchor.constraint(equalTo: cameraButton.bottomAnchor, constant: 100).isActive = true
//        connectionStateLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        connectionStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        connectionStateLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        connectionStateLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        view.addSubview(orderButton)
        orderButton.translatesAutoresizingMaskIntoConstraints = false
        orderButton.topAnchor.constraint(equalTo: connectionStateLabel.bottomAnchor).isActive = true
        orderButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        orderButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        orderButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        orderButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        view.addSubview(receivedData)
        receivedData.translatesAutoresizingMaskIntoConstraints = false
        receivedData.bottomAnchor.constraint(equalTo: orderButton.bottomAnchor).isActive = true
        receivedData.leftAnchor.constraint(equalTo: orderButton.rightAnchor).isActive = true
        receivedData.heightAnchor.constraint(equalToConstant: 100).isActive = true
        receivedData.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        view.addSubview(triggerVideoButton)
        triggerVideoButton.translatesAutoresizingMaskIntoConstraints = false
        triggerVideoButton.topAnchor.constraint(equalTo: orderButton.bottomAnchor).isActive = true
        triggerVideoButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        triggerVideoButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        triggerVideoButton.widthAnchor.constraint(equalToConstant: 200).isActive = true

    }
    
    
    
    
    
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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

extension ViewController: UINavigationControllerDelegate {
    
}
