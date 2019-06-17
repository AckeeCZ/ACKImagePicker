//
//  ACKPhotosViewController.swift
//  ACKImagePickerExample
//
//  Created by Lukáš Hromadník on 13/02/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import UIKit
import Photos

open class ImagePickerViewController: UIViewController {
    
    private let imageManager = PHImageManager()
    
    enum Section: Int {
        case allPhotos
        case smartAlbums
        case userCollections
        
        var title: String? {
            switch self {
            case .allPhotos: return nil
            case .smartAlbums: return "picker.section.smart_albums".localized()
            case .userCollections: return "picker.section.albums".localized()
            }
        }
    }
    
    open var onImagesPicked: (([UIImage]) -> Void)?
    open var maximumNumberOfImages: Int? = nil
    
    private let sections: [Section] = [.allPhotos, .smartAlbums, .userCollections]
    private var albumViewModels: [IndexPath: AlbumViewModel] = [:]
    
    private var allPhotos: PHFetchResult<PHAsset>!
    private var smartAlbums: PHFetchResult<PHAssetCollection>!
    private var userCollections: PHFetchResult<PHCollection>!
    
    private weak var tableView: UITableView!
    
    // MARK: - Controller lifecycle
    
    override open func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        view.addSubview(tableView)
        tableView.makeEdgesEqualToSuperview()
        self.tableView = tableView
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "picker.title".localized()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBarButtonTapped(_:)))
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        
        tableView.register(CollectionTableViewCell.self, forCellReuseIdentifier: CollectionTableViewCell.reuseIdentifier)
        
        PHPhotoLibrary.shared().register(self)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.indexPathsForSelectedRows?.forEach { tableView.deselectRow(at: $0, animated: animated) }
    }
    
    // MARK: - Deinit
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    // MARK: - Actions
    
    @objc
    private func cancelBarButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    // MARK: - Helpers
    
    private func reloadSection(_ section: Section) {
        guard let index = sections.enumerated().first(where: { _, element in element == section })?.offset else { return }
        tableView.reloadSections(IndexSet(integer: index), with: .automatic)
    }
    
}

extension ImagePickerViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .allPhotos: return 1
        case .smartAlbums: return smartAlbums.count
        case .userCollections: return userCollections.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .allPhotos:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "picker.all_photos".localized()
            cell.accessoryType = .disclosureIndicator
            return cell
            
        case .smartAlbums:
            let collection = smartAlbums.object(at: indexPath.row)
            
            let cell: CollectionTableViewCell = tableView.dequeueCell(for: indexPath)
            cell.title = collection.localizedTitle
            cell.accessoryType = .disclosureIndicator
            
            // Initialize new viewModel which performs the fetch
            if albumViewModels[indexPath] == nil {
                albumViewModels[indexPath] = AlbumViewModel(collection: collection, imageManager: imageManager)
            }
            
            let albumViewModel = albumViewModels[indexPath]
            cell.thumbImage = albumViewModel?.image
            cell.assetIdentifier = albumViewModel?.assetIdentifier
            albumViewModel?.onImage = { [weak cell] image, identifier in
                guard cell?.assetIdentifier == identifier else { return }
                cell?.thumbImage = image
            }
            
            return cell
            
        case .userCollections:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            let collection = userCollections.object(at: indexPath.row)
            cell.textLabel?.text = collection.localizedTitle
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
}

extension ImagePickerViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .allPhotos:
            let controller = ACKPhotosViewController(fetchResult: allPhotos)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        case .smartAlbums:
            let controller = ACKPhotosViewController(assetCollection: smartAlbums[indexPath.row])
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        case .userCollections:
            if let child = userCollections[indexPath.row] as? PHCollectionList {
                let controller = ACKCollectionViewController(collection: child)
                controller.delegate = self
                navigationController?.pushViewController(controller, animated: true)
            } else if let child = userCollections[indexPath.row] as? PHAssetCollection {
                let controller = ACKPhotosViewController(assetCollection: child)
                controller.delegate = self
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
}

extension ImagePickerViewController: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        // Change notifications may originate from a background queue.
        // Re-dispatch to the main queue before acting on the change,
        // so you can update the UI.
        DispatchQueue.main.sync { [weak self] in
            // Check each of the three top-level fetches for changes.
            if let changeDetails = changeInstance.changeDetails(for: allPhotos) {
                // Update the cached fetch result.
                allPhotos = changeDetails.fetchResultAfterChanges
                // Don't update the table row that always reads "All Photos."
            }

            // Update the cached fetch results, and reload the table sections to match.
            if let changeDetails = changeInstance.changeDetails(for: smartAlbums) {
                smartAlbums = changeDetails.fetchResultAfterChanges
                self?.reloadSection(.smartAlbums)
            }
            
            if let changeDetails = changeInstance.changeDetails(for: userCollections) {
                userCollections = changeDetails.fetchResultAfterChanges
                self?.reloadSection(.userCollections)
            }
        }
    }

}

extension ImagePickerViewController: ACKImagePickerDelegate {
    
    func maximumNumberOfSelectedImages() -> Int? {
        return maximumNumberOfImages
    }
    
    func didSelectPhotos(_ photos: OrderedSet<PHAsset>) {
        var images: [UIImage] = []
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat
        
        photos.forEach { asset in
            manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options) { image, _ in
                guard let image = image else { return }
                images.append(image)
            }
        }
        
        onImagesPicked?(images)
    }

}