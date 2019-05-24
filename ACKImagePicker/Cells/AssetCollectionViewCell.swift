//
//  AssetCollectionViewCell.swift
//  ACKImagePickerExample
//
//  Created by Lukáš Hromadník on 15/02/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import UIKit
import Photos

final class AssetCollectionViewCell: UICollectionViewCell {
    
    // Needed for correct asset to be loaded after request
    var assetIdentifier: String!
    var imageRequestID: PHImageRequestID?
    var asset: PHAsset? {
        didSet {
            setupAccessibility()
        }
    }
    
    var thumbnailImage: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }
    
    var livePhotoBadgeImage: UIImage? {
        get { return livePhotoBadgeImageView.image }
        set { livePhotoBadgeImageView.image = newValue }
    }
    
    override var isSelected: Bool {
        didSet {
            checkmarkView.isChecked = isSelected
        }
    }
    
    private weak var imageView: UIImageView!
    private weak var livePhotoBadgeImageView: UIImageView!
    private weak var checkmarkView: SSCheckMark!
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupAccessibility()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Components setup
    
    private func setup() {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.makeEdgesEqualToSuperview()
        self.imageView = imageView
        
        let livePhotoBadgeImageView = UIImageView()
        contentView.addSubview(livePhotoBadgeImageView)
        livePhotoBadgeImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints([
            NSLayoutConstraint(item: livePhotoBadgeImageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: livePhotoBadgeImageView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: livePhotoBadgeImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 28),
            NSLayoutConstraint(item: livePhotoBadgeImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 28),
        ])
        self.livePhotoBadgeImageView = livePhotoBadgeImageView
        
        let checkmarkView = SSCheckMark()
        checkmarkView.checkMarkColor = .blue
        contentView.addSubview(checkmarkView)
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints([
            NSLayoutConstraint(item: checkmarkView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: checkmarkView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: checkmarkView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 28),
            NSLayoutConstraint(item: checkmarkView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 28)
        ])
        self.checkmarkView = checkmarkView
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        livePhotoBadgeImageView.image = nil
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibility() {
        isAccessibilityElement = true

        accessibilityLabel = asset?.accessibilityLabelText
        if let creationDate = asset?.creationDate {
            let dateText = DateFormatter.localizedString(from: creationDate, dateStyle: .medium, timeStyle: .none)
            let hourComponents = Calendar.current.dateComponents([.hour, .minute], from: creationDate)
            if let hourText = DateComponentsFormatter.localizedString(from: hourComponents, unitsStyle: .spellOut) {
                accessibilityValue = dateText + " " + hourText
            } else {
                accessibilityValue = dateText
            }
        }
        accessibilityTraits = [.button]
    }
}

extension PHAsset {
    
    var accessibilityLabelText: String? {
        var components: [String] = []
        switch mediaType {
        case .image:
            components.append("Obrázek")
        case .video:
            components.append("Video")
        default: break
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
        if mediaSubtypes.contains(.photoLive) {
            components.append("Live photo")
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
    
}

