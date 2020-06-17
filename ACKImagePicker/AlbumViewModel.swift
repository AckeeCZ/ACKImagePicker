//
//  AlbumViewModel.swift
//  ACKImagePicker
//
//  Created by Lukáš Hromadník on 07/03/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import Photos
import UIKit

final class AlbumViewModel {
    
    var assetIdentifier: String?
    var image: UIImage?
    var onImage: ((UIImage?, String) -> Void)?
    
    private let collection: PHAssetCollection
    private let imageManager: PHImageManager
    
    
    // MARK: - Initialization
    
    init(collection: PHAssetCollection, imageManager: PHImageManager) {
        self.collection = collection
        self.imageManager = imageManager
        
        makeFetch()
    }
    
    // MARK: - Helpers
    
    private func makeFetch() {
        let options = PHFetchOptions()
        options.fetchLimit = 1
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssets(in: collection, options: options)
        if let firstAsset = result.firstObject {
            assetIdentifier = firstAsset.localIdentifier
            let size = CGSize(width: 50, height: 50)
            imageManager.requestImage(for: firstAsset, targetSize: size, contentMode: .aspectFill, options: nil) { [weak self] image, _ in
                self?.image = image
                self?.onImage?(image, firstAsset.localIdentifier)
            }
        }
    }
    
}
