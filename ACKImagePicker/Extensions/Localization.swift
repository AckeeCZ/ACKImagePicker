//
//  Localization.swift
//  ACKImagePicker
//
//  Created by Lukáš Hromadník on 17/06/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import Foundation

extension String {
    /// Uses the string as a localization key
    ///
    /// - Returns: Localized value for the given key
    func localized(withComment comment: String = "") -> String {
        NSLocalizedString(self, bundle: Bundle(for: BundleToken.self), comment: comment)
    }
}
