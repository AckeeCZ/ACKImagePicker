//
//  OrderedSet.swift
//  ACKImagePicker
//
//  Created by Lukáš Hromadník on 21/02/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import Foundation

struct OrderedSet<Element>: CustomStringConvertible {
    private let storage = NSMutableOrderedSet()
    private var iterator = 0

    var count: Int { storage.count }
    
    var description: String {
        "OrderedSet [" + storage.map { String(describing: $0) }.joined(separator: ", ") + "]"
    }

    mutating func add(_ object: Element) {
        storage.add(object)
    }

    mutating func remove(_ object: Element) {
        let index = storage.index(of: object)
        guard index != NSNotFound else { return }
        storage.removeObject(at: index)
    }
}

extension OrderedSet: Sequence, IteratorProtocol {
    mutating func next() -> Element? {
        guard iterator < count else { return nil }
        
        defer { iterator += 1 }
        return storage[iterator] as? Element
    }
}
