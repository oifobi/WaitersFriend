//
//  WFError.swift
//  WaitersFriend
//
//  Created by Simon Italia on 2/26/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import Foundation

enum WFError: String, Error {
    
    //network related errors
    case invalidURLRequested = "Invalid request encountered. Please try again."
    case unableToCompleteRequest = "Unable to complete request. Please check internet connection."
    case invalidServerResposne = "Invalid response from server. Please try again."
    case invalidDataReturned = "Data from server was invalid. Please try again."
    
    
    //Favorites related errors
    case unableToAddFavorite = "Error adding user to Favorites."
    case unableToGetFavorite = "Error retrieving Favorites."
    case noFavorites = "You have no favorite drinks.\n To add drinks to Favorites, tap on ❤️ in drink details."
    case favoriteSaved = "saved to Favorites."
    case favoriteRemoved = "removed from Favorites."
}
