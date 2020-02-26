//
//  FileManager.swift
//  CO2
//
//  Created by Simon Italia on 10/8/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import Foundation

protocol FavoriteDrinksDelegate {
    func updateDrinks(with favorites: [Drink])
}

class FavoritesController {
    
    //Property to access this struct's methods globally
    static var shared = FavoritesController()
    
    //Properties to track favorite drinks and update other VCs when favorites are modified
    var delegate: FavoriteDrinksDelegate?
    static var favorites = [Drink]() {
        
        //Detect when drinks object is modified
        didSet {
            self.shared.delegate?.updateDrinks(with: favorites)
            print("Drinks object modified. Count is: \(favorites.count)\n")
        }
    }
    
    func getDrinkIndex(for drinkID: String) -> Int? {
        guard FavoritesController.favorites.count > 0 else { return nil }
        
        for (index, drink) in FavoritesController.favorites.enumerated() {
            if drinkID == drink.id {
                return index
            }
        }
        return nil
    }
    
    func saveFavorites(_ completion: @escaping (String?, Error?) -> Void) {
        do {
            let encoder = JSONEncoder()
            let favorites = try encoder.encode(FavoritesController.favorites)
                    
            //Save Data object to UserDefaults
            let defaults = UserDefaults.standard
            defaults.set(favorites, forKey: "favorites")
            completion("Success! drinks object succeesfully saved\n", nil)
        
        //If save failed handle error
        } catch {
            completion(nil, error)
        }
    }
    
    func loadFavorites(_ completion: @escaping (String?, Error?) -> Void) {
        let defaults = UserDefaults.standard
        if let favorites = defaults.object(forKey: "favorites") as? Data {
            let encoder = JSONDecoder()
            
            do {
                FavoritesController.favorites = try encoder.decode([Drink].self, from: favorites)
                completion("Success! drinks object succeesfully loaded from user defaults\n", nil)
                
            } catch {
//                print("Failed! drinks object failed to load from user defualts with error: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
    }
}
