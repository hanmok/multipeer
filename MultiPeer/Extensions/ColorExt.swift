//
//  ColorExt.swift
//  MultiPeer
//
//  Created by 핏투비 on 2022/05/31.
//

import Foundation
import UIKit


extension UIColor {
    
    convenience init(redInt: CGFloat, greenInt: CGFloat, blueInt: CGFloat) {
//        init(
        self.init(red: redInt / 255.0, green: (greenInt) / 255.0, blue: blueInt / 255.0, alpha: 1)
    }
    convenience init(rgba: (CGFloat, CGFloat, CGFloat, CGFloat)) {
        self.init(red: rgba.0 / 255.0, green: rgba.1 / 255.0, blue: rgba.2 / 255, alpha: rgba.3 / 255.0)
    }
    
    
    static let purple500 = UIColor(redInt: 120, greenInt: 106, blueInt: 189)
    
    static let purple300 = UIColor(redInt: 201, greenInt: 196, blueInt: 229)
    
    static let lavenderGray900 = UIColor(redInt: 61, greenInt: 69, blueInt: 78)
    
    static let lavenderGray300 = UIColor(redInt: 203, greenInt: 202, blueInt: 211)
    
    static let gray900 = UIColor(redInt: 21, greenInt: 21, blueInt: 21)

    static let red500 = UIColor(redInt: 227, greenInt: 42, blueInt: 47)
    static let lavenderGray700 = UIColor(redInt: 109, greenInt: 107, blueInt: 115)
    

}
