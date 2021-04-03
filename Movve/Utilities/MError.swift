//
//  MError.swift
//  Movve
//
//  Created by Petar Glusac on 24.3.21..
//

import Foundation

enum MError: String, Error {
    
    case unableToComplete = "Unable to complete your request. Please check your internet connection."
    case invalidData = "The data received from the server was invalid. Please try again."
    case unableToFavorite = "There was an error favoriting this item. Please try again."
    case alreadyInFavorites = "This item is already in your favorites list."
    
}
