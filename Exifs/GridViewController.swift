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
    
    var service: Service!
    var album: Album!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        service.photos.addObserver(self, forId: album.id)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        service.photos.removeObserver(self, forId: album.id)
    }
    
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
        guard album.assetCount > 0 else {
            return 1
        }
        
        let rowSize = ceil(CGFloat(album.assetCount) / CGFloat(columnSize()))
        return itemDiameter(collectionViewWidth) * rowSize + itemSpacing() * (rowSize - 1)
    }
}

extension GridViewController: CollectionObserving {
    func collection(id: String, didUpdateAssets rice: Rice) {
        dispatch_async(dispatch_get_main_queue()) {
            print("Grid: \(rice)")
            
            guard let collectionView = self.collectionView else {
                return
            }
            
            if !rice.hasIncrementalChanges {
                return collectionView.reloadData()
            }
            
            collectionView.performBatchUpdates({ 
                if let indexSet = rice.removedIndexes {
                    collectionView.deleteItemsAtIndexPaths(indexSet.toIndexPaths())
                }
                if let indexSet = rice.insertedIndexes {
                    collectionView.insertItemsAtIndexPaths(indexSet.toIndexPaths())
                }
                
                }, completion: { (completed) in
                    if let indexSet = rice.changedIndexes {
                        collectionView.reloadItemsAtIndexPaths(indexSet.toIndexPaths())
                    }
                    rice.enumerateMovesWithBlock?({ (before, after) in
                        let from = NSIndexPath(forRow: before, inSection: 0)
                        let to = NSIndexPath(forRow: after, inSection: 0)
                        collectionView.moveItemAtIndexPath(from, toIndexPath: to)
                    })
            })
        }
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
