
import MobileCoreServices
import UIKit

enum VideoHelper {
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
            mediaUI.perform(#selector(UIImagePickerController.startVideoCapture), with: nil, afterDelay: 3)
            // Unstable. 잘 되는건가 ?? 지금은 괜찮은ㄷ ㅔ?? 시간을 .. 흐음..
            
            mediaUI.perform(#selector(UIImagePickerController.stopVideoCapture), with: nil, afterDelay: 20)
        }
    }
}

// UIImagePickerController 를 보자.
/*
 find a func triggered after stop video capture.
 
 startVideoCapture() -> Bool
 stopVideoCapture()
 */
