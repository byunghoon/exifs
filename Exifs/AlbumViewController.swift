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
    @IBOutlet weak var gridViewBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var shelfViewRightMargin: NSLayoutConstraint!
    @IBOutlet weak var toolbarBottomMargin: NSLayoutConstraint!
    
    @IBOutlet weak var separator: UIView!
    private let shadowLayer = CAGradientLayer()
    
    private var gridViewController: GridViewController!
    private var shelfViewController: MiniShelfViewController!
    
    private var isShelfShown = false
    private var gestureController: GestureController!
    private var gridViewProperties: CollectionViewProperties?
    
    var album: Album!
    
    class func controller() -> AlbumViewController {
        return UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier("AlbumViewController") as! AlbumViewController
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return Theme.statusBarStyle
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
        items.append(UIBarButtonItem(image: IonIcons.imageWithIcon(ion_ios_trash_outline, size: 30, color: Theme.primaryColor), style: .Plain, target: nil, action: nil))
        items.append(UIBarButtonItem.flexibleItem())
        items.append(UIBarButtonItem(title: "Advanced", color: Theme.primaryColor, target: nil, action: nil))
        toolbar.items = items
        toolbar.barTintColor = Color.white
        toolbar.translucent = false
        
        shadowLayer.colors = [UIColor(white: 0, alpha: 0.1).CGColor, UIColor(white: 0, alpha: 0).CGColor ]
        shadowLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shadowLayer.endPoint = CGPoint(x: 1, y: 0.5)
        separator.layer.addSublayer(shadowLayer)

        setupGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        shadowLayer.frame = separator.bounds
        
        if gridViewBottomMargin.constant == 0 {
            let maxWidth = view.frame.width
            let minWidth = maxWidth - shelfViewController.view.frame.width
            let ratio = minWidth / maxWidth
            let newHeight = gridViewController.view.frame.height / ratio
            gridViewBottomMargin.constant = gridViewController.view.frame.height - newHeight
        }
    }
}

private extension AlbumViewController {
    
    private func setupGesture() {
        let config = GestureController.Config(
            minDuration: 0.05,
            maxDuration: 0.1,
            finalTranslation: shelfViewController.view.frame.width,
            thresholdTranslation: 30,
            thresholdVelocity: 200
        )
        gestureController = GestureController(config: config)
        // TODO: [weak self]
        gestureController.began = {
            if let collectionView = self.gridViewController.collectionView where collectionView.contentSize.height > 0 {
                self.gridViewProperties = CollectionViewProperties(collectionView: collectionView)
            }
        }
        gestureController.constraintAnimations = { (percentage: CGFloat) in
            let p = self.isShelfShown ? percentage : percentage + 1
            
            if p < 0 {
                self.shelfViewRightMargin.constant = 0
                self.toolbarBottomMargin.constant = 0
                
            } else if p > 1 {
                self.shelfViewRightMargin.constant = -config.finalTranslation
                self.toolbarBottomMargin.constant = -self.toolbar.frame.height
                
            } else {
                self.shelfViewRightMargin.constant = -config.finalTranslation * p
                self.toolbarBottomMargin.constant = -self.toolbar.frame.height * p
            }
        }
        gestureController.animations = { (percentage: CGFloat) in
            let maxWidth = self.view.frame.width
            let minWidth = maxWidth - self.shelfViewController.view.frame.width
            let maxHeight = self.view.frame.height - self.gridViewBottomMargin.constant
            
            let s, tx, ty: CGFloat
            if self.isShelfShown {
                s = (minWidth - self.shelfViewRightMargin.constant) / minWidth
                tx = minWidth * (s - 1) / 2
                ty = maxHeight * (s - 1) / 2
                
            } else {
                s = (minWidth - self.shelfViewRightMargin.constant) / maxWidth
                tx = maxWidth * (s - 1) / 2
                ty = maxHeight * (s - 1) / 2
            }
            
            self.gridViewController.view.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(tx, ty), s, s)
            
            if let properties = self.gridViewProperties, collectionView = self.gridViewController.collectionView {
                var contentInset = properties.contentInset
                contentInset.top /= s
                collectionView.contentInset = contentInset
                
                var contentOffset = properties.contentOffset
                contentOffset.y = properties.contentOffset.y + properties.contentInset.top - contentInset.top
                collectionView.contentOffset = contentOffset
            }
        }
        gestureController.finished = {
            self.isShelfShown = self.shelfViewRightMargin.constant == 0
            
            self.gridViewController.view.transform = CGAffineTransformIdentity
            self.gridViewRightMargin.constant = self.shelfViewController.view.frame.width + self.shelfViewRightMargin.constant
            
            if let properties = self.gridViewProperties, collectionView = self.gridViewController.collectionView {
                collectionView.reloadData()
                let height =  self.gridViewController.estimatedContentHeight(self.view.frame.width - self.gridViewRightMargin.constant)
                let y = properties.scrollPosition * height - properties.contentInset.top
                collectionView.contentOffset = CGPoint(x: properties.contentOffset.x, y: max(y, -properties.contentInset.top))
                collectionView.contentInset = properties.contentInset
            }
        }
        view.addGestureRecognizer(gestureController.gestureRecognizer)
    }
}

struct CollectionViewProperties {
    let contentInset: UIEdgeInsets
    let contentOffset: CGPoint
    let contentSize: CGSize
    
    init(collectionView: UICollectionView) {
        contentInset = collectionView.contentInset
        contentOffset = collectionView.contentOffset
        contentSize = collectionView.contentSize
    }
    
    var scrollPosition: CGFloat {
        get {
            return (contentInset.top + contentOffset.y) / contentSize.height
        }
    }
}
