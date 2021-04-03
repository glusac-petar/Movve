//
//  PersistenceManager.swift
//  Movve
//
//  Created by Petar Glusac on 28.3.21..
//

import Foundation

enum PersistenceActionType {
    case add, remove
}

enum PersistenceManager {
    
    static private let defaults = UserDefaults.standard
    static private let defaultsKey = "favorites"
    
    static func updateWith(favorite: Favorite, actionType: PersistenceActionType, completed: @escaping (MError?) -> Void) {
        retrieveFavorites { (data) in
            var favorites = data
            
            switch actionType {
            case .add:
                guard !favorites.contains(favorite) else {
                    completed(.alreadyInFavorites)
                    return
                }
                favorites.append(favorite)
            case .remove:
                favorites.removeAll { $0 == favorite }
            }
            completed(save(favorites: favorites))
        }
    }
    
    static func retrieveFavorites(completed: @escaping ([Favorite]) -> Void) {
        guard let data = defaults.object(forKey: defaultsKey) as? Data else {
            completed([])
            return
        }
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode([Favorite].self, from: data)
            completed(decodedData)
        } catch { return }
    }
    
    
    static private func save(favorites: [Favorite]) -> MError? {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(favorites)
            defaults.set(encodedData, forKey: defaultsKey)
        } catch { return .unableToFavorite}
        return nil
    }
    
}
