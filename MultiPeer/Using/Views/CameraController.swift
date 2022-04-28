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

    let positionTitle: String
    let direction: PositionDirection
    var score: Int?
    
    var connectionManger: ConnectionManager
    
//    init(positionTitle: String, direction: PositionDirection, score: Int?, connectionManager: ConnectionManager) {
    
    init(positionWithDirectionInfo: PositionWithDirectionInfo, connectionManager: ConnectionManager) {
        self.positionTitle = positionWithDirectionInfo.title
        self.direction = positionWithDirectionInfo.direction
        self.score = positionWithDirectionInfo.score
        self.connectionManger = connectionManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var picker : UIImagePickerController?
    private var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupAddTargets()
        presentPicker()
//        connectionManger.send
    }
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
      let title = (error == nil) ? "Success" : "Error"
      let message = ( error == nil) ? "Video was saved" : "Video failed to save"
      
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
      present(alert, animated: true)
      
    }

    
    private func setupLayout() {
        
    }
    
    private func setupAddTargets() {

        recordingBtn.addTarget(self, action: #selector(recordingBtnTapped(_:)), for: .touchUpInside)
        dismissBtn.addTarget(self, action: #selector(dismissBtnTapped(_:)), for: .touchUpInside)
    }
    
    @objc func dismissBtnTapped(_ sender: UIButton) {
//        let mydelegate = picker?.delegate

        
        picker?.dismiss(animated: true)
    }
    
    @objc func recordingBtnTapped(_ sender: UIButton) {
        print("recordingBtn Tapped!!")
        if !isRecording {
            picker?.startVideoCapture()
            print("recording Start !")
        } else {
            picker?.stopVideoCapture()
            print("video stop!")
        }
        isRecording.toggle()
    }
    
    func presentPicker() {
        let customHeight: CGFloat = 150
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let someView = UIView(frame: CGRect(x:0, y: screenHeight - customHeight, width: screenWidth, height: customHeight))
            someView.backgroundColor = .magenta
            
            someView.addSubview(self.recordingBtn)
            self.recordingBtn.snp.makeConstraints { make in
//                make.left.bottom.equalToSuperview()
                make.center.equalToSuperview()
                make.height.equalTo(50)
                make.width.equalTo(200)
                
            }
            
            someView.addSubview(self.dismissBtn)
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
            picker.cameraOverlayView = someView
            picker.showsCameraControls = false
            picker.preferredContentSize = CGSize(width: self.view.frame.width, height: self.view.frame.width)
            
            self.present(picker, animated: true)
        }
    print("present Picker!!")
//        let someView = UIView(frame: CGRect(x: 100.0, y: screenHeight - 200, width: screenWidth - 200.0, height: 200))
//        someView.backgroundColor = .magenta
//
//        someView.addSubview(recordingBtn)
//        recordingBtn.snp.makeConstraints { make in
//            make.left.bottom.equalToSuperview()
//            make.height.equalTo(50)
//            make.width.equalTo(200)
//
//        }
//
//        someView.addSubview(dismissBtn)
//        dismissBtn.snp.makeConstraints { make in
//            make.left.top.right.equalToSuperview()
//            make.width.equalTo(200)
//        }
//
//        picker = UIImagePickerController()
//
//        guard let picker = picker else { return }
//        picker.allowsEditing = true
//        picker.sourceType = .camera
//        picker.delegate = self
//        picker.mediaTypes = [kUTTypeMovie as String]
//        picker.cameraOverlayView = someView
//        picker.showsCameraControls = false
//        picker.preferredContentSize = CGSize(width: view.frame.width, height: view.frame.width)
//
//        present(picker, animated: true)
    }
    

    
    
    private let testView: UIView = {
        let v = UIView()
        let viewHeight = 100.0
        v.backgroundColor = .magenta
        v.frame = CGRect(x: 300, y: screenHeight - viewHeight, width: 400.0, height: viewHeight)
        return v
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        return iv
        
    }()

    private let recordingBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Record", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        return btn
    }()
    
    private let dismissBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Dismiss!", for: .normal)
        return btn
    }()
    
}

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


public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

// Screen height.
public var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}
