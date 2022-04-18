
import MobileCoreServices
import UIKit





public enum NotificationKeys {
    
    // ImagePickerController -> ViewController
    static let startRecordingFromIPC = "startRecordingFromIPC"
    static let stopRecordingFromIPC = "stopRecordingFromIPC"
    static let saveFromIPC = "saveFromIPC"
    
    // ViewController -> ImagePickerCOntroller
    static let startRecordingFromVC = "startRecordingFromVC"
    static let stopRecordingFromVC = "stopRecordingFromVC"
    
}


typealias VideoDelegate =  UIViewController & UINavigationBarDelegate & UIImagePickerControllerDelegate


class VideoHelper {
    
//    weak var delegate: videoDelegate?
    weak var delegate: VideoDelegate?
    
    var isRecording: Bool = false
    
    func startMediaBrowser2() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera)
        else { return }
        
        DispatchQueue.main.async {
            let mediaUI = UIImagePickerController()
            mediaUI.sourceType = .camera
            mediaUI.mediaTypes = [kUTTypeMovie as String]
            mediaUI.allowsEditing = true
            mediaUI.delegate = self.delegate as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
//            print(mediaUI.)
            self.delegate!.present(mediaUI, animated: true, completion: nil)
            
            //            mediaUI.perform(#selector(UIImagePickerController.startVideoCapture), with: nil, afterDelay: 3)
            
            //            mediaUI.perform(#selector(UIImagePickerController.stopVideoCapture), with: nil, afterDelay: 10)
            
                        mediaUI.showsCameraControls = false
            
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
            mediaUI.preferredContentSize = CGSize(width: 100, height: 100)
            mediaUI.delegate = delegate
            delegate.present(mediaUI, animated: true, completion: nil)
            
//            mediaUI.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
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
                let btn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 100, y: 0, width: 50, height: 30))
                btn.layer.borderColor = UIColor.blue.cgColor
                btn.layer.borderWidth = 2
                btn.setTitle("end", for: .normal)
                btn.setTitleColor(.blue, for: .normal)
                return btn
            }()
            
            
            let view = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height, width: 400, height: 100))
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
        print(#file, #function, "start tapped!")
        

print("flag1")
        // 여기가 문제?
        NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.startRecordingFromIPC), object: nil)
        print("flag2")
        self.startVideoCapture()
print("flag3")
        
    }
    
    @objc func didEndTapped(_ sender: UIButton) {
        print(#file, #function, "end tapped")
        self.stopVideoCapture()
        

        NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.stopRecordingFromIPC), object: nil)
    }
}


extension UIImagePickerController {
    override open func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(startedRecording(_:)), name: NSNotification.Name(NotificationKeys.startRecordingFromVC), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopRecording(_:)), name: NSNotification.Name(NotificationKeys.stopRecordingFromVC), object: nil)
        
    }
    
    @objc func startedRecording(_ notification: Notification) {
        DispatchQueue.main.async {
            self.startVideoCapture()
            
        }
        
        print(#file, #function, "notification from VC, start recording")
    }
    
    @objc func stopRecording(_ notification: Notification) {
        DispatchQueue.main.async {
            self.stopVideoCapture()
            
        }
        print(#file, #function, "notification From VC, stop recording")
    }
}
//extension UIImagePickerControllerDelegate {
//    func orderVideoCapture() {
//
//    }
//}
