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
        return album.exactCount
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! GridCell
        let asset = album.assets[indexPath.row]
        if let image = imageCache[asset.localIdentifier] {
            cell.thumbnailView.image = image
        } else {
            cell.thumbnailView.load(asset, targetSize: cell.thumbnailView.frame.size, completion: { (image) in
                self.imageCache[asset.localIdentifier] = image
            })
        }
        return cell
    }
    
    
    // MARK: - Collection view delegate flow layout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let diameter = itemDiameter(collectionView.frame.width)
        
        let deficit = (diameter * CGFloat(columnSize()) + totalInteritemSpacing()) - collectionView.frame.width
        if indexPath.row % columnSize() >= columnSize() - Int(deficit) {
            return CGSize(width: diameter - 1, height: diameter)
        }
        
        return CGSize(width: diameter, height: diameter)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1
    }
    
    
    // MARK: - Helper
    
    func columnSize() -> Int {
        return 3
    }
    
    func itemSpacing() -> CGFloat {
        return 1
    }
    
    func totalInteritemSpacing() -> CGFloat {
        return itemSpacing() * CGFloat(columnSize() - 1)
    }
    
    func itemDiameter(collectionViewWidth: CGFloat) -> CGFloat {
        return ceil((collectionViewWidth - totalInteritemSpacing()) / CGFloat(columnSize()))
    }
    
    func estimatedContentHeight(collectionViewWidth: CGFloat) -> CGFloat {
        guard album.exactCount > 0 else {
            return 1
        }
        
        let rowSize = ceil(CGFloat(album.exactCount) / CGFloat(columnSize()))
        return itemDiameter(collectionViewWidth) * rowSize + itemSpacing() * (rowSize - 1)
    }
}

class GridViewFlowLayout: UICollectionViewFlowLayout {
    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItemAtIndexPath(itemIndexPath)
    }
    
    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItemAtIndexPath(itemIndexPath)
    }
}
