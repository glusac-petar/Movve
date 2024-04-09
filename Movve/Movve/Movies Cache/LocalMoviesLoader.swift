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
        store.deleteCachedMovies { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                completion(error)
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
