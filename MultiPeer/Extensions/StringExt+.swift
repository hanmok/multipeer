//
//  StringExt+.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/13.
//

import Foundation


extension String {
    
    struct CoreEntitiesStr {
        static let positionTitleCore = "PositionTitleCore"
        static let trialCore = "TrialCore"
        static let screen = "Screen"
        static let Subject = "Subject"
        static let trialDetail = "TrialDetail"
    }

    struct ScreenStr {
        static let id = "id_"
        static let date = "date_"
        static let isFinished = "isFinished"

        static let totalScore = "totalScore"
    }

    struct SubjectStr {
        static let birthday = "birthday_"
        static let lastUpdateDate = "lastUpdateDate"
        static let isMale = "isMale"
        static let id = "id_"
        static let imageUrl = "imageUrl"
        static let name = "name_"
        static let phoneNumber = "phoneNumber_"
        static let numOfTestConducted = "numOfTestConducted"
        
        static let screens = "screens"
    }
    
    struct TrialCoreStr {
        
        static let title = "title_"
        static let direction = "direction_"
        static let latestWasPainful = "latestWasPainful"
        static let latestScore = "latestScore"
        
        static let trials = "trialD" // what the hell is this ? master 에 있는 것을 공유.
    
        static let tag = "tag"
        static let parentScreen = "parentScreen"
        static let trialDetails = "trialDetails_"
    }
    
    struct TrialDetailStr {
        static let isPainful = "isPainful_"
        
        static let score = "score_"
        static let trialNo = "trialNo"
        
        static let parentTrialCore = "parentTrialCore_"
    }
    
    struct ScoreStr {
        static let hold = "Hold"
        static let red = "Red"
        static let yellow = "Yellow"
        static let green = "Green"
    }
}
