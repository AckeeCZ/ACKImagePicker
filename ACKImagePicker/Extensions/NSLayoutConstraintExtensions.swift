//
//  NSLayoutConstraintExtensions.swift
//  ACKImagePicker
//
//  Created by Lukáš Hromadník on 24/05/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    
    /// Convenient initializer with priority
    convenience init(item view1: Any, attribute attr1: NSLayoutConstraint.Attribute, relatedBy relation: NSLayoutConstraint.Relation, toItem view2: Any?, attribute attr2: NSLayoutConstraint.Attribute, multiplier: CGFloat, constant c: CGFloat, priority p: Float) {
        self.init(item: view1, attribute: attr1, relatedBy: relation, toItem: view2, attribute: attr2, multiplier: multiplier, constant: c)
        priority = UILayoutPriority(rawValue: p)
    }
}
