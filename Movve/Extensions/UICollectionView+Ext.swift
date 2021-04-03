//
//  UICollectionView+Ext.swift
//  Movve
//
//  Created by Petar Glusac on 24.3.21..
//

import UIKit

extension UICollectionView {
    
    func reloadDataOnMainThread() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
    
}
