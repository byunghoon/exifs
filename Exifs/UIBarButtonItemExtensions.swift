//
//  UIBarButtonItemExtensions.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-24.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    class func flexibleItem() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    }
    
    class func spaceItem(width: CGFloat) -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        item.width = width
        return item
    }
    
    convenience init(title: String?, target: AnyObject?, action: Selector) {
        self.init(title: title, style: .Plain, target: target, action: action)
        setTitleTextAttributes([NSForegroundColorAttributeName: Color.blue], forState: .Normal)
    }
}
