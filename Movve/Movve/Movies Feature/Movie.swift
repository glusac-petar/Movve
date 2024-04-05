//
//  Movie.swift
//  Movve
//
//  Created by Petar Glusac on 5.4.24..
//

import Foundation

public struct Movie: Equatable {
    public let id: Int
    public let imagePath: String
    
    public init(id: Int, imagePath: String) {
        self.id = id
        self.imagePath = imagePath
    }
}
