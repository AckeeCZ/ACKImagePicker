//
//  AssetCollectionViewCell.swift
//  Gallery
//
//  Created by Lukáš Hromadník on 05.07.18.
//  Copyright © 2018 Lukáš Hromadník. All rights reserved.
//

import UIKit
import Photos

final class AssetCollectionViewCell: UICollectionViewCell {
    
    var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }
    
    var asset: PHAsset? {
        didSet {
            if let creationDate = asset?.creationDate {
                accessibilityLabel = AssetCollectionViewCell.dateFormatter.string(from: creationDate)
            }
            if let location = asset?.location {
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                    if let place = placemarks?.first {
                        var current = self?.accessibilityLabel ?? ""
                        if let name = place.name {
                            current += name
                        }
                        self?.accessibilityLabel = current
                    }
                }
            }
        }
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("ddMMyyyyHHmm")
        
        return formatter
    }()
    
    private weak var imageView: UIImageView!
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Components setup
    
    private func setup() {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isAccessibilityElement = true
        imageView.accessibilityTraits = UIAccessibilityTraitImage
        contentView.addSubview(imageView)
        contentView.addConstraints([
            NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0),
        ])
        self.imageView = imageView
    }

}

extension AssetCollectionViewCell {
    static let reuseIdentifier = "AssetCollectionViewCell"
}
