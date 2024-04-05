//
//  MoviesMapper.swift
//  Movve
//
//  Created by Petar Glusac on 5.4.24..
//

import Foundation

final class MoviesMapper {
    private struct Root: Decodable {
        let results: [Item]
    }

    private struct Item: Decodable {
        let id: Int
        let posterPath: String?
    }
    
    private static let OK_200 = 200
    
    static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteMoviesLoader.Result {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard response.statusCode == OK_200, let root = try? decoder.decode(Root.self, from: data) else {
            return .failure(RemoteMoviesLoader.Error.invalidData)
        }
        
        let movies = root.results.compactMap { item -> Movie? in
            if let imagePath = item.posterPath {
                return Movie(id: item.id, imagePath: imagePath)
            }
            return nil
        }
        return .success(movies)
    }
}
