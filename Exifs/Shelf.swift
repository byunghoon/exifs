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
    func shelfDidChange(rice: Rice)
}

class Shelf {
    let photos: PhotoLibraryBridge
    let data: CoreDataBridge
    let collectionTypes: [CollectionType]
    let priorityType: PriorityType
    let excludedIds: [String]
    private(set) var albums = [Album]()
    
    private var observers = [ShelfObserving]()
    
    deinit {
        photos.removeObserver(self)
        data.removeObserver(self)
    }
    
    init(photos: PhotoLibraryBridge, data: CoreDataBridge, collectionTypes: [CollectionType], priorityType: PriorityType, excludedIds: [String]? = nil) {
        self.photos = photos
        self.data = data
        self.collectionTypes = collectionTypes
        self.priorityType = priorityType
        self.excludedIds = excludedIds ?? []
        populate()
        
        // TODO: remove service.mainShelf & make ShelfVC own a shelf.
        // Also move addObserver/removeObserver calls to VCs to allow selective observing,
        // e.g. MiniShelfVC should not update based on UseRecord updates.
        photos.addObserver(self)
        data.addObserver(self)
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
        for observer in self.observers {
            observer.shelfDidChange(rice)
        }
    }
}

private extension Shelf {
    func populate() {
        albums.removeAll(keepCapacity: true)
        
        var orderedIds = [String]()
        var unusedIds = Set<String>()
        var typeMap = [String: CollectionType]()
        for type in collectionTypes {
            if let collectionGroup = photos.collectionGroupMap[type] {
                for assetCollection in collectionGroup.assetCollections {
                    let id = assetCollection.localIdentifier
                    if excludedIds.contains(id) {
                        continue
                    }
                    orderedIds.append(id)
                    unusedIds.insert(id)
                    typeMap[id] = type
                }
            }
        }
        
        for priorityId in data.priorityCollectionIds(priorityType) {
            if unusedIds.contains(priorityId) {
                guard let type = typeMap[priorityId] else {
                    continue
                }
                albums.append(Album(photos: photos, id: priorityId, type: type))
                unusedIds.remove(priorityId)
                
            } else {
                log("album does not exist, need to unassociate")
            }
        }
        
        for normalId in orderedIds {
            if unusedIds.contains(normalId) {
                guard let type = typeMap[normalId] else {
                    continue
                }
                albums.append(Album(photos: photos, id: normalId, type: type))
                unusedIds.remove(normalId)
            }
        }
    }
    
    func updateForLargeChanges() {
        populate()
        notifyObservers(Rice.LargeChangesRice())
    }
    
    func updateForIncrementalChanges(changedCollections: Set<String>?) {
        var before = albums.map({ $0.id })
        populate()
        let after = albums.map({ $0.id })
        
        // R of RICE
        let removedIndexes = NSMutableIndexSet()
        var removedIds = [String]()
        var set = Set(after)
        for i in 0..<before.count {
            if !set.contains(before[i]) {
                removedIndexes.addIndex(i)
                removedIds.append(before[i])
            }
        }
        for index in removedIndexes {
            before.removeAtIndex(index)
        }
        
        // I of RICE
        let insertedIndexes = NSMutableIndexSet()
        var insertedIds = [String]()
        set = Set(before)
        for i in 0..<after.count {
            if !set.contains(after[i]) {
                insertedIndexes.addIndex(i)
                insertedIds.append(after[i])
            }
        }
        for index in insertedIndexes {
            before.insert(after[index], atIndex: index)
        }
        
        if before.count != after.count {
            log("Count mismatch after computing removedIndexes and insertedIndexes")
            return notifyObservers(Rice.LargeChangesRice())
        }
        
        // C of RICE
        // TODO: use after or before?
        let changedIndexes = NSMutableIndexSet()
        var changedIds = [String]()
        if let changedCollections = changedCollections {
            for i in 0..<after.count {
                if changedCollections.contains(after[i]) {
                    changedIndexes.addIndex(i)
                    changedIds.append(after[i])
                }
            }
        }
        
        // E of RICE
        var indexMap = [String : Int]() // index of collections in "after"
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
        
        notifyObservers(
            Rice(
                hasIncrementalChanges: true,
                removedIndexes: removedIndexes.count > 0 ? removedIndexes : nil,
                insertedIndexes: insertedIndexes.count > 0 ? insertedIndexes : nil,
                changedIndexes: changedIndexes.count > 0 ? changedIndexes : nil,
                enumerateMovesWithBlock: moveBlock,
                removedObjects: removedIds.isEmpty ? nil : removedIds,
                insertedObjects: insertedIds.isEmpty ? nil : insertedIds,
                changedObjects: changedIds.isEmpty ? nil : changedIds
            )
        )
    }
}

extension Shelf: CoreDataObserving {
    func coreData(data: CoreDataBridge, didUpdatePriority priorityType: PriorityType) {
        if self.priorityType == priorityType {
            updateForIncrementalChanges(nil)
        }
    }
}

extension Shelf: PhotoLibraryObserving {
    func photoLibrary(photoLibrary: PhotoLibraryBridge, didUpdate updates: PhotoLibraryUpdates) {
        for type in collectionTypes {
            if updates.reloadedGroups.contains(type) {
                return updateForLargeChanges()
            }
        }
        
        updateForIncrementalChanges(updates.changedCollections)
    }
}
