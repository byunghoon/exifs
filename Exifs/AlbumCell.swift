//
//  AlbumCell.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-18.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit
import Photos

private class ThumbnailView: UIImageView {
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

class AlbumCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var thumbnailContainer: UIView!
    
    private var thumbnailViews = [ThumbnailView]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        detailLabel.textColor = Color.gray60
        updateThumbnailViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layoutIfNeeded()
        updateThumbnailViews()
    }
    
    func update(album: Album) {
        titleLabel.text = album.title
        
        var dateString = ""
        if let earliestDate = album.assets?.last?.creationDate, latestDate = album.assets?.first?.creationDate {
            if earliestDate.isEqualToDate(latestDate) {
                dateString = "  ·  \(earliestDate.formattedString())"
            } else {
                dateString = "  ·  \(earliestDate.formattedString()) to \(latestDate.formattedString())"
            }
        }
        detailLabel.text = "\(album.assetCount)\(dateString)"
        
        if let assets = album.assets {
            let diameter = thumbnailContainer.frame.height * UIScreen.mainScreen().scale
            let targetSize = CGSize(width: diameter, height: diameter)
            
            let options = PHImageRequestOptions()
            options.resizeMode = PHImageRequestOptionsResizeMode.Exact
            options.deliveryMode = PHImageRequestOptionsDeliveryMode.Opportunistic
            
            for i in 0..<min(assets.count, thumbnailViews.count) {
                let thumbnailView = thumbnailViews[i]
                let asset = assets[i]
                
                thumbnailView.currentRequestID = PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFill, options: options, resultHandler: { (image, info) in
                    let requestId = info?[PHImageResultRequestIDKey] as? NSNumber
                    let cancelled = info?[PHImageCancelledKey] as? NSNumber
                    if requestId?.intValue == thumbnailView.currentRequestID && cancelled?.boolValue != true {
                        thumbnailView.image = image
                    }
                })
            }
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        for thumbnailView in thumbnailViews {
            if let requestID = thumbnailView.currentRequestID {
                PHImageManager.defaultManager().cancelImageRequest(requestID)
            }
            thumbnailView.currentRequestID = nil
            thumbnailView.image = nil
        }
    }
    
    private func updateThumbnailViews() {
        let maxThumbnails = 5
        let diameter = thumbnailContainer.bounds.height
        let margin: CGFloat = 10
        let requiredCount = min(maxThumbnails, Int(thumbnailContainer.bounds.width / (diameter + margin)))
        var rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        
        // resize existing views
        for i in 0..<thumbnailViews.count {
            rect.origin.x = (diameter + margin) * CGFloat(i)
            thumbnailViews[i].frame = rect
            thumbnailViews[i].hidden = false
        }
        
        if thumbnailViews.count < requiredCount {
            // create more views
            for i in thumbnailViews.count..<requiredCount {
                rect.origin.x = (diameter + margin) * CGFloat(i)
                let thumbnailView = ThumbnailView(frame: rect)
                thumbnailView.contentMode = .ScaleAspectFill
                thumbnailView.layer.borderColor = Color.gray85.CGColor
//                thumbnailView.layer.cornerRadius = 2
//                thumbnailView.clipsToBounds = true
                thumbnailContainer.addSubview(thumbnailView)
                thumbnailViews.append(thumbnailView)
            }
            
        } else {
            // hide unnecessary views
            for i in requiredCount..<thumbnailViews.count {
                thumbnailViews[i].hidden = true
            }
        }
    }
}
