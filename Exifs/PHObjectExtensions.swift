//
//  PHObjectExtensions.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-03-10.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import Foundation
import Photos

typealias Album = PHAssetCollection
typealias AlbumId = String

typealias Media = PHAsset
typealias MediaId = String

extension PHFetchResult {
    var allObjects: [AnyObject] {
        get {
            return objectsAtIndexes(NSIndexSet(indexesInRange: NSMakeRange(0, count)))
        }
    }
}

extension PHAssetCollection {
    var name: String {
        get {
            return localizedTitle ?? "Untitled"
        }
    }
    
    var exactCount: Int {
        get {
            if let assetWrapper = DataManager.sharedInstance.photos.map[localIdentifier] {
                return assetWrapper.assetCount
            }
            return 0
        }
    }
    
    var assets: [PHAsset] {
        get {
            if let assetWrapper = DataManager.sharedInstance.photos.map[localIdentifier] {
                return assetWrapper.assets
            }
            return []
        }
    }
}