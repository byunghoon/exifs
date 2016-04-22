//
//  AlbumRecord.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-04-03.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import Foundation
import CoreData

class AlbumRecord: NSManagedObject {
    
    @NSManaged var id: String
    @NSManaged var date: NSTimeInterval

    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        date = NSDate().timeIntervalSinceReferenceDate
    }
}
