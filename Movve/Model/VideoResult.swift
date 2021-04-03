//
//  VideoResult.swift
//  Movve
//
//  Created by Petar Glusac on 1.4.21..
//

import Foundation

struct VideoResult: Decodable {
    let key: String
    let site: String
    let type: String
}

struct VideoResults: Decodable {
    let results: [VideoResult]
}
