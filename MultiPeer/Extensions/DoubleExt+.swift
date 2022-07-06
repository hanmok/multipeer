//
//  DoubleExt+.swift
//  MultiPeer
//
//  Created by 핏투비 on 2022/07/05.
//

import Foundation

extension Double {
    func convertTo4DigitString() -> String {
        var strForm = String(self)
        while strForm.count < 4 {
            strForm = "0" + strForm
        }
        while strForm.count > 4 {
            strForm.removeLast()
        }
        return strForm
    }
}
