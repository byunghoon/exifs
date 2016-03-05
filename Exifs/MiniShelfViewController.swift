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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        backgroundColor = Color.gray85
    }
    
    func update(album: Album) {
        if let asset = album.assets?.first {
            thumbnailView.load(asset, targetSize: thumbnailView.frame.size)
        }
        
        titleLabel.text = album.title
        
        countLabel.text = "\(album.assetCount)"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbnailView.cancelCurrentLoad()
    }
}

class MiniShelfViewController: UITableViewController {
    
    private let reuseIdentifier = "MiniShelfCell"
    
    var albums: [Album]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.backgroundColor = Color.gray85
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 110
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MiniShelfCell
        cell.update(albums[indexPath.row])
        return cell
    }
}
