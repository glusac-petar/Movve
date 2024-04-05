//
//  HTTPClient.swift
//  Movve
//
//  Created by Petar Glusac on 5.4.24..
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
