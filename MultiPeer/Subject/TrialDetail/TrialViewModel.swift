//
//  TrialViewModel.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/16.
//

import Foundation



struct TrialViewModel {
    
    let trialCore: TrialCore
    
//    var imageName: String { return correspondingImageString(from: trialCore.title) }

    var titleName: String { return trialCore.title }

    var direction: String { return trialCore.direction }

    var titleWithDirection: String { return trialCore.title + "\n" + trialCore.direction}

    var painScore: String { return convertPain(trialCore.latestWasPainful) }

    var realScore: String { return convertScore(trialCore.latestScore) }
    
    
    private func convertPain(_ score: Int64) -> String {
        switch score {
        case -1: return "-"
        case 0: return " "
        case 1: return "+"
        default: return " "
        }
    }
    
    private func convertScore(_ score: Int64) -> String {
        switch score {
        case -1: return "-"
        case 0: return " "
        case 1: return "+"
        default: return " "
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
