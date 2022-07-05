//
//  IncrementingIndex+Helper.swift
//  MultiPeer
//
//  Created by 핏투비 on 2022/07/05.
//

import Foundation

extension IncrementingIndex {
    public var index: Int64 {
        get {
            return self.index_
        }
        set {
            self.index_ = newValue
        }
    }
}

// UserDefault 로 하는게 맞을 것 같은데 ????


// 일단.. subject Info 부터 보내자.
