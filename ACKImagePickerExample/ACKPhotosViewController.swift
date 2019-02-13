//
//  ACKPhotosViewController.swift
//  ACKImagePickerExample
//
//  Created by Lukáš Hromadník on 13/02/2019.
//  Copyright © 2019 Lukáš Hromadník. All rights reserved.
//

import UIKit
import Photos

final class ACKPhotosViewController: UIViewController {
    
    private var collections: PHFetchResult<PHCollection>?
    
    private weak var tableView: UITableView!
    
    // MARK: - Controller lifecycle
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addConstraints([
            NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tableView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            ])
        self.tableView = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Fotografie"
        
        tableView.dataSource = self
        
        collections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
    }
    
}

extension ACKPhotosViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = collections?[indexPath.row].localizedTitle
        
        return cell
    }
    
}
