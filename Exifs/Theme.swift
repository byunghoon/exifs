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
    static let black = UIColor.blackColor()
    static let gray10 = UIColor(hex: 0x1D1E23)
    static let gray60 = UIColor(hex: 0x959EA2)
    static let gray85 = UIColor(white: 0.85, alpha: 1)
    static let white = UIColor.whiteColor()
    
    static let blue = UIColor(hex: 0x0B6DB7)
    static let green = UIColor(hex: 0xC0D84D)
    static let teal = UIColor(hex: 0x00A6A9)
    static let purple = UIColor(hex: 0x5D3462)
    static let mulberry = UIColor(hex: 0xDB4E9C)
    static let orange = UIColor(hex: 0xED9149)
}

struct Theme {
    static let statusBarStyle = UIStatusBarStyle.Default
    // sky blue 00B5E3
    // green 50BA6E
    static let primaryColor = Color.blue
}
