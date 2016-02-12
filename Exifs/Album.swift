//
//  Album.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-09.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import Photos

struct Album {
    let id: String
    let title: String
    let assetCount: Int
    let earliestAsset: PHAsset?
    let latestAsset: PHAsset?
    
    init(collection: PHAssetCollection) {
        id = collection.localIdentifier
        title = collection.localizedTitle ?? "Untitled"
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == \(PHAssetMediaType.Image.rawValue)")
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options: fetchOptions)
        
        assetCount = fetchResult.count
        
        earliestAsset = fetchResult.lastObject as? PHAsset
        latestAsset = fetchResult.firstObject as? PHAsset
    }
}
