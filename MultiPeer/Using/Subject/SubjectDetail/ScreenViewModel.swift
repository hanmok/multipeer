//
//  ScreenViewModel.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/13.
//

import Foundation


struct ScreenViewModel {
    private var screen: Screen
    private var index: Int
    
    init(screen: Screen, index: Int) {
        self.index = index
        self.screen = screen
    }
    
    var sequenceIndex : String { return String(index + 1) }
//    var sequenceIndex: String { return "Hi!!" }
    var date: String { return screen.date.toStringUsingStyle(.full)}
    var score: String { return screen.isFinished ? String(screen.totalScore) : "incomplete"
    }
}

