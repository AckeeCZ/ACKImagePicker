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
    
    private var collections: PHFetchResult<PHCollection>!
    
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
        
        collections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
    }
    
}

extension ACKPhotosViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = collections[indexPath.row].localizedTitle
        
        return cell
    }
    
}
