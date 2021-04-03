//
//  MRatingStackView.swift
//  Movve
//
//  Created by Petar Glusac on 26.3.21..
//

import UIKit

class MRatingStackView: UIStackView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .clear
        axis = .horizontal
        distribution = .fillEqually
        translatesAutoresizingMaskIntoConstraints = false
        
        for _ in 0..<5 { addArrangedSubview(UIImageView())}
    }
    
    func set(rating: Float) {
        let numberOfColoredViews = Int((rating/2).rounded(.toNearestOrAwayFromZero))
        
        for i in 0..<5 {
            if i<numberOfColoredViews {
                (arrangedSubviews[i] as! UIImageView).image = UIImage(systemName: "star.fill")
                (arrangedSubviews[i] as! UIImageView).tintColor = .orange
            } else {
                (arrangedSubviews[i] as! UIImageView).image = UIImage(systemName: "star")
                (arrangedSubviews[i] as! UIImageView).tintColor = .secondaryLabel
            }
        }
    }

}
