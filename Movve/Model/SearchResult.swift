//
//  SearchResult.swift
//  Movve
//
//  Created by Petar Glusac on 31.3.21..
//

import Foundation

struct SearchResult: Decodable {
    let id: Int
    var mediaType: String
    var title: String
    var releaseDate: String?
    var posterPath: String?
    var backdropPath: String?
    
    private enum MovieKeys: String, CodingKey {
        case id = "id"
        case mediaType = "mediaType"
        case title = "title"
        case releaseDate = "releaseDate"
        case posterPath = "posterPath"
        case backdropPath = "backdropPath"
    }
    
    private enum TVShowKeys: String, CodingKey {
        case id = "id"
        case mediaType = "mediaType"
        case title = "name"
        case releaseDate = "firstAirDate"
        case posterPath = "posterPath"
        case backdropPath = "backdropPath"
    }
    
    private enum PersonKeys: String, CodingKey {
        case mediaType = "mediaType"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: PersonKeys.self)
        if let mediaType = try values.decodeIfPresent(String.self, forKey: .mediaType), mediaType == "person" {
            self.id = Int()
            self.mediaType = mediaType
            self.title = String()
            self.releaseDate = String()
            self.posterPath = nil
        }
        else {
            let values = try decoder.container(keyedBy: MovieKeys.self)
            if let title = try values.decodeIfPresent(String.self, forKey: .title) {
                self.id = try values.decodeIfPresent(Int.self, forKey: .id)!
                self.mediaType = try values.decodeIfPresent(String.self, forKey: .mediaType)!
                self.title = title
                self.releaseDate = try values.decodeIfPresent(String.self, forKey: .releaseDate)
                self.posterPath = try values.decodeIfPresent(String.self, forKey: .posterPath)
                self.backdropPath = try values.decodeIfPresent(String.self, forKey: .backdropPath)
            } else {
                let values = try decoder.container(keyedBy: TVShowKeys.self)
                self.id = try values.decodeIfPresent(Int.self, forKey: .id)!
                self.mediaType = try values.decodeIfPresent(String.self, forKey: .mediaType)!
                self.title = try values.decodeIfPresent(String.self, forKey: .title)!
                self.releaseDate = try values.decodeIfPresent(String.self, forKey: .releaseDate)
                self.posterPath = try values.decodeIfPresent(String.self, forKey: .posterPath)
                self.backdropPath = try values.decodeIfPresent(String.self, forKey: .backdropPath)
            }
        }
    }
    
}

struct SearchResults: Decodable {
    let results: [SearchResult]
}
