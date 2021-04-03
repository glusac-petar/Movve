//
//  MTableViewHeaderFooterView.swift
//  Movve
//
//  Created by Petar Glusac on 23.3.21..
//

import UIKit

class MTableViewHeaderFooterView: UITableViewHeaderFooterView {
    
    static let reuseID = "MHomeTableViewHeaderFooterView"
    
    private let titleLabel = MTitleLabel(textAlignment: .left, font: UIFont.systemFont(ofSize: 18, weight: .medium))
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -7.5),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabel.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    
    func set(title: String) { titleLabel.text = title }
    
}
