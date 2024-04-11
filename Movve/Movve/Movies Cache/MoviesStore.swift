//
//  MoviesStore.swift
//  Movve
//
//  Created by Petar Glusac on 9.4.24..
//

import Foundation

public enum RetrievalResult {
    case empty
    case found(movies: [LocalMovie], timestamp: Date)
    case failure(Error)
}

public protocol MoviesStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    func deleteCachedMovies(completion: @escaping DeletionCompletion)
    func insert(_ movies: [LocalMovie], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
