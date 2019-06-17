//
//  ACKImagePicker.swift
//  ACKImagePicker
//
//  Created by Lukáš Hromadník on 17/06/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import Foundation

open class ACKImagePicker: UINavigationController {
    
    open var onImagesPicked: (([UIImage]) -> Void)? {
        get { return rootController.onImagesPicked }
        set { rootController.onImagesPicked = newValue }
    }
    
    open var maximumNumberOfImages: Int? {
        get { return rootController.maximumNumberOfImages }
        set { rootController.maximumNumberOfImages = newValue }
    }
    
    private weak var rootController: ImagePickerViewController!
    
    convenience init() {
        let rootController = ImagePickerViewController()
        self.init(rootViewController: rootController)
        self.rootController = rootController
    }

}
