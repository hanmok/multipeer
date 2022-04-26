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

    private var picker : UIImagePickerController?
    private var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupAddTargets()

    }
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject) {
      let title = (error == nil) ? "Success" : "Error"
      let message = ( error == nil) ? "Video was saved" : "Video failed to save"
      
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
      present(alert, animated: true)
      
    }

    
    private func setupLayout() {
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
//            make.bottom.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(40)
        }
    }
    
    private func setupAddTargets() {
        button.addTarget(self, action: #selector(didTapPressed(_:)), for: .touchUpInside)
        recordingBtn.addTarget(self, action: #selector(recordingBtnTapped(_:)), for: .touchUpInside)
        dismissBtn.addTarget(self, action: #selector(dismissBtnTapped(_:)), for: .touchUpInside)
    }
    
    @objc func dismissBtnTapped(_ sender: UIButton) {
        let mydelegate = picker?.delegate
//        mydelegate?.imagePickerController?(picker!, didFinishPickingMediaWithInfo: [UIImagePickerController.InfoKey : Any] as String)
        
        mydelegate?.imagePickerController?(picker!, didFinishPickingMediaWithInfo: [UIImagePickerController.InfoKey.mediaType: kUTTypeMovie, UIImagePickerController.InfoKey.mediaURL: URL(fileURLWithPath: "file:private/var/mobile/Containers/Data/Application/DCEAA1AD-2808-4FF6-9182-C39D74A5E04B/tmp/67265451586__72322A03-DADC-4049-8597-EB8336AFC209.MOV")])
        
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
    
    @objc func didTapPressed(_ sender: UIButton) {
        
        let someView = UIView(frame: CGRect(x: 100.0, y: screenHeight - 200, width: screenWidth - 200.0, height: 200))
        someView.backgroundColor = .magenta
        
        someView.addSubview(recordingBtn)
        recordingBtn.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(200)
            
        }
        
        someView.addSubview(dismissBtn)
        dismissBtn.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.width.equalTo(200)
        }
        
        
        print("btn tapped!!")
//        let picker = UIImagePickerController()
        picker = UIImagePickerController()
        
        guard let picker = picker else { return }
        picker.allowsEditing = true
        picker.sourceType = .camera
        picker.delegate = self
        picker.mediaTypes = [kUTTypeMovie as String]
//        picker.isBeingDismissed = true
//        picker.imageExportPreset = .
//        picker.cameraOverlayView = testView
        picker.cameraOverlayView = someView
        picker.showsCameraControls = false
        
//        picker.fin
//        picker.tabBarObservedScrollView?.zoomScale = 0.5
//        picker.tabBarObservedScrollView?.setZoomScale(0.5, animated: true)
//        picker.zoom
//        picker.cameraViewTransform = CGAffineTransform.scaledBy(CGAffineTransform(translationX: 1, y: 1))
//        picker.size
        picker.preferredContentSize = CGSize(width: view.frame.width, height: view.frame.width)
        
        present(picker, animated: true)
        
    }
    
    private let button: UIButton = {
        let btn = UIButton()
        btn.setTitle("present", for: .normal)
        return btn
        
    }()
    
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
        
//        if let media = info[UIImagePickerController.InfoKey.]
      guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
              mediaType == (kUTTypeMovie as String),
            let crop = info[UIImagePickerController.InfoKey.cropRect],
              // the delegate method gives a URL pointing to the video
              let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
           
              // Verify that the app can save the file to the device's photo album
              UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
             
      else {
          print("fail!")
          return }
      print("success!!")
//        picker.edi
      // If it can, save it.
//      UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)),nil)
        
        UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, nil, nil)
        
        dismiss(animated: true)
    }
    
    
    
    
    
    
}




public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

// Screen height.
public var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}
