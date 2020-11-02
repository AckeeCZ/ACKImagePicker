//
//  ViewController.swift
//  Gallery
//
//  Created by Lukáš Hromadník on 04.07.18.
//  Copyright © 2018 Lukáš Hromadník. All rights reserved.
//

import UIKit
import ACKImagePicker

final class ViewController: UIViewController {
    private var images: [UIImage] = []
    
    private weak var collectionView: UICollectionView!
    
    // MARK: - Controller lifecycle
    
    override func loadView() {
        super.loadView()
        
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 1
        collectionViewLayout.minimumInteritemSpacing = 1
        
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionViewLayout)
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = .systemBackground
        } else {
            collectionView.backgroundColor = .white
        }
        view.addSubview(collectionView)
        self.collectionView = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseIdentifier)
        
        navigationItem.title = "ACKImagePicker"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(galleryBarButtonTapped))
    }
    
    // MARK: - Actions
    
    @objc
    private func galleryBarButtonTapped(_ sender: UIBarButtonItem) {
        let controller = ACKImagePicker()
        controller.maximumNumberOfImages = 3
        controller.onImagesPicked = { [weak self] images in
            self?.images = images
            self?.collectionView.reloadData()
            self?.dismiss(animated: true)
        }
        
        present(controller, animated: true)
    }

}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseIdentifier, for: indexPath) as! ImageCell
        cell.image = images[indexPath.row]
        
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 200)
    }
}
