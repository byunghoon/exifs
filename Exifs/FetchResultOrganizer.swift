//
//  FetchResultOrganizer.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-09.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import Photos

struct FetchResultOrganizer<T: Hashable> {
    private var fetchResult: PHFetchResult
    
    // Use Array for now to respect original ordering in fetchResult;
    // To be replaced with Set when there is any performance issue.
    private var allItems: Array<T>
    
    private(set) var orderedItems: Array<T>
    
    init(fetchResult: PHFetchResult) {
        self.fetchResult = fetchResult
        
        allItems = []
        for i in 0..<fetchResult.count {
            if let item = fetchResult[i] as? T {
                allItems.append(item)
            }
        }
        
        orderedItems = []
    }
    
    mutating func appendResults(predicate: (T) -> Bool) {
        for item in allItems.filter(predicate) {
            allItems.removeAtIndex(allItems.indexOf(item)!)
            orderedItems.append(item)
        }
    }
}
