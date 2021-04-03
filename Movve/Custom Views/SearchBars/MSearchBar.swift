//
//  MSearchBar.swift
//  Movve
//
//  Created by Petar Glusac on 23.3.21..
//

import UIKit

class MSearchBar: UISearchBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        showsCancelButton = false
        tintColor = .white
        searchTextField.clearButtonMode = .whileEditing
        placeholder = "Search"
    }
    
}
