//
//  Localization.swift
//  ACKImagePicker
//
//  Created by Lukáš Hromadník on 17/06/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import Foundation

extension String {
    
    func localized(withComment comment: String = "") -> String {
        return NSLocalizedString(self, bundle: Bundle(for: BundleToken.self), comment: comment)
    }
    
}
