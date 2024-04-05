//
//  RemoteMoviesLoaderTests.swift
//  MovveTests
//
//  Created by Petar Glusac on 5.4.24..
//

import XCTest

class RemoteMoviesLoader {}

class HTTPClient {
    var requestedURL: URL?
}

final class RemoteMoviesLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let httpClient = HTTPClient()
        let _ = RemoteMoviesLoader()
        
        XCTAssertNil(httpClient.requestedURL)
    }
}
