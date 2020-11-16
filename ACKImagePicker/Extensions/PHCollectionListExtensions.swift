//nswift
//  ACKImagePickerExample
//
//  Created by Lukáš Hromadník on 14/02/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import Photos

extension PHCollectionList {
    func fetchAllAssets() -> PHFetchResult<PHAsset> {
        let collections = PHCollectionList.fetchCollections(in: self, options: nil)
        var identifiers: [String] = []
        collections.enumerateObjects { collection, index, _ in
            if let child = collection as? PHCollectionList {
                child.fetchAllAssets().enumerateObjects { asset, _, _ in
                    identifiers.append(asset.localIdentifier)
                }
            } else if let child = collection as? PHAssetCollection {
                PHAsset.fetchAssets(in: child, options: nil).enumerateObjects { asset, _, _ in
                    identifiers.append(asset.localIdentifier)
                }
            }
        }

        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        return PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: options)
    }
}
