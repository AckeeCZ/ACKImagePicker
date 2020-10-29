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
    var imageRequestID: PHImageRequestID?
    var asset: PHAsset? {
        didSet {
            setupAccessibility()
        }
    }

    /// Block which is called as first  in `prepareForReuse` function (before all other actions)
    var prepareForReuseBlock: ((AssetCollectionViewCell) -> ())?

    var thumbnailImage: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }

    var livePhotoBadgeImage: UIImage? {
        get { livePhotoBadgeImageView.image }
        set { livePhotoBadgeImageView.image = newValue }
    }

    override var isSelected: Bool {
        didSet {
            checkmarkView.isChecked = isSelected
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            checkmarkView.checkMarkColor = tintColor
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

        prepareForReuseBlock?(self)

        imageRequestID = nil
        asset = nil
        thumbnailImage = nil
        livePhotoBadgeImage = nil
        prepareForReuseBlock = nil
    }

    // MARK: - Accessibility

    private func setupAccessibility() {
        isAccessibilityElement = true

        accessibilityLabel = asset?.accessibilityLabelText
        accessibilityValue = asset?.accessibilityValueText
        accessibilityTraits = [.button]
    }
}
