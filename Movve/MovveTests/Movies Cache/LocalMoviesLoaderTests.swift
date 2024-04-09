//
//  LocalMoviesLoaderTests.swift
//  MovveTests
//
//  Created by Petar Glusac on 9.4.24..
//

import XCTest
import Movve

class LocalMoviesLoader {
    private let store: MoviesStore
    
    init(store: MoviesStore) {
        self.store = store
    }
    
    func save(_ movies: [Movie]) {
        store.deleteCachedMovies()
    }
}

class MoviesStore {
    var deleteCachedMoviesCallCount = 0
    
    func deleteCachedMovies() {
        deleteCachedMoviesCallCount += 1
    }
}

final class LocalMoviesLoaderTests: XCTestCase {
    func test_init_doesNotDeleteCache() {
        let store = MoviesStore()
        let _ = LocalMoviesLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedMoviesCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let store = MoviesStore()
        let sut = LocalMoviesLoader(store: store)
        let movies = [uniqueMovie(), uniqueMovie()]
        
        sut.save(movies)
        
        XCTAssertEqual(store.deleteCachedMoviesCallCount, 1)
    }
    
    // MARK: - Helper
    
    private func uniqueMovie() -> Movie {
        return Movie(id: 0, imagePath: UUID().uuidString)
    }
}
