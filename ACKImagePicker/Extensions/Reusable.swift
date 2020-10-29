//
//  Reusable.swift
//  ACKImagePicker
//
//  Created by Lukáš Hromadník on 24/05/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import UIKit

protocol Reusable { }

extension Reusable {
    static var reuseIdentifier: String {
        NSStringFromClass(self as! AnyObject.Type)
    }
}

extension UICollectionViewCell: Reusable { }
extension UITableViewCell: Reusable { }

extension UITableView {
    func dequeueCell<Cell>(for indexPath: IndexPath) -> Cell where Cell: UITableViewCell {
        register(Cell.self, forCellReuseIdentifier: Cell.reuseIdentifier)
        // swiftlint:disable:next force_cast
        return dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
    }
}

extension UICollectionView {
    func dequeueCell<Cell>(for indexPath: IndexPath) -> Cell where Cell: UICollectionViewCell {
        register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        // swiftlint:disable:next force_cast
        return dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
    }
}
