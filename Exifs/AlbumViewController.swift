//
//  AlbumViewController.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-07.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit

class AlbumViewController: UIViewController {
    
    @IBOutlet weak var shadowView: UIView!
    private let shadowLayer = CAGradientLayer()
    
    var gridViewController: GridViewController!
    var shelfViewController: MiniShelfViewController!
    
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
            
        } else if segue.identifier == "EmbedShelf" {
            shelfViewController = segue.destinationViewController as! MiniShelfViewController
            shelfViewController.albums = AssetManager.sharedInstance.albums.filter({ return $0 != album })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = album.title
        
        shadowLayer.colors = [UIColor(white: 0, alpha: 0.1).CGColor, UIColor(white: 0, alpha: 0).CGColor ]
        shadowLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shadowLayer.endPoint = CGPoint(x: 1, y: 0.5)
        shadowView.layer.addSublayer(shadowLayer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        shadowLayer.frame = shadowView.bounds
    }
}
