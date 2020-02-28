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

class DataPersistenceManager {
    
    //Property to access this struct's methods globally
    static var shared = DataPersistenceManager()
    
    let defaults = UserDefaults.standard
    
    //Properties to track favorite drinks and update other VCs when favorites are modified
    var delegate: FavoriteDrinksDelegate?
    static var favorites = [Drink]() {
        
        //Detect when drinks object is modified
        didSet {
            self.shared.delegate?.updateDrinks(with: favorites)
        }
    }
    
    
    func getDrinkIndex(for drinkID: String) -> Int? {
        guard DataPersistenceManager.favorites.count > 0 else { return nil }
        
        for (index, drink) in DataPersistenceManager.favorites.enumerated() {
            if drinkID == drink.id {
                return index
            }
        }
        return nil
    }
    
    
    func saveFavorites(_ completion: @escaping (Result<WFSuccess, WFError>) -> Void) {
        
        do {
            let encoder = JSONEncoder()
            let favorites = try encoder.encode(DataPersistenceManager.favorites)
     
            //Save Data object to UserDefaults
            DataPersistenceManager.shared.defaults.set(favorites, forKey: "favorites")
            completion(.success(.favoriteSaved))
        
        //If save failed handle error
        } catch {
            completion(.failure(.unableToSaveFavorite))
        }
    }
    
    
    func loadFavorites(_ completion: @escaping (Result<WFSuccess, WFError>) -> Void) {
        
        guard let favorites = DataPersistenceManager.shared.defaults.object(forKey: "favorites") as? Data else {
            completion(.failure(.unableToLoadFavorites))
            return
        }
        
        do {
            let encoder = JSONDecoder()
            DataPersistenceManager.favorites = try encoder.decode([Drink].self, from: favorites)
            completion(.success(.favoritesLoaded))
            
        } catch {
            completion(.failure(.unableToDecodeFavorites))
        }
    }
}
