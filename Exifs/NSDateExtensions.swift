//
//  NSDateExtensions.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-11.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import Foundation

extension NSDate {
    func formattedString() -> String {
        let formatter = NSDateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM/YYYY")
        return formatter.stringFromDate(self)
    }
}