//
//  UIImageExtensions.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-04-03.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit

extension UIImage {
    func paddedImage(padding: UIEdgeInsets) -> UIImage {
        let paddedSize = CGSizeMake(size.width + padding.left + padding.right, size.height + padding.top + padding.bottom)
        UIGraphicsBeginImageContextWithOptions(paddedSize, false, self.scale)
        UIGraphicsGetCurrentContext()
        self.drawAtPoint(CGPoint(x: padding.left, y: padding.top))
        let paddedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return paddedImage
    }
}
