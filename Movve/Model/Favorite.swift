//
//  Favorite.swift
//  Movve
//
//  Created by Petar Glusac on 29.3.21..
//

import Foundation

struct Favorite: Codable, Hashable {
    let type: MediaType
    let id: Int
    let title: String
    var posterPath: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(type)
    }
    
    static func == (lhs: Favorite, rhs: Favorite) -> Bool {
        return lhs.id == rhs.id && lhs.type == rhs.type
    }
    
}
