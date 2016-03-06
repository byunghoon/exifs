//
//  MiniShelfViewController.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-25.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit

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
        if let asset = album.assets?.first {
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
    
    var albums: [Album]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerLabel.textColor = Color.gray60
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 105
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MiniShelfCell
        cell.update(albums[indexPath.row])
        return cell
    }
}
