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
    private weak var progressView: CircularProgressView!
    
    override func loadView() {
        super.loadView()
        
//        let loadingView = UIView()
//        if #available(iOS 13.0, *) {
//            loadingView.backgroundColor = .systemBackground
//        } else {
//            loadingView.backgroundColor = .white
//        }
//        loadingView.layer.cornerRadius = 10
//        view.addSubview(loadingView)
//        loadingView.makeCenterEqualToSuperview()
//        self.loadingView = loadingView
//
//        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
//        if #available(iOS 13.0, *) {
//            activityIndicator.color = .label
//        } else {
//            activityIndicator.color = .black
//        }
//        loadingView.addSubview(activityIndicator)
//        activityIndicator.makeEdgesEqualToSuperview(insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
//        self.activityIndicator = activityIndicator
//
//        stopLoadingAnimation()
        
        let progressView = CircularProgressView()
//        progressView.isProgressAnimationEnabled = false
//        progressView.backgroundColor = .red
//        progressView.mainColor = .blue
        view.addSubview(progressView)
//        progressView.makeCenterEqualToSuperview()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 50),
            progressView.heightAnchor.constraint(equalToConstant: 50),
        ])
        self.progressView = progressView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        view.bringSubviewToFront(loadingView)
        view.bringSubviewToFront(progressView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        progressView.progress = 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.progressView.progress = 0.75
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.progressView.progress = 0.4
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.progressView.progress = 1
        }
    }
    
    func startLoadingAnimation() {
//        loadingView.isHidden = false
        view.bringSubviewToFront(progressView)
//        activityIndicator.startAnimating()
    }
    
    func stopLoadingAnimation() {
//        loadingView.isHidden = true
//        activityIndicator.stopAnimating()
    }
}
