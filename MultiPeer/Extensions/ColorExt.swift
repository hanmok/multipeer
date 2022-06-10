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
        
        self.init(red: redInt / 255.0, green: (greenInt) / 255.0, blue: blueInt / 255.0, alpha: 1)
    }
    
    convenience init(rgba: (CGFloat, CGFloat, CGFloat, CGFloat)) {
        self.init(red: rgba.0 / 255.0, green: rgba.1 / 255.0, blue: rgba.2 / 255, alpha: rgba.3 / 255.0)
    }
    
    
    
    /// background Color, 248 247 249
    static let lavenderGray50 = UIColor(redInt: 248, greenInt: 247, blueInt: 249)
    /// 237, 236, 239
    static let lavenderGray100 = UIColor(redInt: 237, greenInt: 236, blueInt: 239)
    /// 203, 202, 211
    static let lavenderGray300 = UIColor(redInt: 203, greenInt: 202, blueInt: 211)
    /// 181, 179, 192
    static let lavenderGray400 = UIColor(redInt: 181, greenInt: 179, blueInt: 192)
    /// 109, 107, 115
    static let lavenderGray700 = UIColor(redInt: 109, greenInt: 107, blueInt: 115)
    /// 61, 69, 78
    static let lavenderGray900 = UIColor(redInt: 61, greenInt: 69, blueInt: 78)
    
    /// 201, 196, 229
    static let purple300 = UIColor(redInt: 201, greenInt: 196, blueInt: 229)
    /// 120, 106, 189
    static let purple500 = UIColor(redInt: 120, greenInt: 106, blueInt: 189)
    
    /// 227, 42, 47
    static let red500 = UIColor(redInt: 227, greenInt: 42, blueInt: 47)
    /// 187, 187, 187
    static let gray400 = UIColor(redInt: 187, greenInt: 187, blueInt: 187)
    /// 117, 117, 117
    static let gray600 = UIColor(redInt: 117, greenInt: 117, blueInt: 117)
    /// 21, 21, 21
    static let gray900 = UIColor(redInt: 21, greenInt: 21, blueInt: 21)
    
    static let blueGray200 = UIColor(redInt: 218, greenInt: 225, blueInt: 228)
}
