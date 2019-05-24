//
//  CollectionTableViewCell.swift
//  ACKImagePicker
//
//  Created by Lukáš Hromadník on 27/02/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import UIKit

final class CollectionTableViewCell: UITableViewCell {
    
    var assetIdentifier: String?
    
    var thumbImage: UIImage? {
        get { return thumbImageView.image }
        set { thumbImageView.image = newValue }
    }
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    private weak var thumbImageView: UIImageView!
    private weak var titleLabel: UILabel!
    
    // MARK: - Initializaiton
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Components setup
    
    private func setup() {
        let thumbImageView = UIImageView()
        thumbImageView.layer.cornerRadius = 3
        thumbImageView.clipsToBounds = true
        thumbImageView.contentMode = .scaleAspectFill
        thumbImageView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        contentView.addSubview(thumbImageView)
        thumbImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints([
            NSLayoutConstraint(item: thumbImageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 5),
            NSLayoutConstraint(item: thumbImageView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 15),
            NSLayoutConstraint(item: thumbImageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -5, priority: 999),
            NSLayoutConstraint(item: thumbImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44, priority: 999),
            NSLayoutConstraint(item: thumbImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44, priority: 999)
        ])
        self.thumbImageView = thumbImageView
        
        let titleLabel = UILabel()
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints([
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: thumbImageView, attribute: .trailing, multiplier: 1, constant: 15, priority: 999),
            NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -5)
        ])
        self.titleLabel = titleLabel
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbImage = nil
    }
    
    // MARK: - Selection
    
    private func updateSelection(_ isSelected: Bool, animated: Bool) {
        thumbImageView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        updateSelection(selected, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        updateSelection(highlighted, animated: animated)
    }
}
