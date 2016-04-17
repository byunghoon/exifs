//
//  PHObjectExtensions.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-03-10.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import Foundation
import Photos

extension PHFetchResult {
    var allObjects: [AnyObject] {
        get {
            return objectsAtIndexes(NSIndexSet(indexesInRange: NSMakeRange(0, count)))
        }
    }
}
