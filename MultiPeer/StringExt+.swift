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
        static let subject = "Subject"
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
        static let direction = "direction"
        static let latestWasPainful = "latestWasPainful"
        static let latestScore = "latestScore"
        
        static let parentPositionTitle = "parentPositionTitle"
        static let trials = "trials"
    }
    
    struct PositionTitleCoreStr {
        static let title = "title"
        static let directions = "directions"
        
        static let parentScreen = "parentScreen_" //
    }
    
    struct TrialDetailStr {
        static let isPainful = "isPainful_"
        
        static let score = "score_"
        static let trialNo = "trialNo"
    }
}
