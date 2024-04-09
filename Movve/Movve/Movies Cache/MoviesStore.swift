//
//  MoviesStore.swift
//  Movve
//
//  Created by Petar Glusac on 9.4.24..
//

import Foundation

public protocol MoviesStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedMovies(completion: @escaping DeletionCompletion)
    func insert(_ movies: [Movie], timestamp: Date, completion: @escaping InsertionCompletion)
}
