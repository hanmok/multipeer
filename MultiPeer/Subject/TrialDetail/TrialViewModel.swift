//
//  TrialViewModel.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/16.
//

import Foundation



struct TrialViewModel {
    
    let trialCoresToShow: ([TrialCore], [TrialCore]) // Clearing Test 포함되어있음.
    
//    var titleName: String { return filteredTrialCores.first!.title }
    
    var titleName: String { return returnShortTitleName(filteredTrialCores.first!.title)}

    private func returnShortTitleName(_ titleName: String) -> String {
//        if let shortName = shortmovement
        if let shortName = Dummy.shortName[titleName] {
            return shortName
        } else {
            return titleName
        }
//        return ""
    }
    
    var filteredTrialCores: [TrialCore] {
        let result = trialCoresToShow.0.filter { !$0.title.lowercased().contains("var") }
// deepSquat 이 왜 두번들어가지 ?
        print("----------------- filteredTrialCoresToShow: -----------------")

        for eachCore in result {
            print("title: \(eachCore.title), direction: \(eachCore.direction)")
        }
        return result
    }
    
    var imageName: String { return MovementImgsDictionaryWithVars[filteredTrialCores.first!.title]!.first!}
    
    var realScore: [String] { return returnLatestScores()}
    var finalScore: String { return getFinalScore(from: realScore) }
    
    var scoreTobePrinted: String {
        if realScore.count == 2 {
            let leftScore = realScore.first!
            let rightScore = realScore.last!
            if leftScore == "" && rightScore == "" {
                return ""
            }
            return "(\(leftScore)/\(rightScore))"
            
        } else {
            return realScore.first!
        }
    }
    
    
    private func getFinalScore(from latestScore: [String]) -> String {
        print("latestScore: \(latestScore)")
        
        if (latestScore.first! == "R" || latestScore.first! == "Y" || latestScore.first! == "G") {
            return ""
        }
        
        if latestScore.count != 2 {
            return latestScore.first!
        } else {
            var scores: (leftScore: Int?, rightScore: Int?) = (nil, nil)
            
            if let firstScoreStr = latestScore.first,
               let firstScore = Int(firstScoreStr) {
                scores.leftScore = firstScore
            }
            
            if let secondScoreStr = latestScore.last,
               let secondScore = Int(secondScoreStr) {
                scores.rightScore = secondScore
            }

            if scores.leftScore != nil && scores.rightScore != nil {
                let result = min(scores.leftScore!, scores.rightScore!)
                return String(result)
                
            } else {
                return ""
            }
        }
    }
    
    
    var painText: String {
        
        if trialCoresToShow.1.isEmpty == false {
            let painCores = trialCoresToShow.1
            
            if painCores.count == 2 {
                let leftPain = convertPain(painCores.first!.latestWasPainful)
                let rightPain = convertPain(painCores.last!.latestWasPainful)
                if leftPain == "" && rightPain == "" { return "" }
                
                return "(\(leftPain)/\(rightPain))"
                
            } else {
                let pain = convertPain(painCores.first!.latestWasPainful)
                return pain
            }
            
            // ankleClearing -> ankleClearing (LR)
            // shoulderMobility -> shoulderClearing (LR)
            // trunkStabilityPushUp -> extensionClearing
            // rotaryStability -> flexionClearing
            
        } else {
            return ""
        }
    }
    
    func returnLatestScores() -> [String] {
        // 여기서 출력했던 것 같은데 ??
        var temp: [String] = []
        
        // Neutral
        if trialCoresToShow.0.count == 1 {
            if trialCoresToShow.0.first!.latestScore < 0 {
                temp.append("")
            } else {
                temp.append(String(trialCoresToShow.0.first!.latestScore))
            }
            // Has Left & Right
        } else if trialCoresToShow.0.count == 2 && !(trialCoresToShow.0.first?.direction.lowercased().contains("neutral"))!{

            if -52 ... -50 ~= trialCoresToShow.0.first!.latestScore {
                temp.append(convertScoreToColor(score: trialCoresToShow.0.first!.latestScore))
            }
            
            else if trialCoresToShow.0.first!.latestScore < 0 {
                temp.append("")
            } else {
                temp.append(String(trialCoresToShow.0.first!.latestScore))
            }
            
            
            
            
            if -52 ... -50 ~= trialCoresToShow.0.last!.latestScore {
                temp.append(convertScoreToColor(score: trialCoresToShow.0.last!.latestScore))
            }
            
            else if trialCoresToShow.0.last!.latestScore < 0 {
                temp.append("")
            } else {
                temp.append(String(trialCoresToShow.0.last!.latestScore))
            }
            
            return temp
            
        } else if trialCoresToShow.0.count == 2 {
            if trialCoresToShow.0.first!.updatedDate >= trialCoresToShow.0.last!.updatedDate {
                if trialCoresToShow.0.first!.latestScore < 0 {
                    temp.append("")
                } else {
                    temp.append(String(trialCoresToShow.0.first!.latestScore))
                }
            } else {
                if trialCoresToShow.0.last!.latestScore < 0 {
                    temp.append("")
                } else {
                    temp.append(String(trialCoresToShow.0.last!.latestScore))
                }
            }
        }
        else {
            fatalError("numOfTrialCore: \(trialCoresToShow.0.count)")
        }
        
        print("temp Score: \(temp)")
        return temp
    }
    
    private func returnFinalScore() -> String {
        return ""
    }
    
    private func convertScoreToColor(score: Int64) -> String {
        print("convertScoreToColor triggered!!")
        switch score {
        case .Value.red: return .ScoreStr.shortRed
        case .Value.yellow: return .ScoreStr.shortYellow
        case .Value.green: return .ScoreStr.shortGreen
        default: return String(score)
        }
    }
    
    private func convertPain(_ score: Int64) -> String {
        switch score {
        case -1: return "-"
        case 0: return ""
        case 1: return "+"
        default: return ""
        }
    }
    
    private func convertScore(_ score: Int64) -> String {
        switch score {
        case -1: return "-"
        case 0: return ""
        case 1: return "+"
        default: return ""
        }
    }
    
    public func correspondingImageString(from str: String) -> String {
        // use enum
        if str == "" {
            return String("folder")
        } else {
            return String("circle")
        }
    }
}
