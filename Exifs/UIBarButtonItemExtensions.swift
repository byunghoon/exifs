//
//  UIBarButtonItemExtensions.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-24.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    class func spaceItem(width: CGFloat) -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        item.width = width
        return item
    }
}
