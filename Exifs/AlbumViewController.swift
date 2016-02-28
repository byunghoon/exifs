//
//  AlbumViewController.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-07.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit

class AlbumViewController: UIViewController {
    
    @IBOutlet weak var gridViewRightMargin: NSLayoutConstraint!
    @IBOutlet weak var shadowView: UIView!
    private let shadowLayer = CAGradientLayer()
    
    private var gridViewController: GridViewController!
    private var shelfViewController: MiniShelfViewController!
    
    private var isShelfShown = false
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
            self.gridViewController.collectionView?.reloadData()
        }
        gestureController.finished = {
            self.isShelfShown = self.gridViewRightMargin.constant == config.finalTranslation
            self.gridViewController.collectionView?.reloadData()
        }
        view.addGestureRecognizer(gestureController.gestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        shadowLayer.frame = shadowView.bounds
    }
}
