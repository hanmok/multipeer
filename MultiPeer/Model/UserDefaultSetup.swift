//
//  UserDefaultSetup.swift
//  MultiPeer
//
//  Created by 핏투비 on 2022/07/06.
//

import Foundation


struct UserDefaultSetup {
    
    let defaults = UserDefaults.standard

    enum UserDefaultKey: String {
        case upperIndex
    }
    
    public var upperIndex: Int {
        get {
//            defaults.int(forKey: UserDefaultKey.screenIndex.rawValue)
//            print("currentInteger: \(UserDefaultKey)")
            let value = defaults.integer(forKey: UserDefaultKey.upperIndex.rawValue)
        print("current Value: \(value)")
            return defaults.integer(forKey: UserDefaultKey.upperIndex.rawValue)
        }
        set {
            defaults.set(newValue ,forKey: UserDefaultKey.upperIndex.rawValue)
        }
    }
}
