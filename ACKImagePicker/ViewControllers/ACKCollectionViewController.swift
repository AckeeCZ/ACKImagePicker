//
//  ACKCollectionViewController.swift
//  ACKImagePickerExample
//
//  Created by Lukáš Hromadník on 13/02/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import UIKit
import Photos

protocol ACKImagePickerDelegate: class {
    var maximumNumberOfSelectedImages: Int? { get }

    func didSelectPhotos(_ photos: OrderedSet<PHAsset>)
}

final class ACKCollectionViewController: UIViewController {
    
    enum Section {
        case allPhotos
        case collections
    }
    
    weak var delegate: ACKImagePickerDelegate?
    
    private let sections: [Section] = [.allPhotos, .collections]
    
    private let collection: PHCollectionList
    private var collections: PHFetchResult<PHCollection>?
    
    private weak var tableView: UITableView!
    
    // MARK: - Initialization
    
    init(collection: PHCollectionList) {
        self.collection = collection
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Controller lifecycle
    
    override func loadView() {
        super.loadView()
        
        let tableView = UITableView(frame: .zero)
        view.addSubview(tableView)
        tableView.makeEdgesEqualToSuperview()
        self.tableView = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = collection.localizedTitle
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if collection.canContainCollections {
            collections = PHCollectionList.fetchCollections(in: collection, options: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.indexPathsForSelectedRows?.forEach { tableView.deselectRow(at: $0, animated: animated) }
    }
    
}

extension ACKCollectionViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .allPhotos: return 1
        case .collections: return collections?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .allPhotos:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "picker.all_photos".localized()
            cell.accessoryType = .disclosureIndicator
            return cell
        case .collections:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = collections?[indexPath.row].localizedTitle
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
}

extension ACKCollectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .allPhotos:
            let controller = ACKPhotosViewController(collectionList: collection)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        case .collections:
            let childCollection = collections?[indexPath.row]
            if let child = childCollection as? PHCollectionList {
                let controller = ACKCollectionViewController(collection: child)
                controller.delegate = self
                navigationController?.pushViewController(controller, animated: true)
            } else if let child = childCollection as? PHAssetCollection {
                let controller = ACKPhotosViewController(assetCollection: child)
                controller.delegate = self
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
}

extension ACKCollectionViewController: ACKImagePickerDelegate {
    var maximumNumberOfSelectedImages: Int? {
        delegate?.maximumNumberOfSelectedImages
    }

    func didSelectPhotos(_ photos: OrderedSet<PHAsset>) {
        delegate?.didSelectPhotos(photos)
    }
}
