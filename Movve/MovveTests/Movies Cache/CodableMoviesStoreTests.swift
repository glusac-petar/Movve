//
//  CodableMoviesStoreTests.swift
//  MovveTests
//
//  Created by Petar Glusac on 20.4.24..
//

import XCTest
import Movve

class CodableMoviesStore {
    func retrieve(completion: @escaping MoviesStore.RetrievalCompletion) {
        completion(.empty)
    }
}

final class CodableMoviesStoreTests: XCTestCase {
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
    
    // MARK: - Helpers
    
    func makeSUT() -> CodableMoviesStore {
        return CodableMoviesStore()
    }
}
