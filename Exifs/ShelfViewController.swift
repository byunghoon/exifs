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
    
    func update(album: PHAssetCollection) {
        titleLabel.text = album.name
        
        var dateString = ""
        if let earliestDate = album.assets.last?.creationDate, latestDate = album.assets.first?.creationDate {
            if earliestDate.isEqualToDate(latestDate) {
                dateString = "  ·  \(earliestDate.formattedString())"
            } else {
                dateString = "  ·  \(earliestDate.formattedString()) to \(latestDate.formattedString())"
            }
        }
        detailLabel.text = "\(album.exactCount)\(dateString)"
        
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

class ShelfViewController: UITableViewController {

    private let reuseIdentifier = "ShelfCell"
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return Theme.statusBarStyle
    }
    
    deinit {
        DataManager.sharedInstance.photos.pinnedFirstShelf.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("New", comment: ""), style: .Plain, target: self, action: #selector(ShelfViewController.didTapAdd))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Edit", comment: ""), style: .Plain, target: self, action: #selector(ShelfViewController.didTapEdit))
        
        DataManager.sharedInstance.photos.pinnedFirstShelf.addObserver(self)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.sharedInstance.getAlbumsPinnedFirst().count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 127
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ShelfCell
        cell.update(DataManager.sharedInstance.getAlbumsPinnedFirst()[indexPath.row])
        return cell
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let albumViewController = AlbumViewController.controller()
        albumViewController.album = DataManager.sharedInstance.getAlbumsPinnedFirst()[indexPath.row]
        navigationController?.pushViewController(albumViewController, animated: true)
    }
}

extension ShelfViewController {
    func didTapAdd() {
        
    }
    
    func didTapEdit() {
        
    }
}

extension ShelfViewController: ShelfObserving {
    func shelfDidChange(changes: Rice) {
        print("Shelf: \(changes)")
        
        if !changes.hasIncrementalChanges {
            return tableView.reloadData()
        }
        
        tableView.beginUpdates()
        if let indexSet = changes.removedIndexes {
            self.tableView.deleteRowsAtIndexPaths(indexSet.toIndexPaths(), withRowAnimation: .None)
        }
        if let indexSet = changes.insertedIndexes {
            self.tableView.insertRowsAtIndexPaths(indexSet.toIndexPaths(), withRowAnimation: .None)
        }
        if let indexSet = changes.changedIndexes {
            self.tableView.reloadRowsAtIndexPaths(indexSet.toIndexPaths(), withRowAnimation: .None)
        }
        changes.enumerateMovesWithBlock?({ (before, after) in
            let from = NSIndexPath(forRow: before, inSection: 0)
            let to = NSIndexPath(forRow: after, inSection: 0)
            self.tableView.moveRowAtIndexPath(from, toIndexPath: to)
        })
        tableView.endUpdates()
    }
}
