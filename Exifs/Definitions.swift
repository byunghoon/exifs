//
//  Definitions.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-03-10.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import Foundation
import Photos

protocol ShelfObserving {
    func shelfDidChange(changes: Rice)
}

protocol AssetObserving {
    func assetDidChange(changes: Rice)
}

struct Rice {
    let hasIncrementalChanges: Bool
    
    let removedIndexes: NSIndexSet?
    let insertedIndexes: NSIndexSet?
    let changedIndexes: NSIndexSet?
    let enumerateMovesWithBlock: (((Int, Int) -> Void) -> Void)?
    
    static func LargeChangesRice() -> Rice {
        return Rice(hasIncrementalChanges: false, removedIndexes: nil, insertedIndexes: nil, changedIndexes: nil, enumerateMovesWithBlock: nil)
    }
}

class Shelf {
    var collectionGroups: [CollectionGroup]
    var priorityAlbumIds: [String]
    
    var collections = [PHAssetCollection]()
    
    var observers = [ShelfObserving]()
    
    init(collectionGroups: [CollectionGroup], priorityAlbumIds: [String]) {
        self.collectionGroups = collectionGroups
        self.priorityAlbumIds = priorityAlbumIds
        populate()
    }
    
    func populate() {
        collections.removeAll(keepCapacity: true)
        
        var map = [String : PHAssetCollection]()
        var allAlbumIds = [String]()
        for collectionGroup in collectionGroups {
            for collection in collectionGroup.collections {
                map[collection.localIdentifier] = collection
                allAlbumIds.append(collection.localIdentifier)
            }
        }
        
        for id in priorityAlbumIds {
            if let collection = map[id] {
                collections.append(collection)
                map.removeValueForKey(id)
                
            } else {
                log("album does not exist, need to unassociate")
            }
        }
        
        for id in allAlbumIds {
            if let collection = map[id] {
                collections.append(collection)
                map.removeValueForKey(id)
            }
        }
    }
    
    func notifyObservers(rice: Rice) {
        for observer in observers {
            observer.shelfDidChange(rice)
        }
    }
}

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

class AssetGroup: Hashable {
    let localIdentifier: String
    
    var hashValue: Int {
        get {
            return localIdentifier.hashValue
        }
    }
    
    var fetchResult: PHFetchResult {
        didSet {
            update()
        }
    }
    
    var assets = [PHAsset]()
    var assetCount = 0
    
    var observers = [AssetObserving]()
    
    init(collection: PHAssetCollection) {
        self.localIdentifier = collection.localIdentifier
        
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType == \(PHAssetMediaType.Image.rawValue)")
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options: options)
        self.fetchResult = fetchResult
        update()
    }
    
    private func update() {
        assets = fetchResult.allObjects as? [PHAsset] ?? []
        assetCount = fetchResult.count
    }
    
    func notifyObservers(rice: Rice) {
        for observer in observers {
            observer.assetDidChange(rice)
        }
    }
}

func ==(lhs: AssetGroup, rhs: AssetGroup) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
