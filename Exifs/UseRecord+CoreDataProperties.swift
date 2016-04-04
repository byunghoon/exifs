//
//  UseRecord+CoreDataProperties.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-04-03.
//  Copyright © 2016 Byunghoon. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension UseRecord {

    @NSManaged var localIdentifier: String
    @NSManaged var usedDate: NSDate

}
