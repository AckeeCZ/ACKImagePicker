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
    
    // MARK: - Controller lifecycle
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "ACKImagePicker"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(galleryBarButtonTapped(_:)))
    }
    
    // MARK: - Actions
    
    @objc
    private func galleryBarButtonTapped(_ sender: UIBarButtonItem) {
        let controller = PhotosViewController()
        controller.onImagesPicked = { [weak self] images in
            print(images)
            self?.dismiss(animated: true)
        }
        present(UINavigationController(rootViewController: controller), animated: true)
    }

}

