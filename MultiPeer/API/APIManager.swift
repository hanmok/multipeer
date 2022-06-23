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
        subjectName: String,
        screenId: UUID,
        title: String,
        direction: String,
        score: Int,
        pain: Int,
        
        trialNo: Int,
        currentDate: Date,
        
        videoURL: URL,
        cameraDirection: String,
        closure: @escaping () -> Void ) {
        
        print("---------------- post request!! ----------------")
        
        print("title: \(title), direction: \(direction), scroe: \(score), pain: \(pain), trialCount: \(trialNo), cameraDirection: \(cameraDirection), screenKey: \(screenId) ")
        print("videoURL: \(videoURL)")
        print("---------------- post request ended!! ----------------\n\n\n")
    }
}

class FTPManager {
    
    static let shared = FTPManager()
    
    func postRequest(
        videoURL: URL,
        closure: @escaping () -> Void ) {
        closure()
    }
}
