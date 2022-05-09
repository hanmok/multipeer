//
//  APIManager.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/09.
//

import Foundation


class APIManager {
    
    static let shared = APIManager()
    
    func postRequest(positionDirectionScoreInfo: PositionDirectionScoreInfo, videoUrl: URL) {
        let detailInfo = positionDirectionScoreInfo
        print("post request!! ")
        print("title : \(detailInfo.title)")
        print("direction: \(detailInfo.direction)")
        print("score: \(String(describing: detailInfo.score))")
        print("pain: \(String(describing: detailInfo.pain))")
        print("video: \(videoUrl)")
    }
}
