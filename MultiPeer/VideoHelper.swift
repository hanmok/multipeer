//
//import MobileCoreServices
//import UIKit
//

//
//
//typealias VideoDelegate =  UIViewController & UINavigationBarDelegate & UIImagePickerControllerDelegate
//
//
//class VideoHelper {
//
//    var count = 0
//
//    static var timer: Timer = Timer()
//
//    static let shared = VideoHelper()
//
//    weak var delegate: VideoDelegate?
//
//    var isRecording: Bool = false
//
//    @objc func timerCount() -> Void {
//        count += 1
//    }
//
//    // 여기서 생김새를 정의한 것 부터 문제 아님 ..??
//    func startMediaBrowser2() {
//        guard UIImagePickerController.isSourceTypeAvailable(.camera)
//        else { return }
//
//        DispatchQueue.main.async {
//            let mediaUI = UIImagePickerController()
//            mediaUI.sourceType = .camera
//            mediaUI.mediaTypes = [kUTTypeMovie as String]
//
//            mediaUI.allowsEditing = true
//            mediaUI.delegate = self.delegate as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
//
////            image
//            // cropRect: The cropping Rectangle that was applied to the original iamge.
//            // AVFoundation 으로 하는게... ??
//            self.delegate!.present(mediaUI, animated: true, completion: nil)
//
//            mediaUI.showsCameraControls = false
//
//            let startBtn: UIButton = {
//                let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
//                btn.layer.borderColor = UIColor.red.cgColor
//                btn.layer.borderWidth = 2
//                btn.setTitle("start", for: .normal)
//                btn.setTitleColor(.magenta, for: .normal)
//                return btn
//            }()
//
//            let endBtn: UIButton = {
//                let btn = UIButton(frame: CGRect(x: 300, y: 0, width: 50, height: 30))
//                btn.layer.borderColor = UIColor.blue.cgColor
//                btn.layer.borderWidth = 2
//                btn.setTitle("end", for: .normal)
//                btn.setTitleColor(.blue, for: .normal)
//                return btn
//            }()
//
//
//            let view = UIView(frame: CGRect(x: 0, y: 600, width: 400, height: 100))
//            view.addSubview(endBtn)
//            view.addSubview(startBtn)
//
//            mediaUI.cameraOverlayView = view
//
//            endBtn.addTarget(nil, action: #selector(UIImagePickerController.didEndTapped(_:)), for: .touchUpInside)
//
//            startBtn.addTarget(nil, action: #selector(UIImagePickerController.didStartTapped(_:)), for: .touchUpInside)
//        }
//    }
//}
//
//extension UIImagePickerController {
//
//    @objc func didStartTapped(_ sender: UIButton) {
//
//        NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.startRecordingFromIPC), object: nil)
//
//        self.startVideoCapture()
//        // initiate Timer!
//
//    }
//
//    @objc func didEndTapped(_ sender: UIButton) {
//        //        print(#file, #function, "end tapped")
//        self.stopVideoCapture()
//
//        NotificationCenter.default.post(name: NSNotification.Name(NotificationKeys.stopRecordingFromIPC), object: nil)
////        DispatchQueue.main.async {
////            self.dismiss(animated: true)
////        }
//
//    }
//}
//
////extension
//
//class TimerTest {
//    static let shared = TimerTest()
//
//    static var count = 0
//    static var timer: Timer = Timer()
//}
//
//
//extension UIImagePickerController {
//    override open func viewDidLoad() {
//        NotificationCenter.default.addObserver(self, selector: #selector(startedRecording(_:)), name: NSNotification.Name(NotificationKeys.startRecordingFromVC), object: nil)
//
////        NotificationCenter.default.addObserver(self, selector: #selector(stopRecording(_:)), name: NSNotification.Name(NotificationKeys.stopRecordingFromVC), object: nil)
//    }
//
//    @objc func startedRecording(_ notification: Notification) {
//        DispatchQueue.main.async {
//            self.startVideoCapture()
//
//        }
//
//        print(#file, #function, "notification from VC, start recording")
//    }
//
//    @objc func stopRecording(_ notification: Notification) {
//        DispatchQueue.main.async {
//            self.stopVideoCapture()
////            self.dismiss(animated: true)
//        }
//        print(#file, #function, "notification From VC, stop recording")
//    }
//}
