//
//  NetworkManager.swift
//  Movve
//
//  Created by Petar Glusac on 24.3.21..
//

import UIKit
import Alamofire
import AlamofireImage

enum MediaType: String, Codable {
    case movie = "movie", tvShow = "tv"
}

class NetworkManager {
    
    private let infoBaseUrl = "https://api.themoviedb.org/3"
    private let imageBaseUrl = "https://image.tmdb.org/t/p/w500"
    private let cache = AutoPurgingImageCache()
    
    static let shared = NetworkManager()
    
    private init() {}
    
    func getPopular(completed: @escaping (BasicResult?) -> Void) {
        AF.request("\(infoBaseUrl)/discover/movie?api_key=b00dc2e39fd4cc23884c5735882d65a8").responseData { (response) in
            guard let data = response.data, response.error == nil else {
                completed(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try decoder.decode(BasicResults.self, from: data)
                let result = decodedData.results.first {$0.posterPath != nil && $0.backdropPath != nil}
                completed(result)
            } catch { completed(nil) }
        }
    }
    
    func getUpcoming(completed: @escaping ([BasicResult]?) -> Void) {
        AF.request("\(infoBaseUrl)/movie/upcoming?region=US&api_key=b00dc2e39fd4cc23884c5735882d65a8").responseData { (response) in
            guard let data = response.data, response.error == nil else {
                completed(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try decoder.decode(BasicResults.self, from: data)
                let result = decodedData.results.filter {$0.posterPath != nil && $0.backdropPath != nil}
                completed(result)
            } catch { completed(nil) }
        }
    }
    
    func getPopular(type: MediaType, completed: @escaping ([BasicResult]?) -> Void) {
        let endpoint = type == .movie ? "\(infoBaseUrl)/movie/now_playing?region=US&api_key=b00dc2e39fd4cc23884c5735882d65a8" : "\(infoBaseUrl)/tv/popular?region=US&api_key=b00dc2e39fd4cc23884c5735882d65a8"
        AF.request(endpoint).responseData { (response) in
            guard let data = response.data, response.error == nil else {
                completed(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try decoder.decode(BasicResults.self, from: data)
                let result = decodedData.results.filter {$0.posterPath != nil && $0.backdropPath != nil}
                completed(result)
            } catch { completed(nil) }
        }
    }
    
    func getMovieDetails(id: Int, completed: @escaping (DetailedMovieResult?) -> Void) {
        AF.request("\(infoBaseUrl)/movie/\(id)?api_key=b00dc2e39fd4cc23884c5735882d65a8").responseData { (response) in
            guard let data = response.data, response.error == nil else {
                completed(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try decoder.decode(DetailedMovieResult.self, from: data)
                completed(decodedData)
            } catch { completed(nil) }
        }
    }
    
    func getTrailer(type: MediaType, id: Int, completed: @escaping (VideoResult?) -> Void) {
        AF.request("\(infoBaseUrl)/\(type.rawValue)/\(id)/videos?api_key=b00dc2e39fd4cc23884c5735882d65a8").responseData { (response) in
            guard let data = response.data, response.error == nil else {
                completed(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try decoder.decode(VideoResults.self, from: data)
                let result = decodedData.results.filter { $0.site == "YouTube" && $0.type == "Trailer" }.first
                completed(result)
            } catch { completed(nil) }
        }
    }
    
    func getTVShowDetails(id: Int, completed: @escaping (DetailedShowResult?) -> Void) {
        AF.request("\(infoBaseUrl)/tv/\(id)?api_key=b00dc2e39fd4cc23884c5735882d65a8").responseData { (response) in
            guard let data = response.data, response.error == nil else {
                completed(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try decoder.decode(DetailedShowResult.self, from: data)
                completed(decodedData)
            } catch { completed(nil) }
        }
    }
    
    func getCast(type: MediaType, id: Int, completed: @escaping ([CastResult]?) -> Void) {
        AF.request("\(infoBaseUrl)/\(type.rawValue)/\(id)/credits?api_key=b00dc2e39fd4cc23884c5735882d65a8").responseData { (response) in
            guard let data = response.data, response.error == nil else {
                completed(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try decoder.decode(CreditsResult.self, from: data)
                let result = decodedData.cast.filter { $0.profilePath != nil }.prefix(10)
                completed(Array(result))
            } catch { completed(nil) }
        }
    }
    
    func getRecommendations(type: MediaType, id: Int, completed: @escaping ([BasicResult]?) -> Void) {
        AF.request("\(infoBaseUrl)/\(type.rawValue)/\(id)/recommendations?api_key=b00dc2e39fd4cc23884c5735882d65a8").responseData { (response) in
            guard let data = response.data, response.error == nil else {
                completed(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try decoder.decode(BasicResults.self, from: data)
                let result = decodedData.results.filter { $0.posterPath != nil && $0.backdropPath != nil }.prefix(10)
                completed(Array(result))
            } catch { completed(nil) }
        }
    }
    
    func multipleSearch(query: String, page: Int, completed: @escaping ([SearchResult]?) -> Void) {
        AF.request("\(infoBaseUrl)/search/multi?query=\(query)&page=\(page)&api_key=b00dc2e39fd4cc23884c5735882d65a8").responseData { (response) in
            guard let data = response.data, response.error == nil else {
                completed(nil)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try decoder.decode(SearchResults.self, from: data)
                let result = decodedData.results.filter { $0.posterPath != nil && $0.backdropPath != nil }
                completed(result)
            }
            catch { completed(nil) }
        }
    }
    
    func downloadImage(path: String, completed: @escaping (UIImage?) -> Void) {
        if let image = cache.image(withIdentifier: path) {
            completed(image)
            return
        }
        
        AF.request("\(imageBaseUrl)\(path)").responseImage { [weak self] (response) in
            guard let self = self, let image = response.value, response.error == nil else {
                completed(nil)
                return
            }
            self.cache.add(image, withIdentifier: path)
            completed(image)
        }
    }
    
}
