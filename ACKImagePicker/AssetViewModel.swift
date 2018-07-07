//
//  AssetViewModel.swift
//  Gallery
//
//  Created by Lukáš Hromadník on 05.07.18.
//  Copyright © 2018 Lukáš Hromadník. All rights reserved.
//

import Photos

final class AssetViewModel {
    let asset: PHAsset

    var identifier: PHImageRequestID?
    var isSelected = false
    
    // MARK: - Initialization
    
    init(asset: PHAsset) {
        self.asset = asset
    }
}
