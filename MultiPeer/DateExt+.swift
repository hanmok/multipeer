//
//  DateExt+.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/15.
//


import UIKit
import Foundation

extension Date {
    /// dateFormat = "HH:mm"
    public func toStringUsingFormat(_ dateFormat: String = "HH:mm") -> String {
        let formatter = DateFormatter.current
        formatter.dateStyle = .medium
        formatter.dateFormat = dateFormat
        
        return formatter.string(from: self)
    }
    
    public func toStringUsingStyle(_ dateStyle: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter.current
        formatter.dateStyle = dateStyle
        return formatter.string(from: self)
    }
}




extension String {
    public func toDate(dateFormat: String = "HH:mm") -> Date? {
        let formatter = DateFormatter.current
        formatter.dateFormat = dateFormat
        return formatter.date(from: self)
    }
}

extension Date {
    
}

let date2 = Date()
//let formattedDate = date.toString(dateformat)


//let some = date2.toString(dateFormat: "a HH:mm")


extension DateFormatter {
    public static var current: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.locale = Locale(identifier: "ko-Kore_KR")
        return formatter
    }
}
