//  TrimController.swift
//  trim-crop-video
//
//  Created by 핏투비 on 2022/05/27.
//

import Foundation
import UIKit
import AVKit
import CoreImage
import CoreImage.CIFilterBuiltins


// Crop 과 함께 진행 필요. 
class TrimmerController {
    
    var player: AVPlayer? {
      didSet {
        guard let duration = player?.currentItem?.duration else { return }
        endTime = duration
      }
    }
    
    var startTime: CMTime = .zero
    var endTime: CMTime = .zero
    
    private func exportvideo(_ sender: UIButton) {
        let cropScaleComposition: AVVideoComposition? = AVVideoComposition()
        
      guard let assetToExport = self.player?.currentItem?.asset else { return }
      guard let composition = cropScaleComposition else { return }
      guard let outputMovieURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("exported.mov") else { return }

//      updateControlStatus(enabled: false)

      export(assetToExport, to: outputMovieURL, startTime: self.startTime, endTime: self.endTime, composition: composition)
    }
    
    private func updateStartTime(_ sender: UISlider) {
        guard let videoDuration = self.player?.currentItem?.duration else { return }
        self.startTime = CMTimeMakeWithSeconds(Double(sender.value) * videoDuration.seconds, preferredTimescale: 600)
    }
    
    private func updateEndTime(_ sender: UISlider) {
        guard let videoDuration = self.player?.currentItem?.duration else { return }
        self.endTime = CMTimeMakeWithSeconds(Double(sender.value) * videoDuration.seconds, preferredTimescale: 600)
    }
    
    // TIME RANGE
    func export(_ asset: AVAsset, to outputMovieURL: URL, startTime: CMTime, endTime: CMTime, composition: AVVideoComposition) {

      //Create trim range
      let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)

      //delete any old file
      do {
        try FileManager.default.removeItem(at: outputMovieURL)
      } catch {
        print("Could not remove file \(error.localizedDescription)")
      }
  //      CMTimeGetSeconds(<#T##time: CMTime##CMTime#>)
        //
        // 1 / 60 s
  //      CMTime(seconds: 1.3, preferredTimescale: 60)
        
      //create exporter
      let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)

      //configure exporter
      exporter?.videoComposition = composition
      exporter?.outputURL = outputMovieURL
      exporter?.outputFileType = .mov
      exporter?.timeRange = timeRange

      //export!
      exporter?.exportAsynchronously(completionHandler: { [weak exporter] in
        DispatchQueue.main.async {
          if let error = exporter?.error {
            print("failed \(error.localizedDescription)")
          } else {
//            self.shareVideoFile(outputMovieURL)
          }
        }

      })
    }
}
