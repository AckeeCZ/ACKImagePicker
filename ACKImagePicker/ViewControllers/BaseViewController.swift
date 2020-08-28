//
//  BaseViewController.swift
//  ACKImagePicker
//
//  Created by Jan Misar on 03/02/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    private weak var progressView: CircularProgressView!
    private weak var backgroundView: UIView!
    
    // MARK: - Controller lifecycle
    
    override func loadView() {
        super.loadView()
        
        let backgroundView = UIView()
        if #available(iOSApplicationExtension 13.0, *) {
            backgroundView.backgroundColor = .red
        } else {
            backgroundView.backgroundColor = .white
        }
        backgroundView.layer.cornerRadius = 8
        view.addSubview(backgroundView)
        backgroundView.makeCenterEqualToSuperview()
        NSLayoutConstraint.activate([
            backgroundView.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        self.backgroundView = backgroundView
        
        let progressView = CircularProgressView()
        backgroundView.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 10),
            progressView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -10),
            progressView.heightAnchor.constraint(equalTo: progressView.widthAnchor)
        ])
        self.progressView = progressView
        
        let progressLabel = UILabel()
        progressLabel.text = "25 %"
        progressLabel.font = .boldSystemFont(ofSize: 16)
        backgroundView.addSubview(progressLabel)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            progressLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor)
        ])
        
        let progressTextLabel = UILabel()
        progressTextLabel.text = "Nahrávám"
        backgroundView.addSubview(progressTextLabel)
        progressTextLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressTextLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 10),
            progressTextLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 8),
            progressTextLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -8),
            progressTextLabel.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -10)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.bringSubviewToFront(backgroundView)
    }
}
