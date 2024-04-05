//
//  RemoteMoviesLoader.swift
//  Movve
//
//  Created by Petar Glusac on 5.4.24..
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<HTTPURLResponse, Error>
    
    func get(from url: URL, completion: @escaping (Result) -> Void)
}

public final class RemoteMoviesLoader {
    private let url: URL
    private let httpClient: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        httpClient.get(from: url) { result in
            switch result {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.connectivity)
            }
        }
    }
}
