//
//  DrinkDetailsVCExtension.swift
//  CO2
//
//  Created by Simon Italia on 10/11/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import Foundation

//Protocol delegate method to update drinks property when user modifies favorites from DrinksTableVC (Favorites mode)
extension DrinksTableViewController: FavoriteDrinksDelegate {
    func updateDrinks(with favorites: [Drink]) {
        self.drinks = favorites
        updateUI()
        print("FavoriteDrinksController delegate pattern executed")
    }
}
