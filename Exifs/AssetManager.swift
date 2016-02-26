//
//  AssetManager.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-25.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import Photos

struct AssetManager {
    static let sharedInstance = AssetManager()
    
    private(set) var albums = [Album]()
    
    init() {
        let smartAlbumResult = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .Any, options: nil)
        var smartAlbumOrganizer = FetchResultOrganizer<PHAssetCollection>(fetchResult: smartAlbumResult)
        smartAlbumOrganizer.appendResults({ $0.assetCollectionSubtype == .SmartAlbumUserLibrary })
        smartAlbumOrganizer.appendResults({ $0.assetCollectionSubtype == .SmartAlbumFavorites })
        
        for collection in smartAlbumOrganizer.orderedItems {
            albums.append(Album(collection: collection))
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        
        let albumResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: nil)
        var albumOrganizer = FetchResultOrganizer<PHAssetCollection>(fetchResult: albumResult)
        albumOrganizer.appendResults({ $0.assetCollectionSubtype == .AlbumRegular })
        
        for collection in albumOrganizer.orderedItems {
            albums.append(Album(collection: collection))
        }
    }
}

struct FetchResultOrganizer<T: Hashable> {
    private var fetchResult: PHFetchResult
    
    // Use Array for now to respect original ordering in fetchResult;
    // To be replaced with Set when there is any performance issue.
    private var allItems: Array<T>
    
    private(set) var orderedItems: Array<T>
    
    init(fetchResult: PHFetchResult) {
        self.fetchResult = fetchResult
        
        allItems = []
        for i in 0..<fetchResult.count {
            if let item = fetchResult[i] as? T {
                allItems.append(item)
            }
        }
        
        orderedItems = []
    }
    
    mutating func appendResults(predicate: (T) -> Bool) {
        for item in allItems.filter(predicate) {
            allItems.removeAtIndex(allItems.indexOf(item)!)
            orderedItems.append(item)
        }
    }
}
