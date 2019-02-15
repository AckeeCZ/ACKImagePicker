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

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

enum ScreenState<T> {
    case loading
    case data(T)
    case noData
    case error
}

final class ACKPhotosViewController: UIViewController {
    
    var numberOfColumns: CGFloat = 3
    
    var state: ScreenState<PHFetchResult<PHAsset>> = .loading {
        didSet {
            updateState()
        }
    }
    
    private let imageManager = PHCachingImageManager()
    private var thumbnailSize: CGSize!
    private var previousPreheatRect = CGRect.zero
    
    private var fetchResult: PHFetchResult<PHAsset>?

    private weak var collectionView: UICollectionView!
    private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Initialization
    
    init(assetCollection: PHAssetCollection) {
        super.init(nibName: nil, bundle: nil)

        let fetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
        state = .data(fetchResult)
    }
    
    init(collectionList: PHCollectionList) {
        super.init(nibName: nil, bundle: nil)
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            let fetchResult = collectionList.fetchAllAssets()
            DispatchQueue.main.async { [weak self] in
                self?.state = .data(fetchResult)
            }
        }
    }
    
    init(fetchResult: PHFetchResult<PHAsset>) {
        super.init(nibName: nil, bundle: nil)
        
        self.fetchResult = fetchResult
        self.state = .data(fetchResult)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    // MARK: - Controller lifecycle
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        ])
        self.activityIndicator = activityIndicator
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        let width = ((view.bounds.width - layout.minimumInteritemSpacing * numberOfColumns) / numberOfColumns).rounded(.towardZero)
        let cellSize = CGSize(width: width, height: width)
        layout.itemSize = cellSize
        layout.minimumLineSpacing = (view.bounds.width - numberOfColumns * width) / (numberOfColumns - 1)
        
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        view.addSubview(collectionView)
        collectionView.makeEdgesEqualToSuperview()
        self.collectionView = collectionView
        
        updateState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetCachedAssets()
        
        PHPhotoLibrary.shared().register(self)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(GridViewCell.self, forCellWithReuseIdentifier: GridViewCell.identifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        updateCachedAssets()
    }
    
    private func updateState() {
        switch state {
        case .loading:
            activityIndicator.startAnimating()
            collectionView.isHidden = true
        case .data:
            activityIndicator.stopAnimating()
            collectionView.reloadData()
            collectionView.isHidden = false
        default:
            break
        }
    }
    
    // MARK: Asset Caching
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded, view.window != nil, let fetchResult = fetchResult else { return }
        
        // The window you prepare ahead of time is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start and stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { collectionView.indexPathsForElements(in: $0) }
            .map { fetchResult.object(at: $0.item) }
        let removedAssets = removedRects
            .flatMap { collectionView.indexPathsForElements(in: $0) }
            .map { fetchResult.object(at: $0.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        
        // Store the computed rectangle for future comparison.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY, width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY, width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY, width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY, width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }

}

extension ACKPhotosViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let asset = fetchResult?.object(at: indexPath.item) else { assertionFailure(); return UICollectionViewCell() }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridViewCell.identifier, for: indexPath) as! GridViewCell
        
        // Add a badge to the cell if the PHAsset represents a Live Photo.
        if asset.mediaSubtypes.contains(.photoLive) {
            cell.livePhotoBadgeImage = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
        }
        
        // Request an image for the asset from the PHCachingImageManager.
        cell.assetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { image, _ in
            // UIKit may have recycled this cell by the handler's activation time.
            // Set the cell's thumbnail image only if it's still showing the same asset.
            guard cell.assetIdentifier == asset.localIdentifier else { return }
            cell.thumbnailImage = image
        }
        return cell
    }
}
    
extension ACKPhotosViewController: UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }

}

// MARK: PHPhotoLibraryChangeObserver
extension ACKPhotosViewController: PHPhotoLibraryChangeObserver {
   
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let fetchResult = fetchResult, let changes = changeInstance.changeDetails(for: fetchResult) else { return }

        // Change notifications may originate from a background queue.
        // As such, re-dispatch execution to the main queue before acting
        // on the change, so you can update the UI.
        DispatchQueue.main.sync { [weak self] in
           
            // Hang on to the new fetch result.
            self?.fetchResult = changes.fetchResultAfterChanges
            
            // If we have incremental changes, animate them in the collection view.
            if changes.hasIncrementalChanges {
                guard let collectionView = self?.collectionView else { fatalError() }
            
                // Handle removals, insertions, and moves in a batch update.
                collectionView.performBatchUpdates({
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        collectionView.deleteItems(at: removed.map { IndexPath(item: $0, section: 0) })
                    }
                    if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                        collectionView.insertItems(at: inserted.map { IndexPath(item: $0, section: 0) })
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0), to: IndexPath(item: toIndex, section: 0))
                    }
                })
                
                // We are reloading items after the batch update since `PHFetchResultChangeDetails.changedIndexes` refers to
                // items in the *after* state and not the *before* state as expected by `performBatchUpdates(_:completion:)`.
                if let changed = changes.changedIndexes, !changed.isEmpty {
                    collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                }
            } else {
                
                // Reload the collection view if incremental changes are not available.
                collectionView?.reloadData()
            }
            
            resetCachedAssets()
        }
    }

}

final class GridViewCell: UICollectionViewCell {
    
    static let identifier = "GridViewCell"
    
    // Needed for correct asset to be loaded after request
    var assetIdentifier: String!
    
    var thumbnailImage: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }
    
    var livePhotoBadgeImage: UIImage? {
        get { return livePhotoBadgeImageView.image }
        set { livePhotoBadgeImageView.image = newValue }
    }

    private weak var imageView: UIImageView!
    private weak var livePhotoBadgeImageView: UIImageView!
    
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
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
        livePhotoBadgeImageView.image = nil
    }
}
