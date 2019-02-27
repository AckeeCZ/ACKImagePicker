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
}
