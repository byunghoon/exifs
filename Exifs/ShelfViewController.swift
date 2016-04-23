//
//  ShelfViewController.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-07.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit
import Photos

class ShelfViewController: UITableViewController {

    private let reuseIdentifier = "ShelfCell"
    private let service = Service()
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return Theme.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem.spaceItem(-12))
        let image = IonIcons.imageWithIcon(ion_ios_plus_empty, iconColor: Theme.primaryColor, iconSize: 30, imageSize: CGSizeMake(30, 32))
        items.append(UIBarButtonItem(image: image.paddedImage(UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)), style: .Plain, target: self, action: #selector(didTapAdd)))
        navigationItem.rightBarButtonItems = items
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        service.mainShelf.addObserver(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        service.mainShelf.removeObserver(self)
    }
    
    func didTapAdd() {
        let controller = UIAlertController(title: "New Album", message: nil, preferredStyle: .Alert)
        controller.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Album Title"
        }
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Create", style: .Default, handler: { (action) in
            self.service.createAlbum(controller.textFields?.first?.text)
        }))
        presentViewController(controller, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return service.mainShelf.albums.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 127
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ShelfCell
        let album = service.mainShelf.albums[indexPath.row]
        let pinned = service.data.priorityCollectionIds(.Pinned).contains(album.id)
        cell.update(album, pinned: pinned)
        return cell
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let albumViewController = AlbumViewController.controller()
        albumViewController.service = service
        albumViewController.album = service.mainShelf.albums[indexPath.row]
        navigationController?.pushViewController(albumViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        var actions = [UITableViewRowAction]()
        
        let album = service.mainShelf.albums[indexPath.row]
        if album.type.subtype == .AlbumRegular {
            let deleteAction = UITableViewRowAction(style: .Destructive, title: NSLocalizedString("Delete", comment: ""), handler: { (action, indexPath) in
                let title = NSLocalizedString("This can't be undone. Your photos will still remain in Camera Roll.", comment: "")
                let controller = UIAlertController(title: title, message: nil, preferredStyle: .ActionSheet)
                controller.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .Destructive, handler: { (action) in
                    if let album = album.underlyingAssetCollection {
                        self.service.deleteAlbum(album)
                    }
                }))
                controller.addAction((UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil)))
                self.presentViewController(controller, animated: true, completion: nil)
            })
            deleteAction.backgroundColor = Color.gray60x
            actions.append(deleteAction)
        }
        
        let pinAction = UITableViewRowAction(style: .Normal, title: "Pin\nAlbum", handler: { (action, indexPath) in
            self.service.data.pinAlbum(album.id)
        })
        pinAction.backgroundColor = Color.blue
        actions.append(pinAction)
        
        return actions
    }
}

extension ShelfViewController: ShelfObserving {
    func shelfDidChange(rice: Rice) {
        dispatch_async(dispatch_get_main_queue()) {
            print("Shelf: \(rice)")
            
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
