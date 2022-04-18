
import MobileCoreServices
import UIKit

class VideoHelper {
    
    
    static func startMediaBrowser(
        delegate: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate,
        sourceType: UIImagePickerController.SourceType
    ) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType)
        else { return }
        
        DispatchQueue.main.async {
            let mediaUI = UIImagePickerController()
            mediaUI.sourceType = sourceType
            mediaUI.mediaTypes = [kUTTypeMovie as String]
            mediaUI.allowsEditing = true
            mediaUI.delegate = delegate
            delegate.present(mediaUI, animated: true, completion: nil)
            
            //            mediaUI.perform(#selector(UIImagePickerController.startVideoCapture), with: nil, afterDelay: 3)
            
            //            mediaUI.perform(#selector(UIImagePickerController.stopVideoCapture), with: nil, afterDelay: 10)
            
            //            mediaUI.showsCameraControls = false
            
            //            mediaUI.startVideoCapture()
            
            
            let startBtn: UIButton = {
                let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
                btn.layer.borderColor = UIColor.red.cgColor
                btn.layer.borderWidth = 2
                btn.setTitle("start", for: .normal)
                btn.setTitleColor(.magenta, for: .normal)
                return btn
            }()
            
            let endBtn: UIButton = {
                let btn = UIButton(frame: CGRect(x: 300, y: 0, width: 50, height: 30))
                btn.layer.borderColor = UIColor.blue.cgColor
                btn.layer.borderWidth = 2
                btn.setTitle("end", for: .normal)
                btn.setTitleColor(.blue, for: .normal)
                return btn
            }()
            
            
            let view = UIView(frame: CGRect(x: 0, y: 600, width: 400, height: 100))
            view.addSubview(endBtn)
            view.addSubview(startBtn)
            
            mediaUI.cameraOverlayView = view
            
            endBtn.addTarget(nil, action: #selector(UIImagePickerController.didEndTapped(_:)), for: .touchUpInside)
            
            startBtn.addTarget(nil, action: #selector(UIImagePickerController.didStartTapped(_:)), for: .touchUpInside)
        }
    }
}



extension UIImagePickerController {
    
    @objc func didStartTapped(_ sender: UIButton) {
        print("start tapped!")
        self.startVideoCapture()
    }
    
    @objc func didEndTapped(_ sender: UIButton) {
        print("end tapped")
        self.stopVideoCapture()
    }
    
    
}
