//
//  BaseIngredient.swift
//  CO2
//
//  Created by Simon Italia on 9/24/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import Foundation

struct DrinkListType: Codable {
    var type: [DrinkList]
    
    enum CodingKeys: String, CodingKey {
        case type = "drinks"
    }
}

//Generic Collection of different list types (ie: base ingredients, drink types, glass types etc)
struct DrinkList: Codable  {
    
    //Base Ingredient List properties
    let baseIngredient: String?
    
    //Base Ingredient Drinks List properties
    let id: String?
    let name: String?
    let imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "idDrink"
        case name = "strDrink"
        case imageURL = "strDrinkThumb"
        case baseIngredient = "strIngredient1"
    }
}


