//
//  UIViewControllerExt+.swift
//  MultiPeer
//
//  Created by 핏투비 on 2022/06/15.
//

import UIKit


extension UIViewController {
    func showAlert(_ title: String, _ message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
    }
}

