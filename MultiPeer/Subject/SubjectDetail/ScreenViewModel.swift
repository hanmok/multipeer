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

    var date: String { return screen.date.toStringUsingStyle(.full)}
    
//    var score: String { return screen.isFinished ? String(screen.totalScore) : "incomplete"
//    }
    
//    var score: String { return screen.isFinished ? getFinalScore(screen: screen) : "incomplete"
//    }
    
    //    var score: String { return getFinalScore(screen: screen) }
    
    var score: String { return screen.isFinished ? getFinalScore(screen: screen) : "incomplete" }
    
//    var score: String { return getFinalScore(screen: screen) }
    
    func getFinalScore(screen: Screen) -> String {
        //        let some = screen
        // TODO: FinalScore 구하기.
        // How? Variation 우선 고려하지 않고 만들어보기.
        var totalScore = 0
        var scoreDic: [String: Int64] = [:]
        screen.trialCores.forEach {
            
            // TODO: filter out Variations
            if $0.title.lowercased().contains("var") == false {
                // TODO: Compare Date between original and variation
                // if has Variation
                if let variationName = movementWithVariation[$0.title] {
                    let variationCore = screen.trialCores.filter { $0.title == variationName}.first!
                    
                    let latestScore = $0.updatedDate < variationCore.updatedDate ? variationCore.latestScore : $0.latestScore
                    let selectedCoreName = $0.updatedDate < variationCore.updatedDate ? variationName : $0.title
                    
                    if latestScore > 0 {
                        totalScore += Int(latestScore)
                        print("fflag selectedCoreName: \(selectedCoreName), score: \(latestScore)")
                    }
                    // has no variation. (all variations has no direction)
                } else {
                    // compare two trialCores if has direction.
                    // then, add to totalScore with the lower one.
                    // ?? latestScore is always greater than or equal to 0 (maybe)
                    if $0.latestScore >= 0 {
                        // second core
                        if let prevScore = scoreDic[$0.title] {
                            if $0.latestScore < prevScore {
                                scoreDic[$0.title] = $0.latestScore
                            }
                            // first core
                        } else {
                            scoreDic[$0.title] = $0.latestScore
                        }
                    }
                }
            }
        }
        
        for (movement, finalScore) in scoreDic {
            print("fflag movement: \(movement), finalScore: \(finalScore)")
            totalScore += Int(finalScore)
        }
        
        print("totalScore: \(totalScore)")
        
        return "\(totalScore)"
    }
    // Score 여기서 처리할 수 있나.. ?? 그리 바람직하진 않은데... ??
}
