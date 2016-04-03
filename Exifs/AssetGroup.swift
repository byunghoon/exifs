//
//  AssetGroup.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-04-02.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import Foundation
import Photos

protocol AssetObserving: class {
    func assetDidChange(changes: Rice)
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
    
    func addObserver(observer: AssetObserving) {
        observers.append(observer)
    }
    
    func removeObserver(observer: AssetObserving) {
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
                observer.assetDidChange(rice)
            }
        }
    }
}

func ==(lhs: AssetGroup, rhs: AssetGroup) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
