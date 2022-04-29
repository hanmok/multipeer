//
//  Util+.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/29.
//

import UIKit


public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

// Screen height.
public var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}


public func convertIntoFormat(_ seconds: Int) -> String {
    
    let minutes = Int(seconds) / 60 % 60
    let seconds = Int(seconds) % 60
    return String(format:"%02i:%02i", minutes, seconds)
    
}
