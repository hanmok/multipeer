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
            createAlbumIfNotExist(albumName: albumName)
            album.save(video: video)
        }
    }
    
    static func createAlbumIfNotExist(albumName: String) {
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

