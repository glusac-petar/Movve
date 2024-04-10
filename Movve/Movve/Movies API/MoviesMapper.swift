//
//  MoviesMapper.swift
//  Movve
//
//  Created by Petar Glusac on 5.4.24..
//

import Foundation

final class MoviesMapper {
    private struct Root: Decodable {
        let results: [RemoteMovie]
    }
    
    private static let OK_200 = 200
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteMovie] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        guard response.statusCode == OK_200, let root = try? decoder.decode(Root.self, from: data) else {
            throw RemoteMoviesLoader.Error.invalidData
        }
        
        return root.results
    }
}
