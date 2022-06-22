//
//  APIManager.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/09.
//

import Foundation


class APIManager {
    
    static let shared = APIManager()
    
//    func postRequest(movementDirectionScoreInfo: MovementDirectionScoreInfo,  trialCount: Int, trialId: UUID, videoUrl: URL, angle: CameraDirection, closure: @escaping () -> Void ) {
//        let detailInfo = movementDirectionScoreInfo
//        print("---------------- post request!! ----------------")
//        print("title : \(detailInfo.title)")
//        print("direction: \(detailInfo.direction)")
//        print("score: \(String(describing: detailInfo.score))")
//        print("pain: \(String(describing: detailInfo.pain))")
//        print("video: \(videoUrl)")
//        print("---------------- post request ended!! ----------------\n\n\n")
//    }
    
    func postRequest(
        movementTitle: String,
        direction: String,
        score: Int,
        pain: Int, trialCount: Int,
        videoURL: URL,
        cameraDirection: String,
        screenKey: UUID,
        closure: @escaping () -> Void ) {
        
        print("---------------- post request!! ----------------")
        
        print("title: \(movementTitle), direction: \(direction), scroe: \(score), pain: \(pain), trialCount: \(trialCount), cameraDirection: \(cameraDirection), screenKey: \(screenKey) ")
        print("videoURL: \(videoURL)")
        print("---------------- post request ended!! ----------------\n\n\n")
    }
}

