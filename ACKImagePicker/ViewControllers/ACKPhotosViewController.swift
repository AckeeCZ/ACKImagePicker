//
//  ACKPhotosViewController.swift
//  ACKImagePickerExample
//
//  Created by Lukáš Hromadník on 13/02/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

enum ScreenState {
    case loading
    case data
    case noData
}

final class ACKPhotosViewController: UIViewController {
    
    var numberOfColumns: CGFloat = 4
    
    weak var delegate: ACKImagePickerDelegate?
    
    private var state: ScreenState = .loading {
        didSet {
            updateState()
        }
    }
    
    private var selectedImages: OrderedSet<PHAsset> = .init()
    
    private let imageManager = PHCachingImageManager()
    private var thumbnailSize = CGSize.zero
    private var previousPreheatRect = CGRect.zero
    
    private var fetchResult: PHFetchResult<PHAsset>?

    private weak var collectionView: UICollectionView!
    private weak var activityIndicator: UIActivityIndicatorView!
    private weak var emptyLabel: UILabel!
    
    // MARK: - Initialization
    
    init(assetCollection: PHAssetCollection) {
        super.init(nibName: nil, bundle: nil)
        
        self.title = assetCollection.localizedTitle
        
        // Fetch only photos
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        
        self.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
        
        self.state = fetchResult?.count == 0 ? .noData : .data
    }
    
    init(collectionList: PHCollectionList) {
        super.init(nibName: nil, bundle: nil)
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            let fetchResult = collectionList.fetchAllAssets()
            DispatchQueue.main.async { [weak self] in
                self?.fetchResult = fetchResult
                self?.state = fetchResult.count == 0 ? .noData : .data
            }
        }
    }
    
    init(fetchResult: PHFetchResult<PHAsset>) {
        super.init(nibName: nil, bundle: nil)

        self.fetchResult = fetchResult
        self.state = fetchResult.count == 0 ? .noData : .data
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Controller lifecycle
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.makeCenterEqualToSuperview()
        self.activityIndicator = activityIndicator
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        let width = ((view.bounds.width - layout.minimumInteritemSpacing * numberOfColumns) / numberOfColumns).rounded(.towardZero)
        let cellSize = CGSize(width: width, height: width)
        layout.itemSize = cellSize
        layout.minimumLineSpacing = (view.bounds.width - numberOfColumns * width) / (numberOfColumns - 1)
        
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.allowsMultipleSelection = true
        view.addSubview(collectionView)
        collectionView.makeEdgesEqualToSuperview()
        self.collectionView = collectionView
        
        let emptyLabel = UILabel()
        emptyLabel.font = UIFont.preferredFont(forTextStyle: .body)
        emptyLabel.text = "photos.empty".localized()
        view.addSubview(emptyLabel)
        emptyLabel.makeCenterEqualToSuperview()
        self.emptyLabel = emptyLabel
        
        updateState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "photos.button.select".localized(), style: .plain, target: self, action: #selector(selectBarButtonTapped(_:)))
        
        updateSelection()
    }
    
    // MARK: - Actions
    
    @objc
    private func selectBarButtonTapped(_ sender: UIBarButtonItem) {
        delegate?.didSelectPhotos(selectedImages)
    }
    
    // MARK: - Helpers
    
    private func updateState() {
        switch state {
        case .loading:
            activityIndicator.startAnimating()
            collectionView.isHidden = true
            emptyLabel.isHidden = true
        case .data:
            activityIndicator.stopAnimating()
            emptyLabel.isHidden = true
            collectionView.isHidden = false
            collectionView.reloadData()
        case .noData:
            activityIndicator.stopAnimating()
            collectionView.isHidden = true
            emptyLabel.isHidden = false
        }
    }
    
    private func updateSelection() {
        let title = "photos.selected".localized() + " " + String(selectedImages.count)
        if let maxNumberOfImages = delegate?.maximumNumberOfSelectedImages() {
            navigationItem.title = title + " / " + String(maxNumberOfImages)
        } else {
            navigationItem.title = title
        }
        navigationItem.rightBarButtonItem?.isEnabled = selectedImages.count > 0
    }
}

extension ACKPhotosViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let asset = fetchResult?.object(at: indexPath.item) else { assertionFailure(); return UICollectionViewCell() }
        
        let cell: AssetCollectionViewCell = collectionView.dequeueCell(for: indexPath)
        
        // Add a badge to the Live Photo
        if #available(iOS 9.1, *), asset.mediaSubtypes.contains(.photoLive) {
            cell.livePhotoBadgeImage = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
        }
        
        // Set identifier for the image completion, needed because of the reuse
        cell.assetIdentifier = asset.localIdentifier
        cell.imageRequestID = imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { [weak cell] image, _ in
            guard cell?.assetIdentifier == asset.localIdentifier else { return }
            cell?.asset = asset
            cell?.thumbnailImage = image
            cell?.imageRequestID = nil
        }
        
        return cell
    }
}

extension ACKPhotosViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? AssetCollectionViewCell else { return }
        
        if let imageRequestID = cell.imageRequestID {
            imageManager.cancelImageRequest(imageRequestID)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let object = fetchResult?.object(at: indexPath.item) else { assertionFailure(); return }
        
        if let maxNumberOfImages = delegate?.maximumNumberOfSelectedImages(), selectedImages.count >= maxNumberOfImages {
            collectionView.deselectItem(at: indexPath, animated: false)
            return
        }
        
        selectedImages.add(object)
        updateSelection()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let object = fetchResult?.object(at: indexPath.item) else { assertionFailure(); return }
        
        selectedImages.remove(object)
        updateSelection()
    }
}
