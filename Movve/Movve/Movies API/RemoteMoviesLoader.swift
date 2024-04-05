//
//  RemoteMoviesLoader.swift
//  Movve
//
//  Created by Petar Glusac on 5.4.24..
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}

public final class RemoteMoviesLoader {
    private let url: URL
    private let httpClient: HTTPClient
    
    public init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    public func load() {
        httpClient.get(from: url)
    }
}
