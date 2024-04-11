//
//  LocalMoviesLoaderTests.swift
//  MovveTests
//
//  Created by Petar Glusac on 9.4.24..
//

import XCTest
import Movve

final class LocalMoviesLoaderTests: XCTestCase {
    // MARK: - Save
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
    
    // MARK: - Load
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        let exp = expectation(description: "Wait for completion")
        
        var receivedError: Error?
        sut.load { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure with \(retrievalError), got \(result) instead.")
            }
            exp.fulfill()
        }
        store.completeRetrieval(with: retrievalError)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as? NSError, retrievalError)
    }
    
    func test_load_deliversNoMoviesOnEmptyCache() {
        let (sut, store) = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        var receivedMovies: [Movie]?
        sut.load { result in
            switch result {
            case let .success(movies):
                receivedMovies = movies
            default:
                XCTFail("Expected success with no movies, got \(result) instead.")
            }
            exp.fulfill()
        }
        store.completeRetrievalWithEmptyCache()
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedMovies, [])
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
    
    private final class MoviesStoreSpy: MoviesStore {
        private var deletionCompletions: [DeletionCompletion] = []
        private var insertionCompletions: [InsertionCompletion] = []
        private var retrievalCompletions: [RetrievalCompletion] = []
        
        private(set) var receivedMessages: [ReceivedMessage] = []
        
        enum ReceivedMessage: Equatable {
            case deleteCache
            case insert([LocalMovie], Date)
            case retrieve
        }
        
        func deleteCachedMovies(completion: @escaping DeletionCompletion) {
            receivedMessages.append(.deleteCache)
            deletionCompletions.append(completion)
        }
        
        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        func insert(_ movies: [LocalMovie], timestamp: Date, completion: @escaping InsertionCompletion) {
            receivedMessages.append(.insert(movies, timestamp))
            insertionCompletions.append(completion)
        }
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }
        
        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
        
        func retrieve(completion: @escaping RetrievalCompletion) {
            retrievalCompletions.append(completion)
            receivedMessages.append(.retrieve)
        }
        
        func completeRetrieval(with error: Error, at index: Int = 0) {
            retrievalCompletions[index](error)
        }
        
        func completeRetrievalWithEmptyCache(at index: Int = 0) {
            retrievalCompletions[index](nil)
        }
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
