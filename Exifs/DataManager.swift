//
//  DataManager.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-25.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import Foundation
import Photos

struct DataManager {
    static let sharedInstance = DataManager()
    
    private(set) var photos = PhotosBridge()
    private var data = CoreDataBridge()
    
    private var unrelatedAssets = [PHAsset]() // (cameraRoll) minus (all album entries)
    
    func getAlbumsPinnedFirst() -> [PHAssetCollection] {
        return photos.pinnedFirstShelf.collections
    }
    
    func getAlbumsRecentlyUsed() -> [PHAssetCollection] {
        return photos.recentlyUsedShelf.collections
    }
    
    func createAlbum(title: String?, withPhotos photosToAdd: [PHAsset]? = nil) {
        let albumTitle = (title == nil || title == "") ? "Untitled" : title!
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ 
            PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(albumTitle)
            
            }) { (success, error) in
                if let error = error {
                    log("Create album with name \"\(albumTitle)\" failed: \(error.localizedDescription)")
                }
        }
    }
    
//
//    func addPhotos(photos: [PHAsset], toAlbum album: Album) {} // update RecentlyAdded order
//    func removePhotos(photos: [PHAsset], fromAlbum album: Album) {}
//    
//    func updateAlbumPrefs(album: Album, prefs: AlbumPref) {}
}
