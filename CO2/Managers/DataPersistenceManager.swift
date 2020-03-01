//
//  FileManager.swift
//  CO2
//
//  Created by Simon Italia on 10/8/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import Foundation

protocol FavoriteDrinksDelegate {
//    func updateDrinks(with favorites: [Drink])
    func update()
}

class DataPersistenceManager {
    
    enum Key {
        static let favorites = "favorites"
    }
    
    enum PersistenceAction {
        case add, remove
    }
    
    //Property to access this struct's methods globally
    static var shared = DataPersistenceManager()
    
    let defaults = UserDefaults.standard
    
    //Properties to track favorite drinks and update other VCs when favorites are modified

//    var favorites = [Drink]()
//    var delegate: FavoriteDrinksDelegate?
//    var favorites = [Drink]() {
//
//        //Detect when drinks object is modified
//        didSet {
////            DataPersistenceManager.self.shared.delegate?.updateDrinks(with: DataPersistenceManager.shared.favorites)
//            DataPersistenceManager.self.shared.delegate?.update()
//        }
//    }
//
//    func isSavedToFavorites(drink: Drink) -> Bool {
//        guard !DataPersistenceManager.shared.favorites.isEmpty else { return false }
//
////        var result = Bool()
//
//        let filtered = DataPersistenceManager.shared.favorites.filter({ $0.id == drink.id })
//        print("Filtered Favorites: \(filtered)")
//
//        let result = filtered.isEmpty
//        print("isSavedToFavorite: \(result)")
//
//        return result
        
//        for favorite in DataPersistenceManager.shared.favorites {
//            return favorite.id == drink.id ? true : false
//        }
        
//        print("isSavedToFavorite: \(result)")
//        return result
//    }
    
    
//    func getDrinkIndex(for drink: Drink) -> Int? {
//        guard !DataPersistenceManager.shared.favorites.isEmpty else { return nil }
//
//        for (index, favorite) in DataPersistenceManager.shared.favorites.enumerated() {
//            if favorite.id == drink.id {
//                return index
//            }
//        }
//
//        return nil
//    }
    
    
//    func addFavorite(drink: Drink) {
//        DataPersistenceManager.shared.favorites.append(drink)
//    }
//
//
//    func removeFavorite(drink: Drink) {
//        guard !DataPersistenceManager.shared.favorites.isEmpty else { return }
//
//        DataPersistenceManager.shared.favorites.removeAll { $0.id == drink.id }
//
////        if let index = DataPersistenceManager.shared.getDrinkIndex(for: drink) {
////            DataPersistenceManager.shared.favorites.remove(at: index)
////        }
//    }
//
//
//    func saveFavorites(_ completion: @escaping (Result<WFSuccess, WFError>) -> Void) {
//
//        do {
//            let encoder = JSONEncoder()
//            let favorites = try encoder.encode(DataPersistenceManager.shared.favorites)
//
//            //Save Data object to UserDefaults
//            DataPersistenceManager.shared.defaults.set(favorites, forKey: Key.favorites)
//            completion(.success(.favoriteSaved))
//
//        //If save failed handle error
//        } catch {
//            completion(.failure(.unableToSaveFavorite))
//        }
//    }
    
    
    func getSavedFavorites(_ completion: @escaping (Result<[Drink], WFError>) -> Void) {
        
        guard let data = DataPersistenceManager.shared.defaults.object(forKey: Key.favorites) as? Data else {
            
            //if no saved favorites data object, return empty array
            completion(.success([]))
            return
        }
        
        do {
            let encoder = JSONDecoder()
            let favorites = try encoder.decode([Drink].self, from: data)
            completion(.success(favorites))
            
        } catch {
            completion(.failure(.unableToDecodeFavorites))
        }
    }
    
    
    func save(favorites data: [Drink]) -> WFError? {

        do {
            let encoder = JSONEncoder()
            let favorites = try encoder.encode(data)
            DataPersistenceManager.shared.defaults.set(favorites, forKey: Key.favorites)
            return nil
            
        } catch {
            return .unableToSaveFavorite
        }
    }
    
    
    func updateFavorites(with favorite: Drink, action: PersistenceAction, completion: @escaping (WFError?) -> Void) { getSavedFavorites { (result) in
                   
           switch result {
           case .success(let savedFavorites):
                var updatedFavorites = savedFavorites
            
                switch action {
                case .add:
                    updatedFavorites.append(favorite)
                   
                case .remove:
                    updatedFavorites.removeAll { $0.id == favorite.id }
               }
               
                //save modified favorites object
                completion(self.save(favorites: updatedFavorites))
           
           case .failure(let error):
               completion(error) //pass the error received from getSavedFavorites to callee
           }
       }
   }
}
