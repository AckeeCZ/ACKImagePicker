//
//  Localization.swift
//  ACKImagePicker
//
//  Created by Lukáš Hromadník on 17/06/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import Foundation

extension Bundle {
    
    private static let bundleID = "cz.ackee.enterprise.ACKImagePicker"
    
    static var module: Bundle {
        return Bundle(identifier: bundleID) ?? .main
    }
    
}

extension String {
    
    func localized(withComment comment: String = "") -> String {
        return NSLocalizedString(self, bundle: Bundle.module, comment: comment)
    }
    
}
