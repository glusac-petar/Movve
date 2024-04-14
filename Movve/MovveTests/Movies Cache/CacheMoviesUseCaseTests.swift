//
//  CacheMoviesUseCaseTests.swift
//  MovveTests
//
//  Created by Petar Glusac on 14.4.24..
//

import XCTest
import Movve

final class CacheMoviesUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        
        sut.save(uniqueMovies().models) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCache])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(uniqueMovies().models) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCache])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let movies = uniqueMovies()
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(movies.models) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCache, .insert(movies.local, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = MoviesStoreSpy()
        var sut: LocalMoviesLoader? = LocalMoviesLoader(store: store, currentDate: Date.init)
        
        var receivedResults: [LocalMoviesLoader.SaveResult] = []
        sut?.save(uniqueMovies().models) { receivedResults.append($0) }
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = MoviesStoreSpy()
        var sut: LocalMoviesLoader? = LocalMoviesLoader(store: store, currentDate: Date.init)
        
        var receivedResults: [LocalMoviesLoader.SaveResult] = []
        sut?.save(uniqueMovies().models) { receivedResults.append($0) }
        
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }

    // MARK: - Helper
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalMoviesLoader, store: MoviesStoreSpy) {
        let store = MoviesStoreSpy()
        let sut = LocalMoviesLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalMoviesLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        sut.save(uniqueMovies().models) { error in
            XCTAssertEqual(error as? NSError, expectedError, file: file, line: line)
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func uniqueMovie() -> Movie {
        return Movie(id: 0, imagePath: UUID().uuidString)
    }
    
    private func uniqueMovies() -> (models: [Movie], local: [LocalMovie]) {
        let movies = [uniqueMovie(), uniqueMovie()]
        let local = movies.map { LocalMovie(id: $0.id, imagePath: $0.imagePath) }
        return (movies, local)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any-error", code: 1)
    }
}
