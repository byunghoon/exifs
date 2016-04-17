//
//  MiniShelfViewController.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-25.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit
import Photos

class MiniShelfCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailView: ThumbnailView!
    @IBOutlet weak var overlayLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        overlayLabel.font = IonIcons.fontWithSize(36)
        overlayLabel.text = ""
        overlayLabel.layer.cornerRadius = 30
        thumbnailView.layer.cornerRadius = 30
    }
    
    func update(album: Album) {
        if let asset = album.assets.first {
            thumbnailView.load(asset, targetSize: thumbnailView.frame.size)
        }
        
        let att = NSMutableAttributedString(string: "\(album.title) \(album.assetCount)", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(12), NSForegroundColorAttributeName: Color.black])
        att.addAttribute(NSForegroundColorAttributeName, value: Color.gray60, range: (att.string as NSString).rangeOfString("\(album.assetCount)"))
        titleLabel.attributedText = att
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbnailView.cancelCurrentLoad()
    }
}

class MiniShelfViewController: UITableViewController {
    
    private let reuseIdentifier = "MiniShelfCell"
    
    @IBOutlet weak var headerLabel: UILabel!
    
    var service: Service!
    var excludedAlbum: Album?
    var shelf: Shelf!
    
    deinit {
        shelf.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerLabel.textColor = Color.gray60
        
        var excludedIds = [String]()
        if let id = excludedAlbum?.id {
            excludedIds.append(id)
        }
        shelf = Shelf(photos: service.photos, data: service.data, collectionTypes: [CollectionType(type: .Album, subtype: .AlbumRegular)], priorityType: .RecentlyUsed, excludedIds: excludedIds)
        shelf.addObserver(self)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shelf.albums.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 105
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MiniShelfCell
        cell.update(shelf.albums[indexPath.row])
        return cell
    }
}

extension MiniShelfViewController: ShelfObserving {
    func shelfDidChange(rice: Rice) {
        dispatch_async(dispatch_get_main_queue()) {
            print("Mini shelf: \(rice)")
            
            if !rice.hasIncrementalChanges {
                return self.tableView.reloadData()
            }
            
            self.tableView.beginUpdates()
            if let indexSet = rice.removedIndexes {
                self.tableView.deleteRowsAtIndexPaths(indexSet.toIndexPaths(), withRowAnimation: .None)
            }
            if let indexSet = rice.insertedIndexes {
                self.tableView.insertRowsAtIndexPaths(indexSet.toIndexPaths(), withRowAnimation: .None)
            }
            if let indexSet = rice.changedIndexes {
                self.tableView.reloadRowsAtIndexPaths(indexSet.toIndexPaths(), withRowAnimation: .None)
            }
            rice.enumerateMovesWithBlock?({ (before, after) in
                let from = NSIndexPath(forRow: before, inSection: 0)
                let to = NSIndexPath(forRow: after, inSection: 0)
                self.tableView.moveRowAtIndexPath(from, toIndexPath: to)
            })
            self.tableView.endUpdates()
        }
    }
}
