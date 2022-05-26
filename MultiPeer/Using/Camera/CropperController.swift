//
//  CropperController.swift
//  MultiPeer
//
//  Created by 핏투비 on 2022/05/25.
//

//
//  CropperController.swift
//  trim-crop-video
//
//  Created by 핏투비 on 2022/05/25.
//

import UIKit
import AVKit
import CoreImage
import CoreImage.CIFilterBuiltins

class CropperController: UIViewController {
    
    var videoURL: URL?
    
    init(videoURL: URL) {
        super.init(nibName: nil, bundle: nil)
        self.videoURL = videoURL
    }
    
    private let playerView = UIView()
    
    var cropScaleComposition: AVVideoComposition?
    
    var player: AVPlayer? {
        didSet {
            guard let duration = player?.currentItem?.duration else {return }
            endTime = duration
        }
    }
    
    var startTime: CMTime = .zero
    var endTime: CMTime = .zero
    var endTimeObserver: Any?
    
    func prepareForCropping() {
        guard let playerItem = self.player?.currentItem else { return }
//        let renderingSize = playerItem.presentationSize
//
//        let xFactor = renderingSize.width / playerView.bounds.size.width
//        let yFactor = renderingSize.height / playerView.bounds.size.height

        //      let newX = croppingView.frame.origin.x * xFactor
        //      let newW = croppingView.frame.width * xFactor
        //      let newY = croppingView.frame.origin.y * yFactor
        //      let newH = croppingView.frame.height * yFactor
        //        var cropRect = CGRect(x: newX, y: newY, width: newW, height: UIScreen.height)

        var cropRect = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)

//        let originFlipTransform = CGAffineTransform(scaleX: 1, y: -1)
//        let frameTranslateTransform = CGAffineTransform(translationX: 0, y: renderingSize.height)
//        cropRect = cropRect.applying(originFlipTransform)
//        cropRect = cropRect.applying(frameTranslateTransform)

        self.transformVideo(item: playerItem, cropRect: cropRect)
    }
    
    
    private func playTapped() {
        //        self.croppingView.isHidden = true
        self.prepareForCropping()
        player?.seek(to: startTime)
        self.endTimeObserver = player?.addBoundaryTimeObserver(forTimes: [NSValue(time: endTime)], queue: .main, using: {
            [weak self] in
            guard let self = self else { return }
            self.player?.pause()
            self.player?.removeTimeObserver(self.endTimeObserver!)
            //          self.croppingView.isHidden = false
        })
        player?.play()
    }
    
    private func loadCleanVideo() {
        guard let videoURL = videoURL else { return }
        
        self.player = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = playerView.layer.bounds
        playerLayer.videoGravity = .resizeAspect
        
        playerView.layer.addSublayer(playerLayer)
    }
    
    
    
    func playTapped(_ sender: UIButton) {
        //      self.croppingView.isHidden = true
        self.prepareForCropping()
        player?.seek(to: startTime)
        self.endTimeObserver = player?.addBoundaryTimeObserver(forTimes: [NSValue(time: endTime)], queue: .main, using: {
            [weak self] in
            guard let self = self else { return }
            self.player?.pause()
            self.player?.removeTimeObserver(self.endTimeObserver!)
            //        self.croppingView.isHidden = false
        })
        player?.play()
    }
    
    
    // func need to be called
    func exportvideo() {
        guard let assetToExport = self.player?.currentItem?.asset else { return }
        guard let composition = self.cropScaleComposition else { return }
        guard let outputMovieURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("exported.mov") else { return }
        
        //      updateControlStatus(enabled: false)
        
        export(assetToExport, to: outputMovieURL, startTime: self.startTime, endTime: self.endTime, composition: composition)
    }
    
    
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
                } else {
                    //            self.shareVideoFile(outputMovieURL)
                    // TODO: Save to local library
                }
            }
        })
    }
    
    func transformVideo(item: AVPlayerItem,
                        cropRect: CGRect = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)) {
        
        let cropScaleComposition = AVMutableVideoComposition(asset: item.asset, applyingCIFiltersWithHandler: { [weak self] request in
            
            guard let self = self else { return }
            
            let sepiaToneFilter = CIFilter.sepiaTone()
            let currentTime = request.compositionTime
            //        sepiaToneFilter.intensity = self.calculateFilterIntensity(self.endTime, currentTime)
            sepiaToneFilter.inputImage = request.sourceImage
            
            let cropFilter = CIFilter(name: "CICrop")!
            cropFilter.setValue(sepiaToneFilter.outputImage!, forKey: kCIInputImageKey)
            cropFilter.setValue(CIVector(cgRect: cropRect), forKey: "inputRectangle")
            
            
            let imageAtOrigin = cropFilter.outputImage!.transformed(by: CGAffineTransform(translationX: -cropRect.origin.x, y: -cropRect.origin.y))
            let imageAtOrigin2 = cropFilter.outputImage!.transformed(by: CGAffineTransform(rotationAngle: 0))
            
//            request.finish(with: imageAtOrigin, context: nil)
            request.finish(with: imageAtOrigin2, context: nil)
        })
        cropScaleComposition.renderSize = cropRect.size
        item.videoComposition = cropScaleComposition
        self.cropScaleComposition = cropScaleComposition
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    
    static func cropVideo(from videoURL: URL, presentOn vc: UIViewController) {
        print("cropVideo has been called ")
       let player = AVPlayer(url: videoURL)
//        guard let assetToExport = player.currentItem?.asset else { return }
       
        let startTime: CMTime = .zero
       guard let endTime = player.currentItem?.duration else { fatalError() }
       let timeRange = CMTimeRangeFromTimeToTime(start: .zero, end: endTime)
       guard let playerItem = player.currentItem else { fatalError() }
       //
       let assetToExport = playerItem.asset
       
       var cropScaleComposition = AVMutableVideoComposition(asset: playerItem.asset, applyingCIFiltersWithHandler: { request in
           
//            guard let self = self else { return }
           
           let sepiaToneFilter = CIFilter.sepiaTone()
           let currentTime = request.compositionTime
           //        sepiaToneFilter.intensity = self.calculateFilterIntensity(self.endTime, currentTime)
           sepiaToneFilter.inputImage = request.sourceImage
           
           let cropRect = CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth)
           
           let cropFilter = CIFilter(name: "CICrop")!
           cropFilter.setValue(sepiaToneFilter.outputImage!, forKey: kCIInputImageKey)
           cropFilter.setValue(CIVector(cgRect: cropRect), forKey: "inputRectangle")
           
           
           let imageAtOrigin = cropFilter.outputImage!.transformed(by: CGAffineTransform(translationX: -cropRect.origin.x, y: -cropRect.origin.y))
           let imageAtOrigin2 = cropFilter.outputImage!.transformed(by: CGAffineTransform(rotationAngle: 0))
           

           request.finish(with: imageAtOrigin2, context: nil)
       })
//        String()
        let fileNameFromUrl = videoURL.absoluteString
       // TODO: use different file name
       guard let outputMovieURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileNameFromUrl) else { fatalError() }
       
        
        // MARK: - Export Function
        
        // asset: assetToExport
        // outputMovieURL: outputMovieURL
        // startTime: startTime
        // composition: cropScaleComposition

//         export(assetToExport, to: outputMovieURL, startTime: startTime, endTime: endTime, composition: cropScaleComposition)

        //delete any old file
        
        // TODO: Enable Delete Func
//        do {
//            try FileManager.default.removeItem(at: outputMovieURL)
//        } catch {
//            print("Could not remove file \(error.localizedDescription)")
//            fatalError()
//        }
        
        let testName = outputMovieURL.absoluteString
        guard let testURL = URL(string: testName) else {
//            print(error.)
            fatalError()}
        
        //create exporter
        // 이게 왜 그런데.. Optional 값이지 ??
        
        let exporter = AVAssetExportSession(asset: assetToExport, presetName: AVAssetExportPresetHighestQuality)
        
        //configure exporter
        exporter?.videoComposition = cropScaleComposition
//        exporter?.outputURL = outputMovieURL
        exporter?.outputURL = testURL
        exporter?.outputFileType = .mov
        exporter?.timeRange = timeRange
        
//        exporter.
//        print("composition")
        
        // 왜 안될까 ?? ?? ?? ?
        exporter?.exportAsynchronously {
            UISaveVideoAtPathToSavedPhotosAlbum(testURL.path, self, nil, nil)
        }
        
        //export!
//        exporter?.exportAsynchronously(completionHandler: { [weak exporter] in
//            DispatchQueue.main.async {
//
//                if let error = exporter?.error {
//                    // failed The operation could not be complete. ??? 이게 이유냐?
//                    print("failed \(error.localizedDescription)")
//                    fatalError()
//                } else {
//                    //            self.shareVideoFile(outputMovieURL)
//                    // TODO: Save to local library
//                    var filesToShare = [Any]()
//
//                    // Add the path of the file to the Array
////                    filesToShare.append(outputMovieURL)
//                    filesToShare.append(testURL)
//
//                    // Make the activityViewContoller which shows the share-view
//                    let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
//
//                    // Show the share-view
//                    vc.present(activityViewController, animated: true, completion: nil)
//
//                    UISaveVideoAtPathToSavedPhotosAlbum(testURL.path, self, nil, nil)
//                }
//            }
//        })
        // end of original export
        
   }
}


class TestController {
    
    typealias CropTaskCompletion = (Result<URL, Error>) -> Void

    // Calculate video frame (center it)
    func cropVideoWithGivenSize(asset: AVAsset, baseSize cropSize: CGSize, completionHandler: @escaping CropTaskCompletion) {
        var cropFilter = CIFilter(name: "CICrop")!
        // Create your context and filter
        // I'll use metal context and CIFilter
        var context = CIContext()
        if let device = MTLCreateSystemDefaultDevice(),
           let filterCrop = CIFilter(name: "CICrop") {
            context = CIContext(mtlDevice: device, options: [.workingColorSpace : NSNull()])
            cropFilter = filterCrop
        }
        
        // Try getting first video track to get size and transform
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            print("No video track to crop.")
            completionHandler(.failure(NSError()))
            return
        }
        // Original video size
        let videoSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
        
        // Create a mutable video composition configured to apply Core Image filters to each video frame of the specified asset.
        let composition = AVMutableVideoComposition(asset: asset, applyingCIFiltersWithHandler: { [weak self] request in
            
            guard let `self` = self else { return }
                        
            // Compute scale and corrective aspect ratio
            let scaleX = cropSize.width / videoSize.width
            let scaleY = cropSize.height / videoSize.height
            let rate = max(scaleX, scaleY)
            let width = videoSize.width * rate
            let height = videoSize.height * rate
            let targetSize = CGSize(width: width, height: height)

            // Handle video frame (CIImage)
            let outputImage = request.sourceImage
            
            // Define your crop rect here
            // I would like to crop video from it's center
            let cropRect = CGRect(
                x: (targetSize.width - cropSize.width) / 2,
                y: (targetSize.height - cropSize.height) / 2,
                width: cropSize.width,
                height: cropSize.height
            )
            
            // Add the .sourceImage (a CIImage) from the request to the filter.
            cropFilter.setValue(outputImage, forKey: kCIInputImageKey)
            // Specify cropping rectangle with converting it to CIVector
            cropFilter.setValue(CIVector(cgRect: cropRect), forKey: "inputRectangle")
            
            // Move the cropped image to the origin of the video frame. When you resize the frame (step 4) it will resize from the origin.
            let imageAtOrigin = cropFilter.outputImage!.transformed(
                by: CGAffineTransform(translationX: -cropRect.origin.x, y: -cropRect.origin.y)
            )
            
            request.finish(with: imageAtOrigin, context: context)
        })
        
        // Update composition render size
        composition.renderSize = cropSize
        
        // Export cropped video with AVAssetExport session
        guard let export = AVAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetHighestQuality)
        else {
            print("Cannot create export session.")
            completionHandler(.failure(NSError()))
            return
        }
        
        let videoName = "Write_Your_Video_Name_Here"
        let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(videoName)
            .appendingPathExtension("mp4") // Change file extension
        
        // Try to remove old file if exist
        try? FileManager.default.removeItem(at: exportURL)
        
        // Assign created mutable video composition to exporter
        export.videoComposition = composition
        export.outputFileType = .mp4 // Change file type (it should be same with extension)
        export.outputURL = exportURL
        export.shouldOptimizeForNetworkUse = false
        
        export.exportAsynchronously {
            DispatchQueue.main.async {
                switch export.status {
                case .completed:
                    completionHandler(.success(exportURL))
                    break
                default:
                    print("Something went wrong during export.")
                    if let error = export.error {
                        completionHandler(.failure(error))
                    } else {
                        completionHandler(.failure(NSError(domain: "unknown error", code: 0, userInfo: nil)))
                    }
                    break
                }
            }
        }
    }
    
}
