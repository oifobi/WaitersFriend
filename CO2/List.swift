//
//  BaseIngredient.swift
//  CO2
//
//  Created by Simon Italia on 9/24/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import Foundation

//Generic Collection of different list types (ie: base ingredients, drink types, glass types etc)
struct List: Codable  {
    var ingredients: String?
    
    enum CodingKeys: String, CodingKey {
        case ingredients = "strIngredient1"
    }
}

struct Lists: Codable {
    var list: [List]
    
    enum CodingKeys: String, CodingKey {
        case list = "drinks"
    }
}

//
struct BaseIngredient: Codable {
    let ingredient: String
    
    enum CodingKeys: String, CodingKey {
        case ingredient = "strIngredient1"
    }
}

struct BaseIngredients: Codable {
    var ingredients: [BaseIngredient]
    
    enum CodingKeys: String, CodingKey {
        case ingredients = "drinks"
    }
    
}
