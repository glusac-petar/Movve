//
//  Int+Ext.swift
//  Movve
//
//  Created by Petar Glusac on 26.3.21..
//

import Foundation

extension Int {
    
    func minutesToHoursAndMinutes() -> String {
        guard self > 0 else { return String() }
        
        let hours = self/60
        let minutes = self%60
        
        let hoursString = hours > 0 ? "\(hours)h" : ""
        let minutesString = minutes > 0 ? "\(minutes)m" : ""
        
        return "\(hoursString) \(minutesString)"
    }

}
