//
//  PickerSelectionState.swift
//  ACKImagePicker
//
//  Created by Lukáš Hromadník on 07.07.18.
//  Copyright © 2018 Lukáš Hromadník. All rights reserved.
//

import Foundation

public protocol PickerSelectionState {
    func borderWidth(selected: Bool) -> CGFloat
    func borderColor(selected: Bool) -> UIColor
}

class DefaultPickerSeletionState: PickerSelectionState {
    
    func borderWidth(selected: Bool) -> CGFloat {
        return selected ? 2 : 0
    }
    
    func borderColor(selected: Bool) -> UIColor {
        return selected ? .red : .clear
    }

}
