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
    case invalidURLRequested = "Invalid request encountered./nPlease try again."
    case unableToCompleteRequest = "Unable to complete request./nPlease check internet connection."
    case invalidServerResposne = "Invalid response from server./nPlease try again."
    case invalidDataReturned = "Data from server was invalid./nPlease try again."
    
    //favorites related errors
    case unableToSaveFavorites = "Error saving Favorites object to user defaults."
    case unableToDecodeFavorites = "Error decoding saved Favorites object."
}
