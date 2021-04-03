//
//  DetailedMovieResult.swift
//  Movve
//
//  Created by Petar Glusac on 25.3.21..
//

import Foundation

struct DetailedMovieResult: Decodable {
    let id: Int
    let title: String
    var posterPath: String?
    var backdropPath: String?
    let releaseDate: String
    var runtime: Int?
    let overview: String?
    let voteAverage: Float
    let genres: [GenreResult]
}
