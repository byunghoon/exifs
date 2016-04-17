//
//  FetchedCollectionGroup.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-04-02.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import Foundation
import Photos

class FetchedCollectionGroup {
    let underlyingFetchResult: PHFetchResult
    let assetCollections: [PHAssetCollection]
    let assetCollectionMap: [String: PHAssetCollection]
    
    init(fetchResult: PHFetchResult) {
        underlyingFetchResult = fetchResult
        assetCollections = fetchResult.allObjects as? [PHAssetCollection] ?? []
        
        var map = [String: PHAssetCollection]()
        for assetCollection in assetCollections {
            map[assetCollection.localIdentifier] = assetCollection
        }
        assetCollectionMap = map
    }
}

struct CollectionType: Hashable {
    let type: PHAssetCollectionType
    let subtype: PHAssetCollectionSubtype
    
    var hashValue: Int {
        get {
            return (type.rawValue << 10) + subtype.rawValue
        }
    }
}

func ==(lhs: CollectionType, rhs: CollectionType) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
