//
//  ValidateMoviesCacheUseCase.swift
//  MovveTests
//
//  Created by Petar Glusac on 14.4.24..
//

import XCTest
import Movve

final class ValidateMoviesCacheUseCase: XCTestCase {
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT(currentDate: Date.init)
        
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCache])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT(currentDate: Date.init)
        
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteLessThanSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let movies = uniqueMovies()
        
        sut.validateCache()
        store.completeRetrieval(with: movies.local, timestamp: lessThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let movies = uniqueMovies()
        
        sut.validateCache()
        store.completeRetrieval(with: movies.local, timestamp: sevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCache])
    }
    
    func test_validateCache_deletesMoreThanSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let movies = uniqueMovies()
        
        sut.validateCache()
        store.completeRetrieval(with: movies.local, timestamp: moreThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCache])
    }
    
    func test_validateCache_doesNotDeleteCacheAfterSUTInstanceHasBeenDeallocated() {
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let store = MoviesStoreSpy()
        var sut: LocalMoviesLoader? = LocalMoviesLoader(store: store, currentDate: { fixedCurrentDate })
        let movies = uniqueMovies()
        
        sut?.validateCache()
        sut = nil
        store.completeRetrieval(with: movies.local, timestamp: moreThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    // MARK: - Helper
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalMoviesLoader, store: MoviesStoreSpy) {
        let store = MoviesStoreSpy()
        let sut = LocalMoviesLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
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
            retrievalCompletions[index](.failure(error))
        }
        
        func completeRetrievalWithEmptyCache(at index: Int = 0) {
            retrievalCompletions[index](.empty)
        }
        
        func completeRetrieval(with movies: [LocalMovie], timestamp: Date, at index: Int = 0) {
            retrievalCompletions[index](.found(movies: movies, timestamp: timestamp))
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

private extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
