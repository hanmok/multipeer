//
//  PositionViewModel.swift
//  MultiPeer
//
//  Created by 핏투비 on 2022/05/30.
//

import Foundation


struct PositionViewModel {
    
    public init(trialCores: [TrialCore]) {
        self.trialCore = trialCores
        print("trialCore.first.title: \(trialCore.first?.title)")
        print("trialCore.count: flag")
        print(trialCores.count)
        self.title = trialCores.first!.title
    }
    
    var title: String

    var trialCore: [TrialCore]
    
    // indicator whether it has one or two directions. 이건 또 뭐야 ... ??
    
    var imageName: [String] { return PositionImgsDictionary[trialCore.first!.title]! }
    
    var shortTitleLabel: String { return Dummy.shortName[title]! + addSuffix(title: title) }
    
    var scoreLabel: [String] { return convertScoreToString() }
    
    // TODO: convert score var into scoreLabel
    func convertScoreToString() -> [String] {
        var temp: [String] = []
        if trialCore.count == 1 {
            if trialCore.first!.latestScore == .DefaultValue.trialScore {
                return ["N"]
            } else {
                return [String(trialCore.first!.latestScore)]
            }
        } else if trialCore.count == 2 {
            // first element
            
            if trialCore.first!.latestScore == .DefaultValue.trialScore {
                temp.append("L")
            } else {
                temp.append( String(trialCore.first!.latestScore))
            }
            
            // second element
            if trialCore.last!.latestScore == .DefaultValue.trialScore {
                temp.append("R")
            } else {
                temp.append(String(trialCore.first!.latestScore))
            }
            
            return temp
        } else {
            fatalError("numOfTrialCore: \(trialCore.count)")
        }
    }
    
    func addSuffix(title: String) -> String {
        if PositionsHasPain[title] != nil {
            print("title that has clearing: \(title)")
            if title != PositionList.ankleClearing.rawValue {
                return " + Clearing "
            }
        }
        return ""
    }
}
