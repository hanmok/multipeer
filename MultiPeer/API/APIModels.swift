//
//  APIModels.swift
//  MultiPeer
//
//  Created by 핏투비 iOS on 2022/05/11.
//

import Foundation



struct ScoreModel: Codable {
    let title: String
    let direction: String
    let score: Int
    let pain: Bool?
    let videoURL: URL?
    let angle: String
    let screenNo: Int
    let trialNo: Int

    let trialId: UUID
    let proName: String
}

struct PainModel: Codable {
    let title: String
    let direction: String
    let pain: Bool
    let screenNo: Int
    let trialNo: Int
    let proName: String
}


public enum CapturingAngle: String {
    case front
    case side
}

