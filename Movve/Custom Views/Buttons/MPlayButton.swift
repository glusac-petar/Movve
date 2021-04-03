//
//  MPlayButton.swift
//  Movve
//
//  Created by Petar Glusac on 25.3.21..
//

import UIKit

class MPlayButton: UIButton {
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(isHidden: Bool = false) {
        self.init(frame: .zero)
        self.isHidden = isHidden
    }
    
    private func configure() {
        setBackgroundImage(UIImage(named: "play-button"), for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func enable() {
        activityIndicator.removeFromSuperview()
        setBackgroundImage(UIImage(named: "play-button"), for: .normal)
        isEnabled = true
    }
    
    func disable() {
        isEnabled = false
        setBackgroundImage(nil, for: .normal)
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    
}
