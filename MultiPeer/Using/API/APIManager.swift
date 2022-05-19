//
//  APIManager.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/09.
//

import Foundation


class APIManager {
    
    static let shared = APIManager()
    
    func postRequest(positionDirectionScoreInfo: PositionDirectionScoreInfo,  trialCount: Int, trialId: UUID, videoUrl: URL, angle: CapturingAngle) {
        let detailInfo = positionDirectionScoreInfo
//        print("post request!! ")
//        print("title : \(detailInfo.title)")
//        print("direction: \(detailInfo.direction)")
//        print("score: \(String(describing: detailInfo.score))")
//        print("pain: \(String(describing: detailInfo.pain))")
//        print("video: \(videoUrl)")
    }
}

// 이거.. 지금은 딱히 손 안봐도 되나..? 봐야할걸 ?? 글쎄..
//public var trialDictionary: [String: Int] = [:]


/*
struct PositionDirectionScoreInfo: Codable {
    var title: String
    
    var direction: PositionDirection
    var score: Int?
    var pain: Bool?
}
*/
