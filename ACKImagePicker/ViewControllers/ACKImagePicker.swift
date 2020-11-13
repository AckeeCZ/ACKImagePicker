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

    /// Tint color used in navigation bar, check mark and progress
    open var tintColor: UIColor? {
        get { navigationBar.tintColor }
        set { navigationBar.tintColor = newValue }
    }

    private weak var rootController: ImagePickerViewController!

    // MARK: - Initialization

    convenience init() {
        let rootController = ImagePickerViewController()
        self.init(rootViewController: rootController)

        // on iOS 10 we have trouble with `UINavigationBar` covering list of photos
        // and this is the simplest solution
        // https://user-images.githubusercontent.com/3148214/87172417-80530080-c2d4-11ea-82bb-914f0f8419ce.png
        if #available(iOS 11, *) {
            navigationBar.isTranslucent = true
        } else {
            navigationBar.isTranslucent = false
        }

        self.rootController = rootController
    }
}
