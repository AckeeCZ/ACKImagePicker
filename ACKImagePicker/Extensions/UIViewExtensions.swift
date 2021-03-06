//
//  UIViewExtensions.swift
//  ACKImagePickerExample
//
//  Created by Lukáš Hromadník on 13/02/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import UIKit

extension UIView {
    func makeEdgesEqualToSuperview(insets: UIEdgeInsets = .zero) {
        guard let superview = superview else { assertionFailure(); return }
        translatesAutoresizingMaskIntoConstraints = false

        superview.addConstraints([
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1, constant: insets.top),
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: insets.left),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: -insets.right),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: -insets.bottom),
        ])
    }

    func makeCenterEqualToSuperview() {
        guard let superview = superview else { assertionFailure(); return }
        translatesAutoresizingMaskIntoConstraints = false

        superview.addConstraints([
            NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: superview, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: superview, attribute: .centerY, multiplier: 1, constant: 0)
        ])
    }
}
