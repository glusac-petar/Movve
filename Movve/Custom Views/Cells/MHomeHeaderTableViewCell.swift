//
//  MHomeHeaderTableViewCell.swift
//  Movve
//
//  Created by Petar Glusac on 23.3.21..
//

import UIKit

class MHomeHeaderTableViewCell: UITableViewCell {

    static let reuseID = "MHomeHeaderTableViewCell"
    
    private let posterImageView = MImageView(placeholder: UIImage(named: "backdrop-placeholder"))
    
    private var data: BasicResult! {
        didSet {
            posterImageView.downloadImage(from: data.backdropPath!)
        }
    }
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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

    func set(data: BasicResult) { self.data = data }
    
}



