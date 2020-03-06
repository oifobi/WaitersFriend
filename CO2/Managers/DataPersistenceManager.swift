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
    
    
    public enum FavoriteAction {
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
    

    func performSaveFavorites() {
        //save modified favorites object to user defaults
        DataPersistenceManager.shared.save(favorites: DataPersistenceManager.shared.favorites) { (result) in

            switch result {
            case .success(let message):
                print(message.rawValue)
                
            case .failure(let error):
                print(error.rawValue)
            }
        }
    }
    
    
    func save(favorites: [Drink], completion: @escaping (Result<WFSuccess, WFError>) -> Void ) {

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
    
    
    func updateFavorites(with drink: Drink, action: FavoriteAction, completion: @escaping (Result<WFSuccess, WFError>) -> Void) {
        
        switch action {
        case .remove:
            if let error = removeFavorite(with: drink.id) {
                completion(.failure(error))
            }
            
            completion(.success(.favoriteRemoved))
        
        case .add:
            add(favorite: drink)
            completion(.success(.favoriteAdded))
        }
    }
    
    
    func add(favorite drink: Drink) {
        DataPersistenceManager.shared.favorites.append(drink)
    }
    
    
    func removeFavorite(with id: String) -> WFError? {
        if let index = getIndexOfFavorite(for: id)  {
            DataPersistenceManager.shared.favorites.remove(at: index)
            return nil
        }
        
        return WFError.unableToUpdateFavorites
    }
    
    
    func getIndexOfFavorite(for id: String) -> Int? {
        for (index, favorite) in DataPersistenceManager.shared.favorites.enumerated() {
            if favorite.id == id {
               return index
            }
        }
        
        return nil
    }
}
