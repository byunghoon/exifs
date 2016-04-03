//
//  CollectionGroup.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-04-02.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import Foundation
import Photos

class CollectionGroup: Hashable {
    let type: PHAssetCollectionType
    let subtype: PHAssetCollectionSubtype
    
    var hashValue: Int {
        get {
            return (type.rawValue << 10) + subtype.rawValue
        }
    }
    
    var fetchResult: PHFetchResult {
        didSet {
            update()
        }
    }
    
    var collections = [PHAssetCollection]()
    
    init(type: PHAssetCollectionType, subtype: PHAssetCollectionSubtype) {
        self.type = type
        self.subtype = subtype
        
        self.fetchResult = PHAssetCollection.fetchAssetCollectionsWithType(type, subtype: subtype, options: nil)
        update()
    }
    
    private func update() {
        collections = fetchResult.allObjects as? [PHAssetCollection] ?? []
    }
}

func ==(lhs: CollectionGroup, rhs: CollectionGroup) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
