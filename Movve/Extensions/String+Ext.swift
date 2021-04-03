//
//  String+Ext.swift
//  Movve
//
//  Created by Petar Glusac on 26.3.21..
//

import Foundation

extension String {
    
    func convertToDateFormat() -> String {
        guard !self.isEmpty else { return String() }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: self) else { return String()}
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        return  dateFormatter.string(from: date)
    }
    
}
