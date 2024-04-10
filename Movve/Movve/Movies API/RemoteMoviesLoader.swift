//
//  RemoteMoviesLoader.swift
//  Movve
//
//  Created by Petar Glusac on 5.4.24..
//

import Foundation

public final class RemoteMoviesLoader: MoviesLoader {
    private let url: URL
    private let httpClient: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = MoviesLoader.Result
    
    public init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        httpClient.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(RemoteMoviesLoader.map(data, response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        do {
            let movies = try MoviesMapper.map(data, response)
            return .success(movies.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteMovie {
    func toModels() -> [Movie] {
        return compactMap { item -> Movie? in
            if let imagePath = item.posterPath {
                return Movie(id: item.id, imagePath: imagePath)
            }
            return nil
        }
    }
}
