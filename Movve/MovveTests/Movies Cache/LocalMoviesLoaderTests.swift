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
        store.deleteCachedMovies { [unowned self] error in
            if error == nil {
                self.store.insert(movies)
            }
        }
    }
}

class MoviesStore {
    typealias DeletionCompletion = (Error?) -> Void
    
    var deleteCachedMoviesCallCount = 0
    var insertCallCount = 0
    
    private var deletionCompletions: [DeletionCompletion] = []
    
    func deleteCachedMovies(completion: @escaping DeletionCompletion) {
        deleteCachedMoviesCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: NSError, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfuly(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ movies: [Movie]) {
        insertCallCount += 1
    }
}

final class LocalMoviesLoaderTests: XCTestCase {
    func test_init_doesNotDeleteCache() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedMoviesCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let movies = [uniqueMovie(), uniqueMovie()]
        
        sut.save(movies)
        
        XCTAssertEqual(store.deleteCachedMoviesCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let movies = [uniqueMovie(), uniqueMovie()]
        let deletionError = anyNSError()
        
        sut.save(movies)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_requestNewCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        let movies = [uniqueMovie(), uniqueMovie()]
        
        sut.save(movies)
        store.completeDeletionSuccessfuly()
        
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    // MARK: - Helper
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalMoviesLoader, store: MoviesStore) {
        let store = MoviesStore()
        let sut = LocalMoviesLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueMovie() -> Movie {
        return Movie(id: 0, imagePath: UUID().uuidString)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any-error", code: 1)
    }
}
