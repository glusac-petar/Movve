//
//  RemoteMoviesLoaderTests.swift
//  MovveTests
//
//  Created by Petar Glusac on 5.4.24..
//

import XCTest

class RemoteMoviesLoader {
    private let url: URL
    private let httpClient: HTTPClient
    
    init(url: URL, httpClient: HTTPClient) {
        self.url = url
        self.httpClient = httpClient
    }
    
    func load() {
        httpClient.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

final class RemoteMoviesLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let url = URL(string: "https:/a-given-url.com")!
        let httpClient = HTTPClientSpy()
        let _ = RemoteMoviesLoader(url: url, httpClient: httpClient)
        
        XCTAssertNil(httpClient.requestedURL)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let httpClient = HTTPClientSpy()
        let sut = RemoteMoviesLoader(url: url, httpClient: httpClient)
        
        sut.load()
        
        XCTAssertEqual(httpClient.requestedURL, url)
    }
    
    // MARK: - Helpers
    
    private final class HTTPClientSpy: HTTPClient {
        private(set) var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
    }
}
