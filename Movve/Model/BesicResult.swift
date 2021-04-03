//
//  BesicResult.swift
//  Movve
//
//  Created by Petar Glusac on 24.3.21..
//

import Foundation

struct BasicResult: Decodable {
    let id: Int
    var posterPath: String?
    var backdropPath: String?
}

struct BasicResults: Decodable {
    let results: [BasicResult]
}
