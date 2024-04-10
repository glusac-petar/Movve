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
    func insert(_ movies: [LocalMovie], timestamp: Date, completion: @escaping InsertionCompletion)
}

public struct LocalMovie: Equatable {
    public let id: Int
    public let imagePath: String
    
    public init(id: Int, imagePath: String) {
        self.id = id
        self.imagePath = imagePath
    }
}
