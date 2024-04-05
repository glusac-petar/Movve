//
//  MoviesLoader.swift
//  Movve
//
//  Created by Petar Glusac on 5.4.24..
//

import Foundation

protocol MoviesLoader {
    typealias Result = Swift.Result<[Movie], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
