//
//  PhotoLibraryBridge.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-03-10.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import Foundation
import Photos

struct PhotoLibraryUpdates {
    let changedCollections: Set<String>
    let reloadedGroups: Set<CollectionType> // to trigger Rice.LargeChangesRice()
}

protocol PhotoLibraryObserving: class {
    func photoLibrary(photoLibrary: PhotoLibraryBridge, didUpdate updates: PhotoLibraryUpdates)
}

protocol CollectionObserving: class {
    func collection(id: String, didUpdateAssets rice: Rice)
}

class PhotoLibraryBridge: NSObject {
    private var photoLibrary: PHPhotoLibrary
    
    private(set) var collectionGroupMap = [CollectionType : FetchedCollectionGroup]()
    private(set) var collectionMap = [String : FetchedCollection]()
    
    var collectionObservers = [String: [CollectionObserving]]()
    var libraryObservers = [PhotoLibraryObserving]()
    
    deinit {
        photoLibrary.unregisterChangeObserver(self)
    }
    
    init(photoLibrary: PHPhotoLibrary, collectionTypes: [CollectionType]) {
        self.photoLibrary = photoLibrary
        
        for type in collectionTypes {
            let fetchResult = PHAssetCollection.fetchAssetCollectionsWithType(type.type, subtype: type.subtype, options: nil)
            collectionGroupMap[type] = FetchedCollectionGroup(fetchResult: fetchResult)
            
            let assetCollections = fetchResult.allObjects as? [PHAssetCollection] ?? []
            for assetCollection in assetCollections {
                let fetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: PhotoLibraryBridge.fetchOptions())
                collectionMap[assetCollection.localIdentifier] = FetchedCollection(assetCollection: assetCollection, fetchResult: fetchResult)
            }
        }
        
        super.init()
        
        photoLibrary.registerChangeObserver(self)
    }
    
    private static func fetchOptions() -> PHFetchOptions {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType == \(PHAssetMediaType.Image.rawValue)")
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return options
    }
    
    func addObserver(observer: PhotoLibraryObserving) {
        libraryObservers.append(observer)
    }
    
    func removeObserver(observer: PhotoLibraryObserving) {
        for i in 0..<libraryObservers.count {
            if libraryObservers[i] === observer {
                libraryObservers.removeAtIndex(i)
                return
            }
        }
    }
    
    func notifyLibraryObservers(updates: PhotoLibraryUpdates) {
        for observer in libraryObservers {
            observer.photoLibrary(self, didUpdate: updates)
        }
    }
    
    func addObserver(observer: CollectionObserving, forId id: String) {
        var observers: [CollectionObserving] = collectionObservers[id] ?? []
        observers.append(observer)
        collectionObservers[id] = observers
    }
    
    func removeObserver(observer: CollectionObserving, forId id: String) {
        if var observers = collectionObservers[id] {
            for i in 0..<observers.count {
                if observers[i] === observer {
                    observers.removeAtIndex(i)
                    collectionObservers[id] = observers
                    return
                }
            }
        }
    }
    
    func notifyCollectionObservers(id: String, forChanges rice: Rice) {
        if let observers = collectionObservers[id] {
            for observer in observers {
                observer.collection(id, didUpdateAssets: rice)
            }
        }
    }
}

extension PhotoLibraryBridge: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(changeInstance: PHChange) {
        
        // Update collectionMap based on changes in groups
        for group in collectionGroupMap.values {
            let details = changeInstance.changeDetailsForFetchResult(group.underlyingFetchResult)
            guard let removedObjects = details?.removedObjects as? [PHAssetCollection],
                insertedObjects = details?.insertedObjects as? [PHAssetCollection] else {
                continue
            }
            
            for assetCollection in removedObjects {
                let id = assetCollection.localIdentifier
                collectionMap.removeValueForKey(id)
            }
            for assetCollection in insertedObjects {
                let fetchResult = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: PhotoLibraryBridge.fetchOptions())
                collectionMap[assetCollection.localIdentifier] = FetchedCollection(assetCollection: assetCollection, fetchResult: fetchResult)
            }
        }
        
        // Identify collection changes
        var changedCollections = Set<String>()
        for mapEntry in collectionMap {
            let id = mapEntry.0
            let collection = mapEntry.1
            guard let details = changeInstance.changeDetailsForFetchResult(collection.underlyingFetchResult) else {
                continue
            }
            
            collectionMap[id] = FetchedCollection(assetCollection: collection.underlyingAssetCollection, fetchResult: details.fetchResultAfterChanges)
            changedCollections.insert(id)
            notifyCollectionObservers(id, forChanges: Rice.RiceFromFetchResultChangeDetails(details))
        }
        
        // Identify group changes
        var reloadedGroups = Set<CollectionType>()
        for mapEntry in collectionGroupMap {
            let type = mapEntry.0
            let group = mapEntry.1
            guard let details = changeInstance.changeDetailsForFetchResult(group.underlyingFetchResult) else {
                continue
            }
            
            collectionGroupMap[type] = FetchedCollectionGroup(fetchResult: details.fetchResultAfterChanges)
            
            guard details.hasIncrementalChanges,
                let changedObjects = details.changedObjects as? [PHAssetCollection] else {
                reloadedGroups.insert(type)
                continue
            }
            
            for assetCollection in changedObjects {
                changedCollections.insert(assetCollection.localIdentifier)
            }
        }
        
        let updates = PhotoLibraryUpdates(changedCollections: changedCollections, reloadedGroups: reloadedGroups)
        notifyLibraryObservers(updates)
    }
}
