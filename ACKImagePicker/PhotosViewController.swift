//
//  PhotosViewController.swift
//  Gallery
//
//  Created by Lukáš Hromadník on 04.07.18.
//  Copyright © 2018 Lukáš Hromadník. All rights reserved.
//

import UIKit
import Photos

final public class PhotosViewController: UIViewController {
    
    /// Number of columns
    public var numberOfColumns: CGFloat = 3
    
    /// Spacing between item in a row and between rows
    public var itemSpacing: CGFloat = 2
    
    /// Maximum number of selected images, `nil` for no limit
    public var limit: Int? = 3
    
    /// Completion handler when picker fetches all the selected images
    public var onImagesPicked: (([UIImage]) -> Void)?
    
    /// Entity which localizes the title of the controller
    public var localization = LocalizationStrings()
    
    /// Entity which handles selection state of the photo cell
    public var selectionState: PickerSelectionState = DefaultPickerSeletionState()
    
    private weak var activityIndicator: UIActivityIndicatorView!
    private weak var collectionView: UICollectionView!
    
    private var assets: [AssetViewModel] = [] {
        didSet {
            guard !assets.isEmpty else { return }
            collectionView.isHidden = false
            activityIndicator.stopAnimating()
            collectionView.reloadData()
        }
    }
    
    private var numberOfSelectedImages: Int {
        return assets.filter { $0.isSelected }.count
    }
    
    // MARK: - Controller lifecycle
    
    override public func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.hidesWhenStopped = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        view.addConstraints([
            NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        ])
        self.activityIndicator = activityIndicator
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = itemSpacing
        layout.minimumLineSpacing = itemSpacing
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.isHidden = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        view.addConstraints([
            NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
        ])
        self.collectionView = collectionView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        updateTitle()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarButtonTapped(_:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBarButtonTapped(_:)))
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(AssetCollectionViewCell.self, forCellWithReuseIdentifier: AssetCollectionViewCell.reuseIdentifier)
        
        activityIndicator.startAnimating()
        
        fetchAssets()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        // On the very first attempt the view is loaded before the user gives the consent
        if assets.isEmpty {
            fetchAssets()
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func doneBarButtonTapped(_ sender: UIBarButtonItem) {
        let manager = PHImageManager.default()
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true
        // Not sure if synchronous is the right way to do it
        options.isSynchronous = true
        
        var images: [UIImage] = []
        assets.filter { $0.isSelected }.forEach { viewModel in
            manager.requestImage(for: viewModel.asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options) { result, info in
                guard let image = result else { print(info ?? [:]); return }
                images.append(image)
            }
        }
        
        onImagesPicked?(images)
    }
    
    @objc
    private func cancelBarButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    // MARK: - Helpers
    
    private func fetchAssets() {
        let cachingImageManager = PHCachingImageManager()
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        let results = PHAsset.fetchAssets(with: .image, options: options)
        var assets: [PHAsset] = []
        results.enumerateObjects { object, _, _ in
            assets.append(object)
        }
        self.assets = assets.map(AssetViewModel.init)
        
        cachingImageManager.startCachingImages(for: assets, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil)
    }
    
    private func updateTitle() {
        if let limit = limit, let titleWithLimit = localization.titleWithLimit {
            navigationItem.title = String(format: titleWithLimit, numberOfSelectedImages, limit)
        } else if let titleWithoutLimit = localization.titleWithoutLimit {
            navigationItem.title = String(format: titleWithoutLimit, numberOfSelectedImages)
        } else {
            navigationItem.title = localization.title
        }
    }
    
}

extension PhotosViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssetCollectionViewCell.reuseIdentifier, for: indexPath) as! AssetCollectionViewCell
        let viewModel = assets[indexPath.row]

        cell.asset = viewModel.asset
        
        let manager = PHImageManager.default()
        
        if let identifier = viewModel.identifier, identifier != 0 {
            manager.cancelImageRequest(identifier)
        }
        
        let targetSize = self.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: indexPath)
        viewModel.identifier = manager.requestImage(for: viewModel.asset, targetSize: targetSize, contentMode: .aspectFill, options: nil) { result, _ in
            cell.image = result
        }
        
        cell.layer.borderWidth = selectionState.borderWidth(selected: viewModel.isSelected)
        cell.layer.borderColor = selectionState.borderColor(selected: viewModel.isSelected).cgColor
        
        return cell
    }
    
}

extension PhotosViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewModel = assets[indexPath.row]
        
        if viewModel.isSelected {
            viewModel.isSelected = false
        } else if limit == nil, !viewModel.isSelected {
            viewModel.isSelected = true
        } else if let limit = limit, !viewModel.isSelected, numberOfSelectedImages < limit {
            viewModel.isSelected = true
        }
        
        updateTitle()
        collectionView.reloadItems(at: [indexPath])
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.size.width - (numberOfColumns - 1) * itemSpacing
        let itemWidth = width / numberOfColumns
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
}
