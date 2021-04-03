//
//  UIView+Ext.swift
//  Movve
//
//  Created by Petar Glusac on 23.3.21..
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: UIView...) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
    }
    
}
