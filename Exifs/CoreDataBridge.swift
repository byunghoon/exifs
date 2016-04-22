//
//  CoreDataBridge.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-03-09.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit
import CoreData

struct AlbumPref {
    let scrollOffset: CGPoint // or index?
    let lastSelection: [String]
}

enum PriorityType {
    case Pinned, RecentlyUsed
}

protocol CoreDataObserving: class {
    func coreData(data: CoreDataBridge, didUpdatePriority priorityType: PriorityType)
}

class CoreDataBridge {
    private var context: NSManagedObjectContext
    
    private var observers = [CoreDataObserving]()
    
    private var pinRecords =  [AlbumRecord]()
    private var useRecords = [AlbumRecord]()
    
    init(modelName: String, storeName: String) {
        // create stack
        guard let modelURL = NSBundle.mainBundle().URLForResource(modelName, withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = psc
        
        // Blocking
        let URLs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let appDocumentsURL = URLs[URLs.endIndex - 1]
        let storeURL = appDocumentsURL.URLByAppendingPathComponent("\(storeName).sqlite")
        do {
            try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
        // End blocking
        
        // load data
        pinRecords = fetch("PinRecord", sortKey: "date") as? [AlbumRecord] ?? []
        useRecords = fetch("UseRecord", sortKey: "date") as? [AlbumRecord] ?? []
    }
    
    private func fetch(entityName: String, sortKey: String) -> [AnyObject] {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: false)]
        
        do {
            let results = try context.executeFetchRequest(fetchRequest)
            print("\(entityName) has \(results.count) entries")
            return results
            
        } catch {
            log("Fetch error: \((error as NSError).localizedDescription)")
            return []
        }
    }
    
    private func save() -> Bool {
        do {
            try context.save()
            return true
            
        } catch {
            log("Save error: \((error as NSError).localizedDescription)")
            return false
        }
    }
    
    func addObserver(observer: CoreDataObserving) {
        observers.append(observer)
    }
    
    func removeObserver(observer: CoreDataObserving) {
        for i in 0..<observers.count {
            if observers[i] === observer {
                observers.removeAtIndex(i)
                return
            }
        }
    }
    
    private func notifyObservers(type: PriorityType) {
        for observer in observers {
            observer.coreData(self, didUpdatePriority: type)
        }
    }
}

extension CoreDataBridge {
    func priorityCollectionIds(type: PriorityType) -> [String] {
        switch type {
        case .Pinned:
            return pinRecords.map({ $0.id })
        case .RecentlyUsed:
            return useRecords.map({ $0.id })
        }
    }
    
    func pinAlbum(id: String) -> Bool {
        guard let entity = NSEntityDescription.entityForName("PinRecord", inManagedObjectContext: context) else {
            log("Cannot create NSEntityDescription for PinRecord")
            return false
        }
        
        if pinRecords.filter({ $0.id == id }).first != nil {
            log("Record already exists for \(id)")
            return false
        }
        
        let newRecord = AlbumRecord(entity: entity, insertIntoManagedObjectContext: context)
        newRecord.id = id
        pinRecords.append(newRecord)
        
        if save() {
            notifyObservers(.Pinned)
            return true
        }
        
        return false
    }
    
    func unpinAlbum(id: String) -> Bool {
        for i in 0..<pinRecords.count {
            if pinRecords[i].id == id {
                context.deleteObject(pinRecords[i])
                pinRecords.removeAtIndex(i)
                
                if save() {
                    notifyObservers(.Pinned)
                    return true
                }
                
                return false
            }
        }
        
        return false
    }
    
    func useAlbum(id: String) -> Bool {
        guard let entity = NSEntityDescription.entityForName("UseRecord", inManagedObjectContext: context) else {
            log("Cannot create NSEntityDescription for UseRecord")
            return false
        }
        
        for i in 0..<useRecords.count {
            if useRecords[i].id == id {
                context.deleteObject(useRecords[i])
                useRecords.removeAtIndex(i)
                break
            }
        }
        
        let newRecord = AlbumRecord(entity: entity, insertIntoManagedObjectContext: context)
        newRecord.id = id
        useRecords.insert(newRecord, atIndex: 0)
        
        return save()
        // do not notify observers, for now
    }
}

extension CoreDataBridge {
//    private(set) var albumPrefs = [String : AlbumPref]()
//    func saveAlbumPrefs(prefs: AlbumPref, forAlbumId id: String) {}
//    
//    private(set) var mediaRelations = [String : [String]]()
//    func relateMedia(mediaId: String, toAlbum albumId: String) {}
//    func unrelateMedia(mediaId: String, fromAlbum albumId: String) {}
//    func deleteMedia(mediaId: String) {}
//    
//    func unassociateAlbum(id: String) {}
}
