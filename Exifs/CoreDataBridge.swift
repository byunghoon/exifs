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

struct CoreDataBridge {
    private var managedObjectContext: NSManagedObjectContext
    
    init(modelName: String, storeName: String) {
        guard let modelURL = NSBundle.mainBundle().URLForResource(modelName, withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let docURL = urls[urls.endIndex - 1]
            let storeURL = docURL.URLByAppendingPathComponent("\(storeName).sqlite")
            do {
                try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }
    
    func priorityCollectionIds(type: PriorityType) -> [String] {
        return []
    }
    
    private(set) var pinnedAlbumIds = [String]()
    func pinAlbum(id: String) { print("Pin album not implemented") }
    func unpinAlbum(id: String) {}
    
    private(set) var recentlyUsedAlbumIds = [String]()
    func useAlbum(id: String) {}
    
    private(set) var albumPrefs = [String : AlbumPref]()
    func saveAlbumPrefs(prefs: AlbumPref, forAlbumId id: String) {}
    
    private(set) var mediaRelations = [String : [String]]()
    func relateMedia(mediaId: String, toAlbum albumId: String) {}
    func unrelateMedia(mediaId: String, fromAlbum albumId: String) {}
    func deleteMedia(mediaId: String) {}
    
    func unassociateAlbum(id: String) {}
}
