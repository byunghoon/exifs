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
    
    var showsBorders = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        contentMode = .ScaleAspectFill
        layer.borderColor = Color.gray85.CGColor
    }
    
    func load(asset: PHAsset, targetSize: CGSize, completion: ((image: UIImage) -> Void)? = nil) {
        let options = PHImageRequestOptions()
        options.resizeMode = PHImageRequestOptionsResizeMode.Exact
        options.deliveryMode = PHImageRequestOptionsDeliveryMode.Opportunistic
        
        let scale = UIScreen.mainScreen().scale
        let scaledTargetSize = CGSize(width: targetSize.width * scale, height: targetSize.height * scale)
        
        currentRequestID = PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: scaledTargetSize, contentMode: .AspectFill, options: options, resultHandler: { (image, info) in
            let requestID = info?[PHImageResultRequestIDKey] as? NSNumber
            let cancelled = info?[PHImageCancelledKey] as? NSNumber
            if let currentRequestID = self.currentRequestID, image = image where requestID?.intValue == currentRequestID && cancelled?.boolValue != true {
                self.image = image
                
                if self.showsBorders {
                    self.layer.borderWidth = Unit.pixel
                }
                
                completion?(image: image)
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
