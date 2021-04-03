//
//  DetailedShowResult.swift
//  Movve
//
//  Created by Petar Glusac on 25.3.21..
//

import Foundation

struct DetailedShowResult: Decodable {
    let id: Int
    let name: String
    var posterPath: String?
    var backdropPath: String?
    let firstAirDate: String
    let numberOfSeasons: Int
    let overview: String
    let voteAverage: Float
    let genres: [GenreResult]
}
