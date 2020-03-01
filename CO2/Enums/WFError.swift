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
    
    //favorites related errors
    case unableToSaveFavorite = "Error adding Drink to Favorites."
    case favoriteAlreadySaved = "Drink already saved in Favorites" //not expected to fire, fringe case
    case unableToDecodeFavorites = "Error decoding saved Favorites data object."
}
