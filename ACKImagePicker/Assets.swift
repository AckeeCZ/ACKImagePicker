//
//  Assets.swift
//  ACKImagePicker
//
//  Created by Lukáš Hromadník on 29/10/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import UIKit

internal final class BundleToken { }

enum Assets: String {
    case animated
    case burts
    case cameraRoll = "camera_roll"
    case favourites
    case hidden
    case livePhotos = "live_photos"
    case longExposure = "long_exposure"
    case panoramas
    case portrait
    case random
    case recentlyAdded = "recently_added"
    case recentlyDeleted = "recently_deleted"
    case screenshots
    case selfies
    case sloMo = "slo-mo"
    case timelapse = "time-lapse"
    case videos

    // TODO: Remove !
    var image: UIImage! {
        UIImage(named: rawValue, in: Bundle(for: BundleToken.self), compatibleWith: nil)
    }
}
