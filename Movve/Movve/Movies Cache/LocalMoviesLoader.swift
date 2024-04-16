//
//  LocalMoviesLoader.swift
//  Movve
//
//  Created by Petar Glusac on 9.4.24..
//

import Foundation

private final class MoviesCachePolicy {
    private let currentDate: () -> Date
    private let calendar = Calendar(identifier: .gregorian)
    
    init(currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
    }
    
    private var maxCacheAgeInDays: Int {
        return 7
    }
    
    func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: 7, to: timestamp) else {
            return false
        }
        return currentDate() < maxCacheAge
    }
}

public final class LocalMoviesLoader {
    private let store: MoviesStore
    private let currentDate: () -> Date
    private let moviesCachePolicy: MoviesCachePolicy
    
    public init(store: MoviesStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
        self.moviesCachePolicy = MoviesCachePolicy(currentDate: currentDate)
    }
}

extension LocalMoviesLoader {
    public typealias SaveResult = Error?
    
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
        store.insert(movies.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}
    
extension LocalMoviesLoader: MoviesLoader {
    public typealias LoadResult = Result<[Movie], Error>
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .found(movies: movies, timestamp: timestamp) where moviesCachePolicy.validate(timestamp):
                completion(.success(movies.toModels()))
                
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
}
 
extension LocalMoviesLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                store.deleteCachedMovies { _ in }
                
            case let .found(movies: _, timestamp: timestamp) where !moviesCachePolicy.validate(timestamp):
                store.deleteCachedMovies { _ in }
            
            case .found, .empty:
                break
            }
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
