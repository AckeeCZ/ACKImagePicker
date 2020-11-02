//
//  ImageCell.swift
//  ACKImagePickerExample
//
//  Created by Lukáš Hromadník on 29/10/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    static let reuseIdentifier = "ImageCell"
    
    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }
    
    private weak var imageView: UIImageView!
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        let imageView = UIImageView(frame: contentView.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        self.imageView = imageView
    }
}
