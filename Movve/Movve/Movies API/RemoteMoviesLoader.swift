//
//  RemoteMoviesLoader.swift
//  Movve
//
//  Created by Petar Glusac on 5.4.24..
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(from url: URL, completion: @escaping (Result) -> Void)
}

public final class RemoteMoviesLoader {
    private let url: URL
    private let httpClient: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = Swift.Result<[Movie], Error>
    
    public init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        httpClient.get(from: url) { result in
            switch result {
            case let .success((data, _)):
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                if let root = try? decoder.decode(Root.self, from: data) {
                    let movies = root.results.compactMap { item -> Movie? in
                        if let imagePath = item.posterPath {
                            return Movie(id: item.id, imagePath: imagePath)
                        }
                        return nil
                    }
                    completion(.success(movies))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private struct Root: Decodable {
    let results: [Item]
}

private struct Item: Decodable {
    let id: Int
    let posterPath: String?
}
