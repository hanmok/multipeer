//
//  Int64Ext+.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/19.
//

import Foundation


extension Int64 {
    
    struct DefaultValue {
        static let trialScore = Int64(-100)
        
        static let trialPain = Int64(-200)
    }
    
    
    
    struct Value {
        static let hold = Int64(-1)
        
        static let painFul = Int64(1)
        
        static let notPainful = Int64(-1)
    }
    
    func toInt() -> Int {
        return Int(self)
    }
    
    func painToBool() -> Bool? {
        switch self {
        case .DefaultValue.trialPain: return nil
        case .Value.painFul: return true
        case .Value.notPainful: return false
        default: fatalError("some unknown case !!")
        }
    }
    
    func scoreToInt() -> Int? {
        switch self {
        case .DefaultValue.trialScore: return nil
        default: return self.toInt()
        }
    }
}

class Converter {
//    static func
}
