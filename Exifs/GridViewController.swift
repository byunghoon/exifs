//
//  GridViewController.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-25.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit
import Photos

class GridCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailView: ThumbnailView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbnailView.cancelCurrentLoad()
    }
}

class GridViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let reuseIdentifier = "GridCell"
    
    private var imageCache = [String: UIImage]()
    
    var album: Album!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        imageCache.removeAll()
    }
    
    
    // MARK: - Collection view data source
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return album.assetCount
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! GridCell
        if let asset = album.assets?[indexPath.row] {
            if let image = imageCache[asset.localIdentifier] {
                cell.thumbnailView.image = image
            } else {
                cell.thumbnailView.load(asset, targetSize: cell.thumbnailView.frame.size, completion: { (image) in
                    self.imageCache[asset.localIdentifier] = image
                })
            }
        }
        return cell
    }
    
    
    // MARK: - Collection view delegate flow layout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let diameter = (collectionView.frame.width - 6) / 3
        return CGSize(width: diameter, height: diameter)
    }
}
