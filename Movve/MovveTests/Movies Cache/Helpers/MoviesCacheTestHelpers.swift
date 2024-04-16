//
//  MoviesCacheTestHelpers.swift
//  MovveTests
//
//  Created by Petar Glusac on 14.4.24..
//

import Foundation
import Movve

func uniqueMovie() -> Movie {
    return Movie(id: 0, imagePath: UUID().uuidString)
}

func uniqueMovies() -> (models: [Movie], local: [LocalMovie]) {
    let movies = [uniqueMovie(), uniqueMovie()]
    let local = movies.map { LocalMovie(id: $0.id, imagePath: $0.imagePath) }
    return (movies, local)
}

extension Date {
    func minusMoviesCacheMaxAge() -> Date {
        return adding(days: -moviesCacheMaxAgeInDays)
    }
    
    private var moviesCacheMaxAgeInDays: Int {
        return 7
    }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
