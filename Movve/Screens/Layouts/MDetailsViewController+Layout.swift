//
//  MDetailsViewController+Layout.swift
//  Movve
//
//  Created by Petar Glusac on 25.3.21..
//

import UIKit

extension MDetailsViewController {
    
    func layoutUI() {
        view.addSubview(scrollView)
        scrollView.addSubviews(backdropImageView, posterImageView, playButton, videoPlayer, titleLabel, infoLabel, ratingView, overviewLabel, tableView)
    
        tableViewHeight = tableView.heightAnchor.constraint(equalToConstant: 0)
        let padding: CGFloat = 12
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            backdropImageView.topAnchor.constraint(equalTo: scrollView.contentView.topAnchor),
            backdropImageView.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor),
            backdropImageView.heightAnchor.constraint(equalToConstant: 180),
            
            posterImageView.topAnchor.constraint(equalTo: backdropImageView.topAnchor, constant: padding),
            posterImageView.leadingAnchor.constraint(equalTo: backdropImageView.leadingAnchor, constant: padding),
            posterImageView.widthAnchor.constraint(equalTo: posterImageView.heightAnchor, multiplier: 0.75),
            posterImageView.bottomAnchor.constraint(equalTo: backdropImageView.bottomAnchor, constant: -padding),
            
            playButton.centerYAnchor.constraint(equalTo: backdropImageView.centerYAnchor),
            playButton.leadingAnchor.constraint(equalTo: backdropImageView.leadingAnchor, constant: view.frame.width * 0.59),
            playButton.widthAnchor.constraint(equalToConstant: 60),
            playButton.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: backdropImageView.bottomAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor, constant: -padding),
            
            infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding),
            infoLabel.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor, constant: padding),
            infoLabel.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor, constant: -padding),
            
            ratingView.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: padding),
            ratingView.centerXAnchor.constraint(equalTo: scrollView.contentView.centerXAnchor),
            ratingView.widthAnchor.constraint(equalToConstant: 125),
            ratingView.heightAnchor.constraint(equalToConstant: 25),
            
            overviewLabel.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: padding),
            overviewLabel.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor, constant: padding),
            overviewLabel.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor, constant: -padding),
            
            tableView.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: padding),
            tableView.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor),
            tableViewHeight,
            tableView.bottomAnchor.constraint(equalTo: scrollView.contentView.bottomAnchor)
        ])
    }
    
}

