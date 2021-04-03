//
//  MImageView.swift
//  Movve
//
//  Created by Petar Glusac on 23.3.21..
//

import UIKit

class MImageView: UIImageView {
    
    private var path: String?
    
    private var placeholder: UIImage? {
        didSet { image = placeholder }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(cornerRadius: CGFloat = 0, placeholder: UIImage? = nil) {
        self.init(frame: .zero)
        self.layer.cornerRadius = cornerRadius
        defer { self.placeholder = placeholder }
    }
    
    private func configure() {
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func downloadImage(from path: String) {
        self.path = path
        self.image = placeholder
        
        NetworkManager.shared.downloadImage(path: path) { [weak self] (image) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if self.path == path { self.image = image }
            }
        }
    }
    
}
