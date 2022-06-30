//
//  MovementViewModel.swift
//  MultiPeer
//
//  Created by 핏투비 on 2022/05/30.
//

import Foundation

// Variation 의 경우, 나머지는 다 기본 동작과 같게 하고, 점수만 Variation 의 것을 사용할 것.

struct MovementViewModel {
    
    public init(trialCores: [TrialCore]) {
        self.trialCores = trialCores
        print(trialCores.count)
//        self.title = trialCores.first!.title
    }
    
    var title: String { return filteredTrialCores.first!.title }

    var trialCores: [TrialCore]
    
    var filteredTrialCores: [TrialCore] {
        let result = trialCores.filter { !$0.title.lowercased().contains("var") }

        print("----------------- filteredTrialCoresToShow: -----------------")

        for eachCore in result {
            print("title: \(eachCore.title), direction: \(eachCore.direction)")
        }
        return result
    }
    // indicator whether it has one or two directions. 이건 또 뭐야 ... ??
    
//    var imageName: [String] { return MovementImgsDictionary[trialCores.first!.title]! }
//    var imageName: [String] { return MovementImgsDictionaryWithVars[trialCores.first!.title]! }
    var imageName: [String] { return MovementImgsDictionaryWithVars[filteredTrialCores.first!.title]! }
    
    var shortTitleLabel: String { return Dummy.shortName[title]! + addClearingSuffix(to : title) }
    
    // 여기서는 제대로 나옴..
    /// [score] or [score, score]
    var scoreLabel: [String] { return convertScoreToString() }
    
    // TODO: convert score var into scoreLabel, Not Complete yet
    func convertScoreToString() -> [String] {
        // 여기서 출력했던 것 같은데 ??
        var temp: [String] = []
        
        // Neutral
        if trialCores.count == 1 {
            if trialCores.first!.latestScore < 0 {
                temp.append("N")
            } else {
                temp.append(String(trialCores.first!.latestScore))
            }
            // Has Left & Right
        } else if trialCores.count == 2 && !(trialCores.first?.direction.lowercased().contains("neutral"))!{

            if -52 ... -50 ~= trialCores.first!.latestScore {
                temp.append(convertScoreToColor(score: trialCores.first!.latestScore))
            }
            
            else if trialCores.first!.latestScore < 0 {
                temp.append("L")
            } else {
                temp.append(String(trialCores.first!.latestScore))
            }
            
            if -52 ... -50 ~= trialCores.last!.latestScore {
                temp.append(convertScoreToColor(score: trialCores.last!.latestScore))
            }
            
            else if trialCores.last!.latestScore < 0 {
                temp.append("R")
            } else {
                temp.append(String(trialCores.last!.latestScore))
            }
            
            print("viewmodel title: \(title)")
            print("viewmodel temp: \(temp)")
            
            return temp
        } else if trialCores.count == 2 {
            if trialCores.first!.date >= trialCores.last!.date {
                if trialCores.first!.latestScore < 0 {
                    temp.append("N")
                } else {
                    temp.append(String(trialCores.first!.latestScore))
                }
            } else {
                if trialCores.last!.latestScore < 0 {
                    temp.append("N")
                } else {
                    temp.append(String(trialCores.last!.latestScore))
                }
            }
        }
        else {
            fatalError("numOfTrialCore: \(trialCores.count)")
        }
        
        print("temp Score: \(temp)")
        return temp
    }
    
    func addClearingSuffix(to title: String) -> String {
        if MovementsHasPain[title] != nil {
            print("title that has clearing: \(title)")
            if title != MovementList.ankleClearing.rawValue {
                return " + Clearing "
            }
        }
        return ""
    }
    /// convert Score To Red, Yellow, Green for ankle Clearing
    private func convertScoreToColor(score: Int64) -> String {
        print("convertScoreToColor triggered!!")
        switch score {
        case .Value.red: return .ScoreStr.red
        case .Value.yellow: return .ScoreStr.yellow
        case .Value.green: return .ScoreStr.green
        default: return String(score)
        }
    }
}


