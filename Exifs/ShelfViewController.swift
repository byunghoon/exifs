//
//  ShelfViewController.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-07.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit
import Photos

class ShelfCell: UITableViewCell {
    
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
            let diameter = thumbnailContainer.frame.height
            let targetSize = CGSize(width: diameter, height: diameter)
            
            for i in 0..<min(assets.count, thumbnailViews.count) {
                thumbnailViews[i].load(assets[i], targetSize: targetSize)
            }
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

class ShelfViewController: UITableViewController {

    private let reuseIdentifier = "ShelfCell"
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem.spaceItem(-12), UIBarButtonItem(image: IonIcons.imageWithIcon(ion_ios_plus_empty, size: 30, color: Color.blue), style: .Plain, target: self, action: "didTapAdd")]
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Edit", comment: ""), style: .Plain, target: self, action: "didTapEdit")
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AssetManager.sharedInstance.albums.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 127
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ShelfCell
        cell.update(AssetManager.sharedInstance.albums[indexPath.row])
        return cell
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        navigationController?.pushViewController(AlbumViewController.controller(), animated: true)
    }
}


// MARK: -

extension ShelfViewController {
    func didTapAdd() {
        
    }
    
    func didTapEdit() {
        
    }
}
