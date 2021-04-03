//
//  MCastCollectionViewCell.swift
//  Movve
//
//  Created by Petar Glusac on 27.3.21..
//

import UIKit

class MCastCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = "MCastCollectionViewCell"
    
    let actorImageView = MImageView(cornerRadius: 31.25, placeholder: UIImage(named: "poster-placeholder"))
    let actorNameLabel = MTitleLabel(textAlignment: .center, font: UIFont.systemFont(ofSize: 13, weight: .medium))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .clear
        contentView.addSubviews(actorImageView, actorNameLabel)
        
        NSLayoutConstraint.activate([
            actorImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            actorImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            actorImageView.widthAnchor.constraint(equalToConstant: 62.5),
            actorImageView.heightAnchor.constraint(equalToConstant: 62.5),
            
            actorNameLabel.topAnchor.constraint(equalTo: actorImageView.bottomAnchor, constant: 5),
            actorNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            actorNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            actorNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func set(cast: CastResult) {
        actorImageView.downloadImage(from: cast.profilePath!)
        actorNameLabel.text = cast.name
    }
    
}
