//
//  LocalMoviesLoader.swift
//  Movve
//
//  Created by Petar Glusac on 9.4.24..
//

import Foundation

public final class LocalMoviesLoader {
    private let store: MoviesStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    
    public init(store: MoviesStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ movies: [Movie], with completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedMovies { [weak self] deletionError in
            guard let self = self else { return }
            
            if let deletionError = deletionError {
                completion(deletionError)
            } else {
                self.cache(movies, with: completion)
            }
        }
    }
    
    private func cache(_ movies: [Movie], with completion: @escaping (SaveResult) -> Void) {
        store.insert(movies, timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}

public protocol MoviesStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedMovies(completion: @escaping DeletionCompletion)
    func insert(_ movies: [Movie], timestamp: Date, completion: @escaping InsertionCompletion)
}
