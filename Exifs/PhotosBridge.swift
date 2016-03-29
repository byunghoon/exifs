//
//  PhotoLibraryBridge.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-03-10.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import Foundation
import Photos

class PhotosBridge: NSObject {
    private(set) var pinnedFirstShelf: Shelf
    private(set) var recentlyUsedShelf: Shelf
    
    private var collectionGroups = [CollectionGroup]()
    private(set) var map = [AlbumId : AssetGroup]()
    
    deinit {
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }
    
    override init() {
        let cameraRoll = CollectionGroup(type: .SmartAlbum, subtype: .SmartAlbumUserLibrary)
        let favorites = CollectionGroup(type: .SmartAlbum, subtype: .SmartAlbumFavorites)
        let userAlbums = CollectionGroup(type: .Album, subtype: .AlbumRegular)
        
        collectionGroups = [cameraRoll, favorites, userAlbums]
        
        for collectionGroup in collectionGroups {
            for collection in collectionGroup.collections {
                map[collection.localIdentifier] = AssetGroup(collection: collection)
            }
        }
        
        pinnedFirstShelf = Shelf(collectionGroups: [cameraRoll, favorites, userAlbums], priorityAlbumIds: [])
        recentlyUsedShelf = Shelf(collectionGroups: [userAlbums], priorityAlbumIds: [])
        
        super.init()
        
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    }
}

extension PhotosBridge: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(changeInstance: PHChange) {
        var changedAssetGroups = Set<AssetGroup>()
        
        for assetGroup in map.values {
            if let details = changeInstance.changeDetailsForFetchResult(assetGroup.fetchResult) {
                assetGroup.fetchResult = details.fetchResultAfterChanges
                changedAssetGroups.insert(assetGroup)
                
                let rice = Rice(
                    hasIncrementalChanges: details.hasIncrementalChanges,
                    removedIndexes: details.removedIndexes,
                    insertedIndexes: details.insertedIndexes,
                    changedIndexes: details.changedIndexes,
                    enumerateMovesWithBlock: details.enumerateMovesWithBlock
                )
                assetGroup.notifyObservers(rice)
            }
        }
        
        var changedCollectionGroups = [CollectionGroup : Bool]()
        for collectionGroup in collectionGroups {
            if let details = changeInstance.changeDetailsForFetchResult(collectionGroup.fetchResult) {
                collectionGroup.fetchResult = details.fetchResultAfterChanges
                changedCollectionGroups[collectionGroup] = details.hasIncrementalChanges
                
            } else {
                for collection in collectionGroup.collections {
                    if let assetGroup = map[collection.localIdentifier] where changedAssetGroups.contains(assetGroup) {
                        changedCollectionGroups[collectionGroup] = true
                        break
                    }
                }
            }
        }
        
        for shelf in [pinnedFirstShelf, recentlyUsedShelf] {
            shelf.notifyObserversIfNeeded(map, changedAssetGroups, changedCollectionGroups)
        }
    }
}

private extension Shelf {
    func notifyObserversIfNeeded(map: [AlbumId : AssetGroup], _ changedAssetGroups: Set<AssetGroup>, _ changedCollectionGroups: [CollectionGroup : Bool]) {
        var hasChanges = false
        var hasIncrementalChanges = true
        
        for collectionGroup in collectionGroups {
            if let boolValue = changedCollectionGroups[collectionGroup] {
                hasChanges = true
                hasIncrementalChanges = boolValue
                
                if !hasIncrementalChanges {
                    break
                }
            }
        }
        
        if !hasChanges {
            return
        }
        
        if !hasIncrementalChanges {
            return notifyObservers(Rice.LargeChangesRice())
        }
        
        var before = collections
        populate()
        let after = collections
        
        let removedIndexes = NSMutableIndexSet()
        var set = Set(after)
        for i in 0..<before.count {
            if !set.contains(before[i]) {
                removedIndexes.addIndex(i)
            }
        }
        for index in removedIndexes {
            before.removeAtIndex(index)
        }
        
        let insertedIndexes = NSMutableIndexSet()
        set = Set(before)
        for i in 0..<after.count {
            if !set.contains(after[i]) {
                insertedIndexes.addIndex(i)
            }
        }
        for index in insertedIndexes {
            before.insert(after[index], atIndex: index)
        }
        
        if before.count != after.count {
            log("Count mismatch after computing removedIndexes and insertedIndexes")
            return notifyObservers(Rice.LargeChangesRice())
        }
        
        let changedIndexes = NSMutableIndexSet()
        for i in 0..<after.count {
            if let afterAssetGroup = map[after[i].localIdentifier] where changedAssetGroups.contains(afterAssetGroup) {
                changedIndexes.addIndex(i)
            } else if before[i].localizedTitle != after[i].localizedTitle {
                changedIndexes.addIndex(i)
            }
        }
        
        var indexMap = [PHAssetCollection : Int]() // index of collections in "after"
        for i in 0..<after.count {
            indexMap[after[i]] = i
        }
        let moveBlock = { (move: ((Int, Int) -> Void)) -> Void in
            for indexBefore in 0..<before.count {
                let collection = before[indexBefore]
                if let indexAfter = indexMap[collection] where indexBefore != indexAfter {
                    move(indexBefore, indexAfter)
                }
            }
        }
        
        let rice = Rice(
            hasIncrementalChanges: true,
            removedIndexes: removedIndexes.count > 0 ? removedIndexes : nil,
            insertedIndexes: insertedIndexes.count > 0 ? insertedIndexes : nil,
            changedIndexes: changedIndexes.count > 0 ? changedIndexes : nil,
            enumerateMovesWithBlock: moveBlock
        )
        notifyObservers(rice)
    }
}
