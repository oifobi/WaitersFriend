//
//  FileManager.swift
//  CO2
//
//  Created by Simon Italia on 10/8/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import Foundation

protocol FavoriteDrinksDelegate {
    func update()
}

class DataPersistenceManager {
    
    enum Key {
        static let favorites = "favorites"
    }
    
    
    enum FavoriteAction {
        case add, remove
    }
    
    //Property to access this struct's methods globally
    static var shared = DataPersistenceManager()
    
    let defaults = UserDefaults.standard
    
    //Properties to track favorite drinks and update other VCs when favorites are modified
    var delegate: FavoriteDrinksDelegate?
    
    var favorites = [Drink]() {
        didSet {
            
            //trigger save
            performSaveFavorites()

            //trigger update to delegates
            DataPersistenceManager.shared.delegate?.update()
        }
    }
    
    
    func performSaveFavorites() {
        //save modified favorites object to user defaults
        DataPersistenceManager.shared.save(favorites: DataPersistenceManager.shared.favorites) { (result, error) in

            if let _ = result {}
            if let error = error { print(error.rawValue) }
        }
    }
    

    func save(favorites: [Drink], completion: @escaping (WFSuccess?, WFError?) -> Void) {

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(favorites)

            //Save Data object to UserDefaults
            DataPersistenceManager.shared.defaults.set(data, forKey: Key.favorites)
            completion(.favoritesSaved, nil)

        //If save failed handle error
        } catch { completion(nil, .unableToSaveFavorites) }
    }
    
    
    func loadSavedFavorites(_ completion: @escaping (Result<WFSuccess, WFError>) -> Void) {
        
        guard let data = DataPersistenceManager.shared.defaults.object(forKey: "favorites") as? Data else {
            completion(.success(.noFavorites))
            return
        }
        
        do {
            let encoder = JSONDecoder()
            DataPersistenceManager.shared.favorites = try encoder.decode([Drink].self, from: data)
            
            if DataPersistenceManager.shared.favorites.isEmpty {
                completion(.success(.noFavorites))
            
            } else  { completion(.success(.favoritesLoaded)) }
            
            
        } catch {
            completion(.failure(.unableToDecodeFavorites))
        }
    }
    
    
    func updateFavorites(with drink: Drink, completion: @escaping (WFSuccess) -> Void) {
        
        //remove
        if let index = getIndexOf(favorite: drink) {
            DataPersistenceManager.shared.favorites.remove(at: index)
            completion(.favoriteRemoved)
            
        //add
        } else {
            DataPersistenceManager.shared.favorites.append(drink)
            completion(.favoriteAdded)
        }
    }
    
    
    func getIndexOf(favorite drink: Drink) -> Int? {
        for (index, favorite) in DataPersistenceManager.shared.favorites.enumerated() {
            if favorite.id == drink.id {
               return index
            }
        }
        
        return nil
    }
    
    
//MARK:- ---New---
    func performSaveFavorites2() {
        //save modified favorites object to user defaults
        DataPersistenceManager.shared.save2(favorites: DataPersistenceManager.shared.favorites) { (result) in

            switch result {
            case .success(let message):
                print(message.rawValue)
                
            case .failure(let error):
                print(error.rawValue)
            }
        }
    }
    
    
    func save2(favorites: [Drink], completion: @escaping (Result<WFSuccess, WFError>) -> Void ) {

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(favorites)

            //Save Data object to UserDefaults
            DataPersistenceManager.shared.defaults.set(data, forKey: Key.favorites)
            completion(.success(.favoritesSaved))

        //If save failed handle error
        } catch {
            completion(.failure(.unableToSaveFavorites))
        }
    }
    
    
    func updateFavorites2(with drink: Drink, action: FavoriteAction, completion: @escaping (WFSuccess) -> Void) {
        
        switch action {
        case .remove:
            remove(favorite: drink)
            completion(.favoriteRemoved)
            
        case .add:
            add(favorite: drink)
            completion(.favoriteAdded)
        }
    }
    
    
    func add(favorite drink: Drink) {
        DataPersistenceManager.shared.favorites.append(drink)
    }
    
    
    func remove(favorite drink: Drink) {
        if let index = getIndexOf(favorite: drink) {
            DataPersistenceManager.shared.favorites.remove(at: index)
        }
    }
}
