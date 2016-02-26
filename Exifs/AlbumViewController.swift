//
//  AlbumViewController.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-07.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit

class AlbumViewController: UIViewController {
    
    class func controller() -> AlbumViewController {
        return UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier("AlbumViewController") as! AlbumViewController
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
}
