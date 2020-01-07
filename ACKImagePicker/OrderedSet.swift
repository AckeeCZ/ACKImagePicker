//
//  OrderedSet.swift
//  ACKImagePicker
//
//  Created by Lukáš Hromadník on 21/02/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import Foundation

final class OrderedSet<Item> {
    private let storage = NSMutableOrderedSet()
    
    var count: Int { storage.count }
    
    func add(_ object: Item) {
        storage.add(object)
    }
    
    func remove(_ object: Item) {
        let index = storage.index(of: object)
        guard index != NSNotFound else { return }
        storage.removeObject(at: index)
    }
    
    func forEach(_ body: (Item) -> Void) {
        storage.forEach { body($0 as! Item) }
    }
}
