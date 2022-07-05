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

// need subject Info
class TrimmingController {
    
    var player: AVPlayer? {
        didSet {
            guard let duration = player?.currentItem?.duration else { return }
//            let asset = AVURLAsset(url: <#T##NSURL#>)
            endTime = duration
            print("endTime changed to \(endTime)")
        }
    }
    
    var testDuration: Double = 0.0 // millisec 까지 표현
    var cropScaleComposition: AVVideoComposition?
    
    var startTime: CMTime = .zero
    var endTime: CMTime = .zero
    
    var parentVC: UIViewController?
    
    var timeDiff: CMTime
    var subjectName: String
    var screenIndex: Int64
    
    init(url: URL, vc: UIViewController, timeDiff: Int64, subjectName: String, screenIndex: Int64) {
        self.player = AVPlayer(url: url)
        self.parentVC = vc

        self.timeDiff = timeDiff.convertIntoCMTime()
        self.screenIndex = screenIndex
        
        let asset = AVURLAsset(url: url)
        
        testDuration = asset.duration.seconds
        self.subjectName = subjectName
    }
    
    func exportVideo(shouldSave: Bool = true, fileName: String = "default fileName", closure: @escaping (_ CroppedUrl: URL) -> Void ) {
//        print("export Video Triggered! ffffflllllaaaagggg")
        // MARK: - Asset To Export
        guard let assetToExport = self.player?.currentItem?.asset else { fatalError() }
        
        // MARK: - Composition
        guard let playerItem = self.player?.currentItem else { fatalError() }
        
//        let cropRect = setupCropRect(item: playerItem)
//        self.setupCropScaleComposition(item: playerItem, cropRect: cropRect)
//        guard let composition = self.cropScaleComposition else { fatalError() }
        
        // MARK: - Output Movie URL
        // 음....
//        let fileUUID = UUID()
//        let fileName = "someName"
        
        //        guard let outputMovieURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("exported.mov") else { fatalError() }
        
//        guard let outputMovieURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(fileUUID).mov") else { fatalError() }
        
        
        
        guard let outputMovieURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(fileName).mov") else { fatalError() }
        
//        guard let outputMovieURL = URL(string: "hi2.mov") else { fatalError() }
                
//        export(assetToExport, to: outputMovieURL, startTime: self.startTime, endTime: self.endTime, composition: composition)
        
//        let timeRange = CMTimeRangeFromTimeToTime(start: self.startTime, end: self.endTime)
        let timeRange = CMTimeRangeFromTimeToTime(start: self.timeDiff, end: self.endTime)
        
        do {
            try FileManager.default.removeItem(at: outputMovieURL)
        } catch {
            print("Could not remove file \(error.localizedDescription)")
        }
        
//        let exporter = AVAssetExportSession(asset: assetToExport, presetName: AVAssetExportPresetHighestQuality)
        
        let exporter = AVAssetExportSession(asset: assetToExport, presetName: AVAssetExportPreset960x540)
        
//        exporter?.videoComposition = composition
        exporter?.outputURL = outputMovieURL
        exporter?.outputFileType = .mov
        exporter?.timeRange = timeRange
        print("---------- trimming flag ----------")
        print("startTime: \(startTime)")
        print("endTime: \(endTime)")
        print("timeDiff: \(self.timeDiff)")
        exporter?.exportAsynchronously(completionHandler: {
            [weak exporter] in
            DispatchQueue.main.async {
                if let error = exporter?.error {
                    print("failed \(error.localizedDescription)")
                    fatalError()
                } else {
                    if shouldSave {
                    self.saveVideoToLocal(with: outputMovieURL)
                        print("successfully saved video !!")
                    }
                    closure(outputMovieURL)
                }
            }
        })
    }
    
    func setupCropRect(item: AVPlayerItem) -> CGRect {
        
        let renderingSize = item.presentationSize
        
        let size: CGFloat = screenWidth
        
        print("screenWidth: \(screenWidth), screenHeight: \(screenHeight)")
        
        let preferredSize: CGFloat = 1000

        let sizeTobeUsed = preferredSize * 1
        
        let cropRect = CGRect(x: 0, y: 0, width: sizeTobeUsed, height: sizeTobeUsed)
        
        return cropRect
    }
    
    func setupCropScaleComposition(item: AVPlayerItem, cropRect: CGRect) {
        
        let cropScaleComposition = AVMutableVideoComposition(asset: item.asset, applyingCIFiltersWithHandler: { [weak self] request in
                        
            let cropFilter = CIFilter(name: "CICrop")!
            
            cropFilter.setValue(request.sourceImage, forKey: kCIInputImageKey)
            cropFilter.setValue(CIVector(cgRect: cropRect), forKey: "inputRectangle")
            
            let imageAtOrigin = cropFilter.outputImage!.transformed(by: CGAffineTransform(translationX: 0, y: 0 ))
            
            request.finish(with: imageAtOrigin, context: nil)
        })
        
        cropScaleComposition.renderSize = CGSize(width: cropRect.width, height: cropRect.height)
        
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
//        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset960x540)
        
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
                    self.saveVideoToLocal(with: outputMovieURL)
                }
            }
        })
    }
    
    // not used .
//    func shareVideoFile(_ file:URL, presentOn vc: UIViewController) {
//
//        //      updateControlStatus(enabled: true)
//
//        // Create the Array which includes the files you want to share
//        var filesToShare = [Any]()
//
//        // Add the path of the file to the Array
//        filesToShare.append(file)
//
//        // Make the activityViewContoller which shows the share-view
//        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
//
//        // Show the share-view
//        vc.present(activityViewController, animated: true, completion: nil)
//    }
    
    func saveVideoToLocal(with url: URL) {
        let formattedDate = Date().getFormattedDate(format: "yyyy.MM.dd")
        
        // 미리 만들어 놓아야하나.. ??
//        let albumName = "subject5 \(formattedDate)"
//        let albumName = "\(subjectName) \(formattedDate)"
        
//        createAlbumIfNotExist(albumName: albumName)
// screen 값이 주어져야하는데 .. ??
        let screenIndex = 1

        let albumName = "\(screenIndex)_\(subjectName)"
//        let userName = connec
//        let albumName =
        
        MyCustomAlbum.saveToAlbum(named: albumName, video: url)
        
        print("duration: \(self.testDuration)")
        
        // prev code
//        PHPhotoLibrary.shared().performChanges {
//            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
//        }
        
    }
    
    
//    func save(video: URL, completion: (Result<Bool, Error>)) -> () {
//
//            PHPhotoLibrary.shared().performChanges({
//                //                        let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
//                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: video)
//                let assetPlaceHolder = assetChangeRequest?.placeholderForCreatedAsset
//                if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection) {
//                    let enumeration: NSArray = [assetPlaceHolder!]
//                    albumChangeRequest.addAssets(enumeration)
//                }
//
//
//        })
//    }
    
    public func createAlbumIfNotExist(albumName: String) {
        let albumsPhoto:PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        var albumNames = Set<String>()
        albumsPhoto.enumerateObjects({(collection, index, object) in
            let photoInAlbums = PHAsset.fetchAssets(in: collection, options: nil)
//            print("print photoAlbum info")
//            print(photoInAlbums.count)
            print(collection.localizedTitle!)
            albumNames.insert(collection.localizedTitle!)
        })
        // if given albumName not exist, create .
        if albumNames.contains(albumName) == false {
          // Create
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            }) { success, error in
                if success {
                    print("successFully create file of name: \(albumName)")
                } else {
                    print("error: \(error?.localizedDescription)")
                }
            }
        }
    }
    
}

