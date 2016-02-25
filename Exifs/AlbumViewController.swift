//
//  AlbumViewController.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-07.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit
import Photos

class AlbumViewController: UITableViewController {

    private let reuseIdentifier = "AlbumCell"
    
    private var albums = [Album]()
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAlbums()
    }
    
    private func loadAlbums() {
        albums = []
        
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
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 127
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AlbumCell
        cell.update(albums[indexPath.row])
        return cell
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        navigationController?.pushViewController(ThumbnailViewController.controller(), animated: true)
    }
}
