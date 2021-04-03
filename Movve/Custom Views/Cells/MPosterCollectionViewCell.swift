//
//  MPosterCollectionViewCell.swift
//  Movve
//
//  Created by Petar Glusac on 24.3.21..
//

import UIKit

class MPosterCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = "MHomeCollectionViewCell"
    
    private let posterImageView = MImageView(cornerRadius: 2.5, placeholder: UIImage(named: "poster-placeholder"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .clear
        contentView.addSubview(posterImageView)
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func set(path: String) { posterImageView.downloadImage(from: path) }
    
}
