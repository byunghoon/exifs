//
//  ShelfCell.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-04-03.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit

class ShelfCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var thumbnailContainer: UIView!
    
    private var thumbnailViews = [ThumbnailView]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accessoryView = UIImageView(image: IonIcons.imageWithIcon(ion_ios_arrow_right, size: 22, color: Color.gray60x))
        
        detailLabel.textColor = Color.gray60
        updateThumbnailViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        accessoryView?.frame.origin.x += 8
        
        contentView.layoutIfNeeded()
        updateThumbnailViews()
    }
    
    func update(album: Album, pinned: Bool) {
        var titleAtt = NSMutableAttributedString(string: album.title, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14), NSForegroundColorAttributeName: Color.black])
        if pinned {
            let pinnedAtt = NSMutableAttributedString(string: "\(ion_ios_star) ", attributes: [NSFontAttributeName: IonIcons.fontWithSize(14), NSForegroundColorAttributeName: Color.orange])
            pinnedAtt.appendAttributedString(titleAtt)
            titleAtt = pinnedAtt
        }
        titleLabel.attributedText = titleAtt
        
        var countString = ""
        if album.assetCount == 1 {
            countString = NSLocalizedString("1 photo", comment: "")
        } else {
            countString = String(format: NSLocalizedString("%ld photos", comment: ""), album.assetCount)
        }
        
        var dateString = ""
        if let earliestDate = album.assets.last?.creationDate, latestDate = album.assets.first?.creationDate {
            dateString = ", "
            if earliestDate.isEqualToDate(latestDate) {
                dateString += earliestDate.formattedString()
            } else {
                dateString += String(format: NSLocalizedString("%@ to %@", comment: ""), earliestDate.formattedString(), latestDate.formattedString())
            }
        }
        
        detailLabel.text = "\(countString)\(dateString)"
        
        let diameter = thumbnailContainer.frame.height
        let targetSize = CGSize(width: diameter, height: diameter)
        
        for i in 0..<min(album.assets.count, thumbnailViews.count) {
            thumbnailViews[i].load(album.assets[i], targetSize: targetSize)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        for thumbnailView in thumbnailViews {
            thumbnailView.cancelCurrentLoad()
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
                thumbnailView.showsBorders = true
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
