//
//  PositionDirection.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/04/27.
//

import Foundation

enum PositionDirection {
    case left
    case right
    case neutral // represent 'Center' or 'Neutral'
//    case not
}

struct Position {
    var title: String
    
    var imageName: [String]
    var score: [Int?] = [nil, nil]
    
    var leftRight: Bool {
        return imageName.count == 2 ? true : false
    }
}
