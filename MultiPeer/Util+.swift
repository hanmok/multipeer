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


//extension UIScreen {
//    static var screenHeight: CGFloat {
//        return self.main.bounds.height
//    }
//
//    static var screenWidth: CGFloat {
//        return self.main.bounds.width
//    }
//}

public func convertIntoRecordingTimeFormat(_ seconds: Int) -> String {
    
    let minutes = Int(seconds) / 60 % 60
    let seconds = Int(seconds) % 60
    return String(format:"%02i:%02i", minutes, seconds)
    
}


extension Date {
 var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
        //RESOLVED CRASH HERE
    }

    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}
