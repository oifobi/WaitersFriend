//
//  WFAlertMessages.swift
//  WaitersFriend
//
//  Created by Simon Italia on 2/27/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import Foundation

enum WFSuccess: String {
    
    //internal / debugging
    case favoritesSaved = "Favorites object successfully saved to user defaults"
    case favoritesLoaded = "Favorites object succeesfully loaded from user defaults"
    
    //user facing
    case favoriteAdded = "saved to Favorites."
    case favoriteRemoved = "removed from Favorites."
    case noFavorites = "You have 0 Favorites.\nTap 💜 on the Cocktail Details screen to add Favorites."
}
