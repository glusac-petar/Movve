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
    private let calendar = Calendar(identifier: .gregorian)
    
    public typealias SaveResult = Error?
    public typealias LoadResult = Result<[Movie], Error>
    
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
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [unowned self] result in
            switch result {
            case let .failure(error):
                store.deleteCachedMovies { _ in }
                completion(.failure(error))
                
            case let .found(movies: movies, timestamp: timestamp) where validate(timestamp):
                completion(.success(movies.toModels()))
                
            case .found:
                store.deleteCachedMovies { _ in }
                completion(.success([]))
                
            case .empty:
                completion(.success([]))
            }
        }
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: 7, to: timestamp) else {
            return false
        }
        return currentDate() < maxCacheAge

    }
    
    private func cache(_ movies: [Movie], with completion: @escaping (SaveResult) -> Void) {
        store.insert(movies.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}

private extension Array where Element == Movie {
    func toLocal() -> [LocalMovie] {
        return map { LocalMovie(id: $0.id, imagePath: $0.imagePath) }
    }
}

private extension Array where Element == LocalMovie {
    func toModels() -> [Movie] {
        return map { Movie(id: $0.id, imagePath: $0.imagePath) }
    }
}
