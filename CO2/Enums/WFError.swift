//
//  WFError.swift
//  WaitersFriend
//
//  Created by Simon Italia on 2/26/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import Foundation

enum WFError: String, Error {
    
    //internal / network related
    case invalidURLRequested = "Invalid request encountered.\nPlease try again."
    case unableToCompleteRequest = "Unable to complete request.\nPlease check internet connection."
    case invalidServerResposne = "Invalid response from server.\nPlease try again."
    case invalidDataReturned = "Data from server was invalid.\nPlease try again."
    
    //user facing
    case unableToDecodeData = "No Results.\nPlease try another search."
    
    //favorites related
    case unableToSaveFavorites = "Error saving Favorites object to user defaults."
    case unableToDecodeFavorites = "Error decoding saved Favorites object."
    case unableToUpdateFavorites = "Error updating Favorites"
}
