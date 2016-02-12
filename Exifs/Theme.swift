//
//  Theme.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-11.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit

struct Unit {
    static let pixel: CGFloat = 1.0 / UIScreen.mainScreen().scale
}

struct Color {
    static let blackColor = UIColor.blackColor()
    static let gray10Color = UIColor(hex: 0x1D1E23)
    static let gray60Color = UIColor(hex: 0x959EA2)
    static let gray85Color = UIColor(white: 0.85, alpha: 1)
    static let whiteColor = UIColor.whiteColor()
    
    static let blueColor = UIColor(hex: 0x0B6DB7)
    static let greenColor = UIColor(hex: 0xC0D84D)
    static let tealColor = UIColor(hex: 0x00A6A9)
}
