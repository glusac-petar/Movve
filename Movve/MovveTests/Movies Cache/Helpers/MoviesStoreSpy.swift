//
//  MoviesStoreSpy.swift
//  MovveTests
//
//  Created by Petar Glusac on 14.4.24..
//

import Foundation
import Movve

final class MoviesStoreSpy: MoviesStore {
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
