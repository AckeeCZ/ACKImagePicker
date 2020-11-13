//
//  ProgressViewController.swift
//  ACKImagePicker
//
//  Created by Lukáš Hromadník on 28/08/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

import UIKit

final class ProgressViewController: UIViewController {
    var progress: CGFloat = 0 {
        didSet {
            updateProgress()
        }
    }

    var progressTintColor: UIColor! {
        didSet {
            progressView?.tintColor = progressTintColor
        }
    }

    private weak var progressView: CircularProgressView!
    private weak var progressLabel: UILabel!
    private weak var backgroundView: UIView!

    // MARK: - Controller lifecycle

    override func loadView() {
        super.loadView()

        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)

        let backgroundView = UIView()
        if #available(iOSApplicationExtension 13.0, *) {
            backgroundView.backgroundColor = .systemBackground
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
        progressView.tintColor = progressTintColor
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
        progressLabel.font = .boldSystemFont(ofSize: 16)
        backgroundView.addSubview(progressLabel)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            progressLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor)
        ])
        self.progressLabel = progressLabel

        let progressTextLabel = UILabel()
        progressTextLabel.text = "progress.loading".localized()
        progressTextLabel.textAlignment = .center
        backgroundView.addSubview(progressTextLabel)
        progressTextLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressTextLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 10),
            progressTextLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 8),
            progressTextLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -8),
            progressTextLabel.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -10)
        ])

        updateProgress()
    }

    private func updateProgress() {
        progressView?.progress = progress
        progressLabel?.text = "\(Int(progress * 100)) %"
    }
}
