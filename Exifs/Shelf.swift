//
//  Shelf.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-04-02.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import Foundation
import Photos

protocol ShelfObserving: class {
    func shelfDidChange(changes: Rice)
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
    
    func addObserver(observer: ShelfObserving) {
        observers.append(observer)
    }
    
    func removeObserver(observer: ShelfObserving) {
        for i in 0..<observers.count {
            if observers[i] === observer {
                observers.removeAtIndex(i)
                return
            }
        }
    }
    
    func notifyObservers(rice: Rice) {
        dispatch_async(dispatch_get_main_queue()) {
            for observer in self.observers {
                observer.shelfDidChange(rice)
            }
        }
    }
}
