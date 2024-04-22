//
//  CodableMoviesStoreTests.swift
//  MovveTests
//
//  Created by Petar Glusac on 20.4.24..
//

import XCTest
import Movve

class CodableMoviesStore {
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    private struct CodableMovie: Codable {
        private let id: Int
        private let imagePath: String
        
        init(_ movie: LocalMovie) {
            id = movie.id
            imagePath = movie.imagePath
        }
        
        var local: LocalMovie {
            return LocalMovie(id: id, imagePath: imagePath)
        }
    }
    
    private struct Cache: Codable {
        let movies: [CodableMovie]
        let timestamp: Date
        
        var localMovies: [LocalMovie] {
            return movies.map { $0.local }
        }
    }
    
    func retrieve(completion: @escaping MoviesStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }
        
        let decoder = JSONDecoder()
        let decoded = try! decoder.decode(Cache.self, from: data)
        completion(.found(movies: decoded.localMovies ,timestamp: decoded.timestamp))
    }
    
    func insert(_ movies: [LocalMovie], timestamp: Date, completion: @escaping MoviesStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(movies: movies.map(CodableMovie.init), timestamp: timestamp))
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

final class CodableMoviesStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for retrieval")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty, got \(result) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for retrieval")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let movies = uniqueMovies().local
        let timestamp = Date()
        let exp = expectation(description: "Wait for retrieval")
        
        sut.insert(movies, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError)
            
            sut.retrieve { retrievedResult in
                switch retrievedResult {
                case let .found(movies: retrievedMovies, timestamp: retrievedTimestamp):
                    XCTAssertEqual(retrievedMovies, movies)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                default:
                    XCTFail("Expected found result with movies \(movies) and timestamp \(timestamp), got \(retrievedResult) instead")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableMoviesStore {
        let sut = CodableMoviesStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
