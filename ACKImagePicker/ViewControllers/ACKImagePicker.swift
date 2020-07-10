//
//  ACKImagePicker.swift
//  ACKImagePicker
//
//  Created by Lukáš Hromadník on 17/06/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import UIKit

/// View controller that enables users to select image from the user's media library
open class ACKImagePicker: UINavigationController {
    
    /// Called when user finished selecting images
    open var onImagesPicked: (([UIImage]) -> Void)? {
        get { rootController.onImagesPicked }
        set { rootController.onImagesPicked = newValue }
    }
    
    /// Maximum number of images that user can select
    open var maximumNumberOfImages: Int? {
        get { rootController.maximumNumberOfImages }
        set { rootController.maximumNumberOfImages = newValue }
    }
    
    private weak var rootController: ImagePickerViewController!
    
    convenience init() {
        let rootController = ImagePickerViewController()
        self.init(rootViewController: rootController)
        navigationBar.isTranslucent = false
        self.rootController = rootController
    }

}
