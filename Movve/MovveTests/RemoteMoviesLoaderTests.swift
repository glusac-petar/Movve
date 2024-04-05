//
//  RemoteMoviesLoaderTests.swift
//  MovveTests
//
//  Created by Petar Glusac on 5.4.24..
//

import XCTest
import Movve

final class RemoteMoviesLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, httpClient) = makeSUT()
        
        XCTAssertTrue(httpClient.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, httpClient) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(httpClient.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, httpClient) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(httpClient.requestedURLs, [url, url])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://an-url.com")!) -> (sut: RemoteMoviesLoader, httpClient: HTTPClientSpy) {
        let httpClient = HTTPClientSpy()
        let sut = RemoteMoviesLoader(url: url, httpClient: httpClient)
        return (sut, httpClient)
    }
    
    private final class HTTPClientSpy: HTTPClient {
        private(set) var requestedURLs: [URL] = []
        
        func get(from url: URL) {
            requestedURLs.append(url)
        }
    }
}
