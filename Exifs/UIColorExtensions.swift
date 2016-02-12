//
//  UIColorExtensions.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-12.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: UInt32, alpha a: CGFloat = 1) {
        let divisor: CGFloat = 255
        
        let r = CGFloat((hex & 0xFF0000) >> 16) / divisor
        let g = CGFloat((hex & 0x00FF00) >> 8) / divisor
        let b = CGFloat(hex & 0x0000FF) / divisor
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
