//
//  MSearchTableViewCell.swift
//  Movve
//
//  Created by Petar Glusac on 31.3.21..
//

import UIKit

class MSearchTableViewCell: UITableViewCell {
    
    static let reuseID = "MSearchTableViewCell"
    
    private let posterImageView = MImageView(placeholder: UIImage(named: "poster-placeholder"))
    private let titleLabel = MTitleLabel(textAlignment: .left, font: UIFont.systemFont(ofSize: 15, weight: .semibold))
    private let dateLabel = MBodyLabel(textAlignment: .left, fontSize: 14)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        selectionStyle = .none
        backgroundColor = .mBackground
        contentView.addSubviews(posterImageView, titleLabel, dateLabel)
        
        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7.5),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            posterImageView.widthAnchor.constraint(equalTo: posterImageView.heightAnchor, multiplier: 0.75),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7.5),
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 7),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 7),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5)
        ])
    }
    
    func set(data: SearchResult) {
        posterImageView.downloadImage(from: data.posterPath!)
        titleLabel.text = data.title
        dateLabel.text = data.releaseDate?.convertToDateFormat()
    }
    
}
