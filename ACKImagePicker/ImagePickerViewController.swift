//
//  ACKPhotosViewController.swift
//  ACKImagePickerExample
//
//  Created by Lukáš Hromadník on 13/02/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import UIKit
import Photos

final class ImagePickerViewController: UIViewController {
    
    private let imageManager = PHImageManager()
    
    enum Section: Int {
        case allPhotos
        case smartAlbums
        case userCollections
        
        var title: String? {
            switch self {
            case .allPhotos: return nil
            case .smartAlbums: return NSLocalizedString("Smart Albums", comment: "")
            case .userCollections: return NSLocalizedString("Albums", comment: "")
            }
        }
    }
    
    var onImagesPicked: (([UIImage]) -> Void)?
    var maximumNumberOfImages: Int? = nil
    
    private let sections: [Section] = [.allPhotos, .smartAlbums, .userCollections]
    
    private var allPhotos: PHFetchResult<PHAsset>!
    private var smartAlbums: PHFetchResult<PHAssetCollection>!
    private var userCollections: PHFetchResult<PHCollection>!
    
    private weak var tableView: UITableView!
    
    // MARK: - Controller lifecycle
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        view.addSubview(tableView)
        tableView.makeEdgesEqualToSuperview()
        self.tableView = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("Photos", comment: "")
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
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .allPhotos: return 1
        case .smartAlbums: return smartAlbums.count
        case .userCollections: return userCollections.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .allPhotos:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = NSLocalizedString("All Photos", comment: "")
            return cell
            
        case .smartAlbums:
            let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableViewCell.reuseIdentifier, for: indexPath) as! CollectionTableViewCell
            let collection = smartAlbums.object(at: indexPath.row)
            cell.title = collection.localizedTitle
            let options = PHFetchOptions()
            options.fetchLimit = 1
            let result = PHAsset.fetchAssets(in: collection, options: options)
            if let firstAsset = result.firstObject {
                cell.assetIdentifier = firstAsset.localIdentifier
                let size = CGSize(width: 50, height: 50)
                imageManager.requestImage(for: firstAsset, targetSize: size, contentMode: .aspectFill, options: nil) { image, _ in
                    guard cell.assetIdentifier == firstAsset.localIdentifier else { return }
                    cell.thumbImage = image
                }
            }
            
            return cell
            
        case .userCollections:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            let collection = userCollections.object(at: indexPath.row)
            cell.textLabel?.text = collection.localizedTitle
            return cell
        }
    }
    
}

extension ImagePickerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
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
