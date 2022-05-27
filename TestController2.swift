//
//  TestController2.swift
//  trim-crop-video
//
//  Created by 핏투비 on 2022/05/26.
//

import UIKit
import AVKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class TestController2 {
    
    var player: AVPlayer? {
        didSet {
            guard let duration = player?.currentItem?.duration else { return }
//            let asset = AVURLAsset(url: <#T##NSURL#>)
            endTime = duration
        }
    }
    
    var testDuration: Double = 0.0 // millisec 까지 표현
    var cropScaleComposition: AVVideoComposition?
    
    var startTime: CMTime = .zero
    var endTime: CMTime = .zero
    var parentVC: UIViewController?
    
    init(url: URL, vc: UIViewController) {
        self.player = AVPlayer(url: url)
        self.parentVC = vc
//        testDuration
        let asset = AVURLAsset(url: url)
        testDuration = asset.duration.seconds
        
    }
    
    func exportVideo() {
        print("export Video Triggered!")
        // MARK: - Asset To Export
        guard let assetToExport = self.player?.currentItem?.asset else { fatalError() }
        
        // MARK: - Composition
        guard let playerItem = self.player?.currentItem else { fatalError() }
        let cropRect = setupCropRect(item: playerItem)
        self.setupCropScaleComposition(item: playerItem, cropRect: cropRect)
        guard let composition = self.cropScaleComposition else { fatalError() }
        
        // MARK: - Output Movie URL
        // 음....
        let fileUUID = UUID()
        //        guard let outputMovieURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("exported.mov") else { fatalError() }
        
        guard let outputMovieURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(fileUUID).mov") else { fatalError() }
        
        export(assetToExport, to: outputMovieURL, startTime: self.startTime, endTime: self.endTime, composition: composition)
    }
    
    func setupCropRect(item: AVPlayerItem) -> CGRect {
        
        let renderingSize = item.presentationSize
        
        //        let xFactor = renderingSize.width / playerView.bounds.size.width
        //        let yFactor = renderingSize.height / playerView.bounds.size.height
        
        //        let newX = croppingView.frame.origin.x * xFactor
        //        let newW = croppingView.frame.width * xFactor
        //        let newY = croppingView.frame.origin.y * yFactor
        //        let newH = croppingView.frame.height * yFactor
        
        //        let size: CGFloat = 500
        let size: CGFloat = screenWidth
        
        print("screenWidth: \(screenWidth), screenHeight: \(screenHeight)")
        
        //        let yCoordinate: CGFloat = (screenHeight - screenWidth) / 2
        //        let yCoordinate: CGFloat = 57
        
        // 이게.. 센터냐 ?
        //        아니,
        
        var cropRect = CGRect(x: 0, y: 0, width: size, height: size)
        
        //        let originFlipTransform = CGAffineTransform(scaleX: 1, y: -1)
        //        let frameTranslateTransform = CGAffineTransform(translationX: 0, y: renderingSize.height)
        
        //        cropRect = cropRect.applying(originFlipTransform)
        //        cropRect = cropRect.applying(frameTranslateTransform)
        
        return cropRect
    }
    
    func setupCropScaleComposition(item: AVPlayerItem, cropRect: CGRect) {
        
        let cropScaleComposition = AVMutableVideoComposition(asset: item.asset, applyingCIFiltersWithHandler: { [weak self] request in
            
            //        guard let self = self else { return }
            
            //        let sepiaToneFilter = CIFilter.sepiaTone()
            
            //        let currentTime = request.compositionTime
            //        sepiaToneFilter.intensity = self.calculateFilterIntensity(self.endTime, currentTime)
            
            //          sepiaToneFilter.intensity = 0.5
            //        sepiaToneFilter.inputImage = request.sourceImage
            
            let cropFilter = CIFilter(name: "CICrop")!
            //        cropFilter.setValue(sepiaToneFilter.outputImage!, forKey: kCIInputImageKey)
            cropFilter.setValue(request.sourceImage, forKey: kCIInputImageKey)
            cropFilter.setValue(CIVector(cgRect: cropRect), forKey: "inputRectangle")
            
            
            //        let imageAtOrigin = cropFilter.outputImage!.transformed(by: CGAffineTransform(translationX: -cropRect.origin.x, y: -cropRect.origin.y))
            
            let imageAtOrigin = cropFilter.outputImage!.transformed(by: CGAffineTransform(translationX: 0, y: 0 ))
            
            request.finish(with: imageAtOrigin, context: nil)
        })
        
        //        cropScaleComposition.renderSize = cropRect.size
        //        cropScaleComposition.renderScale = 1.5
        // modified
        
        cropScaleComposition.renderSize = CGSize(width: cropRect.width * 0.8, height: cropRect.height * 0.8)
        
        item.videoComposition = cropScaleComposition
        self.cropScaleComposition = cropScaleComposition
    }
    // 이거 호출호출~
    func export(_ asset: AVAsset, to outputMovieURL: URL, startTime: CMTime, endTime: CMTime, composition: AVVideoComposition) {
        
        //Create trim range
        let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
        
        //delete any old file
        do {
            try FileManager.default.removeItem(at: outputMovieURL)
        } catch {
            
            print("Could not remove file \(error.localizedDescription)")
        }
        
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
                    fatalError()
                } else {
                    guard let vc = self.parentVC else {fatalError() }
                    //            self.shareVideoFile(outputMovieURL, presentOn: vc)
                    self.saveVideoToLocal(with: outputMovieURL)
                    //              UISaveVideoAtPathToSavedPhotosAlbum(outputMovieURL.absoluteString, vc, nil, nil)
                    
                    print("outputMovieURL : \(outputMovieURL.absoluteString)")
                }
            }
            
        })
    }
    
    // not used .
    func shareVideoFile(_ file:URL, presentOn vc: UIViewController) {
        
        //      updateControlStatus(enabled: true)
        
        // Create the Array which includes the files you want to share
        var filesToShare = [Any]()
        
        // Add the path of the file to the Array
        filesToShare.append(file)
        
        // Make the activityViewContoller which shows the share-view
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        //        FileManager().
        
        // Show the share-view
        vc.present(activityViewController, animated: true, completion: nil)
    }
    
    func saveVideoToLocal(with url: URL) {
        //        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //        let documentsDirectoryURL = paths[0]
        print("duration: \(self.testDuration)")
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }
    }
}
