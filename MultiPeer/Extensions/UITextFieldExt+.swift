//
//  UITextFieldExt+.swift
//  MultiPeer
//
//  Created by 핏투비 on 2022/07/01.
//

import UIKit

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    convenience init(leftPadding: CGFloat = 5, rightPadding: CGFloat = 5, withPadding: Bool) {
        self.init(frame: .zero)

        if withPadding {
        setLeftPaddingPoints(leftPadding)
        setRightPaddingPoints(rightPadding)
        }
    }
}
