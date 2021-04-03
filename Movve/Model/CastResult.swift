//
//  CastResult.swift
//  Movve
//
//  Created by Petar Glusac on 26.3.21..
//

import Foundation

struct CastResult: Decodable {
    let id: Int
    let name: String
    var profilePath: String?
}

struct CreditsResult: Decodable {
    let cast: [CastResult]
}
