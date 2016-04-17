//
//  FetchedCollection.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-04-02.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import Foundation
import Photos

class FetchedCollection {
    let underlyingAssetCollection: PHAssetCollection
    let underlyingFetchResult: PHFetchResult
    let assets: [PHAsset]
    let assetCount: Int
    
    init(assetCollection: PHAssetCollection, fetchResult: PHFetchResult) {
        underlyingAssetCollection = assetCollection
        underlyingFetchResult = fetchResult
        assets = fetchResult.allObjects as? [PHAsset] ?? []
        assetCount = fetchResult.count
    }
}
