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
        if mediaSubtypes.contains(.photoLive) {
            components.append("Live photo")
        } else if mediaType == .image {
            components.append("Obrázek")
        } else if mediaType == .video {
            components.append("Video")
        }
        
        if isFavorite {
            components.append("Oblíbený")
        }
        
        if mediaSubtypes.contains(.photoDepthEffect) {
            components.append("Efekt hloubky")
        }
        if mediaSubtypes.contains(.photoPanorama) {
            components.append("Panorama")
        }
        if mediaSubtypes.contains(.photoScreenshot) {
            components.append("Snímek obrazovky")
        }
        if mediaSubtypes.contains(.videoHighFrameRate) {
            components.append("Zpomalené")
        }
        
        if pixelWidth > pixelHeight {
            components.append("Na šířku")
        } else {
            components.append("Na výšku")
        }
        
        if mediaType == .video {
            components.append(String(duration) + " vteřin")
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
