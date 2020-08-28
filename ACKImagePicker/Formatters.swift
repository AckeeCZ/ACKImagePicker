//
//  Formatters.swift
//  ACKImagePicker
//
//  Created by Lukáš Hromadník on 14/06/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import Foundation

enum Formatters {
    
    /// Duration formatter used for the accessibility
    static let duration: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .spellOut
        formatter.maximumUnitCount = 1
        return formatter
    }()
}
