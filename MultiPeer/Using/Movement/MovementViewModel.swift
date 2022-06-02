//
//  MovementViewModel.swift
//  MultiPeer
//
//  Created by 핏투비 on 2022/05/30.
//

import Foundation


struct MovementViewModel {
    
    public init(trialCores: [TrialCore]) {
        self.trialCore = trialCores
        print(trialCores.count)
        self.title = trialCores.first!.title
    }
    
    var title: String

    var trialCore: [TrialCore]
    
    // indicator whether it has one or two directions. 이건 또 뭐야 ... ??
    
    var imageName: [String] { return MovementImgsDictionary[trialCore.first!.title]! }
    
    var shortTitleLabel: String { return Dummy.shortName[title]! + addSuffix(title: title) }
    // 여기서는 제대로 나옴..
    var scoreLabel: [String] { return convertScoreToString() }
    
    // TODO: convert score var into scoreLabel, Not Complete yet
    func convertScoreToString() -> [String] {
        
        var temp: [String] = []
        
        // Neutral
        if trialCore.count == 1 {
//            if trialCore.first!.latestScore == .DefaultValue.trialScore || trialCore.first!.latestScore < 0 {
            if trialCore.first!.latestScore < 0 {
                temp.append("N")
            } else {

                temp.append(String(trialCore.first!.latestScore))
            }
            // Has Left & Right
        } else if trialCore.count == 2 {

            if trialCore.first!.latestScore < 0 {
                temp.append("L")
            } else {
                temp.append( String(trialCore.first!.latestScore))
            }
            
            // second element
//            if trialCore.last!.latestScore == .DefaultValue.trialScore {
            if trialCore.last!.latestScore < 0 {
                temp.append("R")
            } else {
                temp.append(String(trialCore.last!.latestScore))
            }
            print("my test title: \(title)")
            print("temp: \(temp)")
            return temp
        }
        
        else {
            fatalError("numOfTrialCore: \(trialCore.count)")
        }
        
        return temp
    }
    
    func addSuffix(title: String) -> String {
        if MovementsHasPain[title] != nil {
            print("title that has clearing: \(title)")
            if title != MovementList.ankleClearing.rawValue {
                return " + Clearing "
            }
        }
        return ""
    }
}
