//
//  UITableView+Ext.swift
//  Movve
//
//  Created by Petar Glusac on 24.3.21..
//

import UIKit

extension UITableView {
    
    func reloadDataOnMainThread() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
    
    func removeExcessCells() { tableFooterView = UIView(frame: .zero) }
    
}
