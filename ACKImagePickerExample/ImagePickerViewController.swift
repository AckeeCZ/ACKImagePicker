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
    
    enum Section {
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
        view.addSubview(tableView)
        tableView.makeEdgesEqualToSuperview()
        self.tableView = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Fotografie"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        
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
            cell.textLabel!.text = NSLocalizedString("All Photos", comment: "")
            return cell
            
        case .smartAlbums:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            let collection = smartAlbums.object(at: indexPath.row)
            cell.textLabel!.text = collection.localizedTitle
            return cell
            
        case .userCollections:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            let collection = userCollections.object(at: indexPath.row)
            cell.textLabel!.text = collection.localizedTitle
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
            navigationController?.pushViewController(controller, animated: true)
        case .smartAlbums:
            print("TODO")
        case .userCollections:
            guard let child = userCollections[indexPath.row] as? PHCollectionList else { assertionFailure(); return }
            let controller = ACKCollectionViewController(collection: child)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}

extension ImagePickerViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        // Change notifications may originate from a background queue.
        // Re-dispatch to the main queue before acting on the change,
        // so you can update the UI.
//        DispatchQueue.main.sync {
//            // Check each of the three top-level fetches for changes.
//            if let changeDetails = changeInstance.changeDetails(for: allPhotos) {
//                // Update the cached fetch result.
//                allPhotos = changeDetails.fetchResultAfterChanges
//                // Don't update the table row that always reads "All Photos."
//            }
//
//            // Update the cached fetch results, and reload the table sections to match.
//            if let changeDetails = changeInstance.changeDetails(for: smartAlbums) {
//                smartAlbums = changeDetails.fetchResultAfterChanges
//                tableView.reloadSections(IndexSet(integer: Section.smartAlbums.rawValue), with: .automatic)
//            }
//            if let changeDetails = changeInstance.changeDetails(for: userCollections) {
//                userCollections = changeDetails.fetchResultAfterChanges
//                tableView.reloadSections(IndexSet(integer: Section.userCollections.rawValue), with: .automatic)
//            }
//        }
    }
}

