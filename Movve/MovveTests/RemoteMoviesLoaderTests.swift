//
//  RemoteMoviesLoaderTests.swift
//  MovveTests
//
//  Created by Petar Glusac on 5.4.24..
//

import XCTest

class RemoteMoviesLoader {
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func load() {
        httpClient.get(from: URL(string: "https://an-url.com")!)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

final class RemoteMoviesLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let httpClient = HTTPClientSpy()
        let _ = RemoteMoviesLoader(httpClient: httpClient)
        
        XCTAssertNil(httpClient.requestedURL)
    }
    
    func test_load_requestsDataFromURL() {
        let httpClient = HTTPClientSpy()
        let sut = RemoteMoviesLoader(httpClient: httpClient)
        
        sut.load()
        
        XCTAssertNotNil(httpClient.requestedURL)
    }
    
    // MARK: - Helpers
    
    private final class HTTPClientSpy: HTTPClient {
        private(set) var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
    }
}
