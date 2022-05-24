//
//  SoundService.swift
//  MultiPeer
//
//  Created by Mac mini on 2022/05/23.
//

import Foundation
import AVFoundation

class SoundService {
    static let shard = SoundService()
    
    var decreasingCount = 3
    var decreasingTimer = Timer()
    
    var systemSoundID : SystemSoundID = 1016
    
    func someFunc() {
        
        decreasingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            
            guard let `self` = self else { return }
            
            if self.decreasingCount > 0 {
                self.decreasingCount -= 1
                SoundService.shard.someFunc()
                AudioServicesPlaySystemSound(self.systemSoundID)
                
                
                if self.decreasingCount == 0 { // ????
                    AudioServicesPlaySystemSound(self.systemSoundID)
                } else {
                    
                    // make sound
                    
                    AudioServicesPlaySystemSound(self.systemSoundID)
                }
                //                }
            } else { // self.decreasingCount <= 0
                
                self.decreasingTimer.invalidate()
                self.decreasingCount = 3
            }
        }
    }
}
