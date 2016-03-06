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
}

struct BarButtonItemUtility {
    static func backButtonImage(color: UIColor) -> UIImage {
        let diameter: CGFloat = 28
        var image = IonIcons.imageWithIcon(ion_ios_arrow_left, size: diameter, color: color)
        image = image.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: diameter, bottom: 0, right: 0))
        image = image.imageWithAlignmentRectInsets(UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 0))
        return image
    }
}