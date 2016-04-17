//
//  Service.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-25.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import Foundation
import Photos

struct Service {
    private(set) var data: CoreDataBridge
    private(set) var photos: PhotoLibraryBridge
    
    private(set) var mainShelf: Shelf
    
    private var unrelatedAssets = [PHAsset]() // (cameraRoll) minus (all album entries)
    
    init() {
        data = CoreDataBridge(modelName: "Model", storeName: "Model")
        
        let cameraRollType = CollectionType(type: .SmartAlbum, subtype: .SmartAlbumUserLibrary)
        let favoritesType = CollectionType(type: .SmartAlbum, subtype: .SmartAlbumFavorites)
        let userAlbumsType = CollectionType(type: .Album, subtype: .AlbumRegular)
        photos = PhotoLibraryBridge(photoLibrary: PHPhotoLibrary.sharedPhotoLibrary(), collectionTypes: [cameraRollType, favoritesType, userAlbumsType])
        
        mainShelf = Shelf(photos: photos, data: data, collectionTypes: [cameraRollType, favoritesType, userAlbumsType], priorityType: .Pinned)
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
    
    func deleteAlbum(album: PHAssetCollection) {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            PHAssetCollectionChangeRequest.deleteAssetCollections([album])
            
        }) { (success, error) in
            if let error = error {
                log("Delete album \(album) failed: \(error.localizedDescription)")
            }
        }
    }
//
//    func addPhotos(photos: [PHAsset], toAlbum album: Album) {} // update RecentlyAdded order
//    func removePhotos(photos: [PHAsset], fromAlbum album: Album) {}
}
