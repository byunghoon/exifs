//
//  NavigationController.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-11.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return topViewController
    }
    
    override func childViewControllerForStatusBarHidden() -> UIViewController? {
        return topViewController
    }
}
