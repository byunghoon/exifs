//
//  ThumbnailViewController.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-07.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit

class ThumbnailViewController: UIViewController {
    
    class func controller() -> ThumbnailViewController {
        return UIStoryboard.mainStoryboard().instantiateViewControllerWithIdentifier("ThumbnailViewController") as! ThumbnailViewController
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
