//
//  LocalMovie.swift
//  Movve
//
//  Created by Petar Glusac on 10.4.24..
//

import Foundation

public struct LocalMovie: Equatable, Codable {
    public let id: Int
    public let imagePath: String
    
    public init(id: Int, imagePath: String) {
        self.id = id
        self.imagePath = imagePath
    }
}
