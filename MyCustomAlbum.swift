//
//  MyCustomAlbum.swift
//  MultiPeer
//
//  Created by 핏투비 on 2022/07/05.
//

import Foundation
import Photos
import UIKit

class MyCustomAlbum: NSObject {
    var name = "Custom Album"
    private var assetCollection: PHAssetCollection!
    
    init(name: String) {
        self.name = name
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
    }
    
    private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", name)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    static func saveToAlbum(named albumName: String, video: URL) {
        let album = MyCustomAlbum(name: albumName)
        DispatchQueue.main.async {
            album.save(video: video)
        }
    }
    
    func createAlbumIfNeeded() {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
        } else {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.name)
            }) { success, error in
                if let error = error {
                    print("error: \(error.localizedDescription)")
                    
                }
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                }
            }
        }
    }
    
    func save(video url: URL) {
        if self.assetCollection != nil {
            PHPhotoLibrary.shared().performChanges({
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                let assetPlaceHolder = assetChangeRequest?.placeholderForCreatedAsset
                
                if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection) {
                    let enumeration: NSArray = [assetPlaceHolder!]
                    albumChangeRequest.addAssets(enumeration)
                }
            }) { success, error in
                if let error = error {
                    print("Error writing to image library: \(error.localizedDescription)")
                    return
                }
            }
        }
    }
    
    
}

