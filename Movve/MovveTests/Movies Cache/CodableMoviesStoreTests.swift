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
        let sut = CodableMoviesStore()
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
}
