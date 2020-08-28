//
//  PHAssetExtensions.swift
//  ACKImagePicker
//
//  Created by Lukáš Hromadník on 24/05/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import Foundation
import Photos

extension PHAsset {
    var accessibilityLabelText: String? {
        var components: [String] = []
        if #available(iOS 9.1, *), mediaSubtypes.contains(.photoLive) {
            components.append("asset.live_photo".localized())
        } else if mediaSubtypes.contains(.videoHighFrameRate) {
            components.append("asset.high_frame_rate".localized())
        } else if mediaSubtypes.contains(.videoTimelapse) {
            components.append("asset.timelapse".localized())
        } else if mediaType == .image {
            components.append("asset.image".localized())
        } else if mediaType == .video {
            components.append("asset.video".localized())
        }
        
        if isFavorite {
            components.append("asset.is_favorite".localized())
        }
        if #available(iOS 10.2, *), mediaSubtypes.contains(.photoDepthEffect) {
            components.append("asset.depth_effect".localized())
        }
        if mediaSubtypes.contains(.photoPanorama) {
            components.append("asset.panorama".localized())
        }
        if mediaSubtypes.contains(.photoScreenshot) {
            components.append("asset.screenshot".localized())
        }
        
        
        if pixelWidth > pixelHeight {
            components.append("asset.height".localized())
        } else {
            components.append("asset.width".localized())
        }
        
        if mediaType == .video, let duration = Formatters.duration.string(from: duration) {
            components.append(duration)
        }
        
        return components.joined(separator: ", ")
    }
    
    var accessibilityValueText: String? {
        guard let creationDate = creationDate else { return nil }
        let dateText = DateFormatter.localizedString(from: creationDate, dateStyle: .medium, timeStyle: .none)
        let hourComponents = Calendar.current.dateComponents([.hour, .minute], from: creationDate)
        if let hourText = DateComponentsFormatter.localizedString(from: hourComponents, unitsStyle: .spellOut) {
            return dateText + " " + hourText
        } else {
            return dateText
        }
    }
}
