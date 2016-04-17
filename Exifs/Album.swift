//
//  Album.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-04-16.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import Foundation
import Photos

class Album {
    let photos: PhotoLibraryBridge
    let id: String
    let type: CollectionType
    
    var underlyingAssetCollection: PHAssetCollection? {
        get {
            return photos.collectionGroupMap[type]?.assetCollectionMap[id]
        }
    }
    var title: String {
        get {
            return underlyingAssetCollection?.localizedTitle ?? "Untitled"
        }
    }
    var assets: [PHAsset] {
        get {
            return photos.collectionMap[id]?.assets ?? []
        }
    }
    var assetCount: Int {
        get {
            return photos.collectionMap[id]?.assetCount ?? 0
        }
    }
    
    init(photos: PhotoLibraryBridge, id: String, type: CollectionType) {
        self.photos = photos
        self.id = id
        self.type = type
    }
}
