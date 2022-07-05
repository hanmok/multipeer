//
//  CMTimeExt+.swift
//  MultiPeer
//
//  Created by 핏투비 on 2022/07/04.
//

import Foundation
import CoreMedia

extension CMTime {
    static func makeCMTime(from int64: Int64) -> CMTime {
        return CMTimeMakeWithSeconds(Float64(int64), preferredTimescale: 1000)
    }
}

extension Int64 {
    func convertIntoCMTime() -> CMTime {
        return CMTimeMakeWithSeconds(Float64(self), preferredTimescale: 1000)
    }
}
