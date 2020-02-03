//
//  BaseViewController.swift
//  ACKImagePicker
//
//  Created by Jan Misar on 03/02/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    private weak var loadingView: UIView!
    private weak var activityIndicator: UIActivityIndicatorView!
    
    override func loadView() {
        super.loadView()
        
        let loadingView = UIView()
        if #available(iOS 13.0, *) {
            loadingView.backgroundColor = .systemBackground
        } else {
            loadingView.backgroundColor = .white
        }
        loadingView.layer.cornerRadius = 10
        view.addSubview(loadingView)
        loadingView.makeCenterEqualToSuperview()
        self.loadingView = loadingView
        
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        if #available(iOS 13.0, *) {
            activityIndicator.color = .label
        } else {
            activityIndicator.color = .black
        }
        loadingView.addSubview(activityIndicator)
        activityIndicator.makeEdgesEqualToSuperview(insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        self.activityIndicator = activityIndicator
        
        stopLoadingAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.bringSubviewToFront(loadingView)
    }
    
    internal func startLoadingAnimation() {
        loadingView.isHidden = false
        activityIndicator.startAnimating()
    }
    
    internal func stopLoadingAnimation() {
        loadingView.isHidden = true
        activityIndicator.stopAnimating()
    }
}
