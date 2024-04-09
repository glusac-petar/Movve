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
    private let currentDate: () -> Date
    
    init(store: MoviesStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ movies: [Movie]) {
        store.deleteCachedMovies { [unowned self] error in
            if error == nil {
                self.store.insert(movies, timestamp: self.currentDate())
            }
        }
    }
}

class MoviesStore {
    typealias DeletionCompletion = (Error?) -> Void
    
    private var deletionCompletions: [DeletionCompletion] = []
    
    private(set) var receivedMessages: [ReceivedMessage] = []
    
    enum ReceivedMessage: Equatable {
        case deleteCache
        case insert([Movie], Date)
    }
    
    func deleteCachedMovies(completion: @escaping DeletionCompletion) {
        receivedMessages.append(.deleteCache)
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: NSError, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfuly(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ movies: [Movie], timestamp: Date) {
        receivedMessages.append(.insert(movies, timestamp))
    }
}

final class LocalMoviesLoaderTests: XCTestCase {
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let movies = [uniqueMovie(), uniqueMovie()]
        
        sut.save(movies)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCache])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let movies = [uniqueMovie(), uniqueMovie()]
        let deletionError = anyNSError()
        
        sut.save(movies)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCache])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let movies = [uniqueMovie(), uniqueMovie()]
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(movies)
        store.completeDeletionSuccessfuly()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCache, .insert(movies, timestamp)])
    }
    
    // MARK: - Helper
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalMoviesLoader, store: MoviesStore) {
        let store = MoviesStore()
        let sut = LocalMoviesLoader(store: store, currentDate: currentDate)
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
