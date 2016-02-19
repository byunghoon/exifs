//
//  AlbumViewController.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-07.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit
import Photos

class AlbumCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    private var currentRequestID: PHImageRequestID?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumbnailView.layer.borderColor = Color.gray85.CGColor
        thumbnailView.layer.borderWidth = Unit.pixel
        thumbnailView.layer.cornerRadius = 2
        
        detailLabel.textColor = Color.gray60
    }
    
    func update(album: Album) {
        if let asset = album.latestAsset {
            currentRequestID = PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: thumbnailView.frame.size, contentMode: .AspectFill, options: nil, resultHandler: { (image, info) in
                let requestId = info?[PHImageResultRequestIDKey] as? NSNumber
                let cancelled = info?[PHImageCancelledKey] as? NSNumber
                if requestId?.intValue == self.currentRequestID && cancelled?.boolValue != true {
                    self.thumbnailView.image = image
                }
            })
        }
        
        titleLabel.text = album.title
        
        var dateString = ""
        if let earliestDate = album.earliestAsset?.creationDate, latestDate = album.latestAsset?.creationDate {
            if earliestDate.isEqualToDate(latestDate) {
                dateString = "  ·  \(earliestDate.formattedString())"
            } else {
                dateString = "  ·  \(earliestDate.formattedString()) to \(latestDate.formattedString())"
            }
        }
        
        detailLabel.text = "\(album.assetCount)\(dateString)"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let requestID = currentRequestID {
            PHImageManager.defaultManager().cancelImageRequest(requestID)
        }
        
        currentRequestID = nil
        thumbnailView.image = nil
    }
}


// MARK: -

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
        
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        
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
        return 90
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! AlbumCell
        cell.update(albums[indexPath.row])
        return cell
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
