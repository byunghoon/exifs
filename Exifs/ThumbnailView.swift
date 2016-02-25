//
//  ThumbnailView.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-25.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit
import Photos

class ThumbnailView: UIImageView {
    var currentRequestID: PHImageRequestID?
    
    override var image: UIImage? {
        get {
            return super.image
        }
        set {
            super.image = newValue
            layer.borderWidth = newValue != nil ? Unit.pixel : 0
        }
    }
}
