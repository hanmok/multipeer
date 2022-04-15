//
//  ViewController.swift
//  TakingCamera
//
//  Created by 이한목 on 2022/04/13.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.backgroundColor = .secondarySystemBackground
        button.backgroundColor = .systemBlue
        button.setTitle("Take Picture", for: .normal)
        button.setTitleColor(.white, for: .normal)
        
    }

    @IBAction func didTapButton() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

}

extension SecondViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        imageView.image = image
    }
}
