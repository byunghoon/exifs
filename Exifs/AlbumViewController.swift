//
//  AlbumViewController.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-07.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit

class AlbumViewController: UIViewController {
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var gridViewRightMargin: NSLayoutConstraint!
    @IBOutlet weak var shadowView: UIView!
    private let shadowLayer = CAGradientLayer()
    
    private var gridViewController: GridViewController!
    private var shelfViewController: MiniShelfViewController!
    
    private var isShelfShown = false
    private var referenceScrollPosition: CGFloat = 0
    private var gestureController: GestureController!
    
    var album: Album!
    
    class func controller() -> AlbumViewController {
        return UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier("AlbumViewController") as! AlbumViewController
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EmbedGrid" {
            gridViewController = segue.destinationViewController as! GridViewController
            gridViewController.album = album
            gridViewController.collectionView?.scrollsToTop = true
            
        } else if segue.identifier == "EmbedShelf" {
            shelfViewController = segue.destinationViewController as! MiniShelfViewController
            shelfViewController.albums = AssetManager.sharedInstance.albums.filter({ return $0 != album })
            shelfViewController.tableView.scrollsToTop = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = album.title
        
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem.spaceItem(-12))
        items.append(UIBarButtonItem(image: IonIcons.imageWithIcon(ion_ios_trash_outline, size: 30, color: Color.blue), style: .Plain, target: nil, action: nil))
        items.append(UIBarButtonItem.flexibleItem())
        items.append(UIBarButtonItem(title: "Advanced", target: nil, action: nil))
        toolbar.items = items
        
        shadowLayer.colors = [UIColor(white: 0, alpha: 0.1).CGColor, UIColor(white: 0, alpha: 0).CGColor ]
        shadowLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shadowLayer.endPoint = CGPoint(x: 1, y: 0.5)
        shadowView.layer.addSublayer(shadowLayer)
        
        let config = GestureController.Config(
            minDuration: 0.05,
            maxDuration: 0.1,
            finalTranslation: 100,
            thresholdTranslation: 30,
            thresholdVelocity: 200
        )
        gestureController = GestureController(config: config)
        gestureController.began = {
            if let collectionView = self.gridViewController.collectionView where collectionView.contentSize.height > 0 {
                self.referenceScrollPosition = collectionView.contentOffset.y / collectionView.contentSize.height
            }
        }
        gestureController.continuousActions = { (percentage: CGFloat) in
            let p = self.isShelfShown ? percentage : percentage + 1
            let x = config.finalTranslation
            
            if p < 0 {
                self.gridViewRightMargin.constant = x
            } else if p > 1 {
                self.gridViewRightMargin.constant = 0
            } else {
                self.gridViewRightMargin.constant = x * (1 - p)
            }
        }
        gestureController.discreteActions = {
            self.reloadGridView()
        }
        gestureController.finished = {
            self.isShelfShown = self.gridViewRightMargin.constant == config.finalTranslation
            self.reloadGridView()
        }
        view.addGestureRecognizer(gestureController.gestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        shadowLayer.frame = shadowView.bounds
    }
    
    private func reloadGridView() {
        if let collectionView = gridViewController.collectionView where collectionView.contentSize.height > 0 {
            collectionView.reloadData()
            collectionView.contentOffset = CGPoint(x: collectionView.contentOffset.x, y: self.referenceScrollPosition * contentHeight())
        }
    }
    
    private func contentHeight() -> CGFloat {
        guard album.assetCount > 0 else {
            return 1
        }
        
        let itemHeight = gridViewController.itemDiameter(view.frame.width - gridViewRightMargin.constant)
        let lineSpacing = gridViewController.itemSpacing()
        let rowSize = ceil(CGFloat(album.assetCount) / CGFloat(gridViewController.columnSize()))
        
        return itemHeight * rowSize + lineSpacing * (rowSize - 1)
    }
}
