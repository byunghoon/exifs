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
    private var currentRequestID: PHImageRequestID?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentMode = .ScaleAspectFill
        layer.borderColor = Color.gray85.CGColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(asset: PHAsset, targetSize: CGSize) {
        let options = PHImageRequestOptions()
        options.resizeMode = PHImageRequestOptionsResizeMode.Exact
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.Opportunistic
        
        currentRequestID = PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFill, options: options, resultHandler: { (image, info) in
            let requestId = info?[PHImageResultRequestIDKey] as? NSNumber
            let cancelled = info?[PHImageCancelledKey] as? NSNumber
            if requestId?.intValue == self.currentRequestID && cancelled?.boolValue != true, let image = image {
                self.image = image
                self.layer.borderWidth = Unit.pixel
            }
        })
    }
    
    func cancelCurrentLoad() {
        if let requestID = currentRequestID {
            PHImageManager.defaultManager().cancelImageRequest(requestID)
        }
        currentRequestID = nil
        image = nil
        layer.borderWidth = 0
    }
}
