//
//  LocalMoviesLoaderTests.swift
//  MovveTests
//
//  Created by Petar Glusac on 9.4.24..
//

import XCTest

class LocalMoviesLoader {}

class MoviesStore {
    var deleteCachedMoviesCallCount = 0
}

final class LocalMoviesLoaderTests: XCTestCase {
    func test_init_doesNotDeleteCache() {
        let store = MoviesStore()
        let _ = LocalMoviesLoader()
        
        XCTAssertEqual(store.deleteCachedMoviesCallCount, 0)
    }
}
