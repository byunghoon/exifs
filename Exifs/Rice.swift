//
//  Rice.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-04-02.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import Foundation
import Photos

struct Rice {
    let hasIncrementalChanges: Bool
    
    let removedIndexes: NSIndexSet?
    let insertedIndexes: NSIndexSet?
    let changedIndexes: NSIndexSet?
    let enumerateMovesWithBlock: (((Int, Int) -> Void) -> Void)?
    
    let removedObjects: [AnyObject]?
    let insertedObjects: [AnyObject]?
    let changedObjects: [AnyObject]?
    
    static func LargeChangesRice() -> Rice {
        return Rice(hasIncrementalChanges: false, removedIndexes: nil, insertedIndexes: nil, changedIndexes: nil, enumerateMovesWithBlock: nil, removedObjects: nil, insertedObjects: nil, changedObjects: nil)
    }
    
    static func RiceFromFetchResultChangeDetails(details: PHFetchResultChangeDetails) -> Rice {
        return Rice(
            hasIncrementalChanges: details.hasIncrementalChanges,
            removedIndexes: details.removedIndexes,
            insertedIndexes: details.insertedIndexes,
            changedIndexes: details.changedIndexes,
            enumerateMovesWithBlock: details.enumerateMovesWithBlock,
            removedObjects: details.removedObjects,
            insertedObjects: details.insertedObjects,
            changedObjects: details.changedObjects
        )
    }
}

extension Rice: CustomDebugStringConvertible {
    var debugDescription: String {
        get {
            if !hasIncrementalChanges {
                return "large changes"
            }
            
            var str = ""
            if let indexSet = removedIndexes {
                str += "removed(\(indexSet.toString())) "
            }
            if let indexSet = insertedIndexes {
                str += "inserted(\(indexSet.toString())) "
            }
            if let indexSet = changedIndexes {
                str += "changed(\(indexSet.toString())) "
            }
            if let block = enumerateMovesWithBlock {
                str += "moved("
                block({ (before, after) in
                    str += "{\(before) > \(after)} "
                })
                str += ")"
            }
            return str
        }
    }
}

extension NSIndexSet {
    func toIndexPaths(section: Int = 0) -> [NSIndexPath] {
        var indexPaths = [NSIndexPath]()
        enumerateIndexesUsingBlock { (i, _) in
            indexPaths.append(NSIndexPath(forRow: i, inSection: section))
        }
        return indexPaths
    }
    
    private func toString() -> String {
        var indexes = [String]()
        enumerateIndexesUsingBlock { (i, _) in
            indexes.append("\(i)")
        }
        return indexes.joinWithSeparator(", ")
    }
}
