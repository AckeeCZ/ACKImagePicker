//
//  ACKPhotosViewController.swift
//  ACKImagePickerExample
//
//  Created by Lukáš Hromadník on 13/02/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import UIKit
import Photos

class ImagePickerViewController: UIViewController {
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

    var onImagesPicked: (([UIImage]) -> Void)?
    var maximumNumberOfImages: Int? = nil

    private let sections: [Section] = [.allPhotos, .smartAlbums, .userCollections]
    private var albumViewModels: [IndexPath: AlbumViewModel] = [:]

    private var allPhotos: PHFetchResult<PHAsset> = .init()
    private var smartAlbumsResults: PHFetchResult<PHAssetCollection> = .init() {
        didSet {
            smartAlbumsResults.enumerateObjects { [weak self] collection, _, _ in
                // Add only those albums that we want
                if self?.smartSubtypes.contains(collection.assetCollectionSubtype) == true {
                    self?.smartAlbums.append(collection)
                }
            }
        }
    }
    private var smartAlbums: [PHAssetCollection] = []
    private let smartSubtypes: [PHAssetCollectionSubtype] = {
        var smartSubtypes: [PHAssetCollectionSubtype] = [
            .smartAlbumGeneric,
            .smartAlbumPanoramas,
//            .smartAlbumVideos,
            .smartAlbumFavorites,
//            .smartAlbumTimelapses,
            .smartAlbumAllHidden,
            .smartAlbumRecentlyAdded,
            .smartAlbumBursts,
//            .smartAlbumSlomoVideos,
            .smartAlbumUserLibrary,
            .smartAlbumSelfPortraits,
            .smartAlbumScreenshots
        ]

        if #available(iOS 10.2, *) {
            smartSubtypes.append(.smartAlbumDepthEffect)
        }
        if #available(iOS 10.3, *) {
            smartSubtypes.append(.smartAlbumLivePhotos)
        }
        if #available(iOS 11.0, *) {
            smartSubtypes.append(.smartAlbumAnimated)
            smartSubtypes.append(.smartAlbumLongExposures)
        }
        return smartSubtypes
    }()

    private var userCollections: PHFetchResult<PHCollection> = .init()

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
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelBarButtonTapped))

        tableView.dataSource = self
        tableView.delegate = self

        checkAuthorizationStatus()
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

    private func checkAuthorizationStatus() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            authorize()
        case .authorized:
            setupPhotos()
        default:
            break
        }
    }

    private func authorize() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            switch status {
            case .authorized:
                self?.setupPhotos()
            default:
                break
            }
        }
    }

    private func setupPhotos() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotos = PHAsset.fetchAssets(with: .image, options: allPhotosOptions)

        let loadData: () -> () = { [weak self] in
            self?.smartAlbumsResults = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
            self?.reloadSection(.smartAlbums)
            self?.userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            self?.reloadSection(.userCollections)
        }

        // `loadData` must be on main thread, `setupPhotos` can be called from main or background thread
        if Thread.isMainThread {
            loadData()
        } else {
            DispatchQueue.main.sync {
                loadData()
            }
        }

        PHPhotoLibrary.shared().register(self)
    }

    // MARK: - LoadingView

    private func showProgress() -> ProgressViewController {
        let controller = ProgressViewController()
        controller.modalPresentationStyle = .overCurrentContext
        present(controller, animated: false)
        return controller
    }
}

extension ImagePickerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
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
            cell.textLabel?.text = "picker.all_photos".localized()
            cell.accessoryType = .disclosureIndicator
            return cell

        case .smartAlbums:
            let collection = smartAlbums[indexPath.row]

            let image: UIImage!
            switch collection.assetCollectionSubtype {
            case .smartAlbumPanoramas:
                image = Assets.panoramas.image
            case .smartAlbumVideos:
                image = Assets.videos.image
            case .smartAlbumFavorites:
                image = Assets.favourites.image
            case .smartAlbumTimelapses:
                image = Assets.timelapse.image
            case .smartAlbumAllHidden:
                image = Assets.hidden.image
            case .smartAlbumRecentlyAdded:
                image = Assets.recentlyAdded.image
            case .smartAlbumBursts:
                image = Assets.burts.image
            case .smartAlbumSelfPortraits:
                image = Assets.selfies.image
            case .smartAlbumScreenshots:
                image = Assets.screenshots.image
            case .smartAlbumSlomoVideos:
                image = Assets.sloMo.image
            case .smartAlbumDepthEffect:
                image = Assets.random.image
            case .smartAlbumLivePhotos:
                image = Assets.livePhotos.image
            case .smartAlbumAnimated:
                image = Assets.animated.image
            case .smartAlbumLongExposures:
                image = Assets.longExposure.image
            default:
                image = Assets.random.image
            }

            let cell: CollectionTableViewCell = tableView.dequeueCell(for: indexPath)
            cell.title = collection.localizedTitle
            cell.accessoryType = .disclosureIndicator

            // Initialize a new viewModel which performs the fetch
            if albumViewModels[indexPath] == nil {
                albumViewModels[indexPath] = AlbumViewModel(collection: collection, imageManager: imageManager)
            }

            let albumViewModel = albumViewModels[indexPath]
            cell.thumbImage = albumViewModel?.image ?? image.withRenderingMode(.alwaysOriginal)
            cell.assetIdentifier = albumViewModel?.assetIdentifier
            albumViewModel?.onImage = { [weak cell] image, identifier in
                guard cell?.assetIdentifier == identifier, let image = image else { return }
                cell?.thumbImage = image
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)

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
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
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
            if let changeDetails = changeInstance.changeDetails(for: smartAlbumsResults) {
                smartAlbumsResults = changeDetails.fetchResultAfterChanges
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
    var maximumNumberOfSelectedImages: Int? {
        maximumNumberOfImages
    }

    func didSelectPhotos(_ photos: OrderedSet<PHAsset>) {
        let progressView = showProgress()

        // We need to store the download progress per asset
        // based on its request ID
        var progress: [PHImageRequestID: Double] = [:] {
            didSet {
                // Always update the UI on the main thread
                DispatchQueue.main.async {
                    // Sum all intermediate progresses and divide them by number of photos
                    progressView.progress = CGFloat(progress.values.reduce(0, +) / Double(photos.count))
                }
            }
        }

        var images: [UIImage] = []
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progressValue, _, _, info in
            guard let requestID = info?[PHImageResultRequestIDKey] as? PHImageRequestID else { assertionFailure(); return }
            // Update the progress value for the current request
            progress[requestID] = progressValue
        }

        // group of imageRequest tasks, used for waiting for all of images to be downloaded
        let group = DispatchGroup()

        // start requests for all selected images
        photos.forEach { asset in
            group.enter()
            let requestID = manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { image, info in
                if let image = image {
                    images.append(image)
                    if let requestID = info?[PHImageResultRequestIDKey] as? PHImageRequestID {
                        // When the download is finished or when the image is available locally
                        // this will set the progress to the correct value
                        progress[requestID] = 1
                    }
                }
                group.leave()
            }
            // Set the initial value for the progress
            progress[requestID] = 0
        }

        // call `onImagesPicked` block on main thread when whole group is finished
        group.notify(queue: .main) { [weak self] in
            // Show the completed progress for a brief moment, it's nicer than immediate dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                progressView.dismiss(animated: false)
                self?.onImagesPicked?(images)
            }
        }
    }
}
