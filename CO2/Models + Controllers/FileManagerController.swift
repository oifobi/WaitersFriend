//
//  FileManager.swift
//  CO2
//
//  Created by Simon Italia on 10/8/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import Foundation

struct FileManagerController: Codable {
    
    //Propeerty to access this struct's properties globally
    static var shared = FileManagerController()
    
    //Properties to track favorited drinks
//    static var drinkIDs = [String]()
    static var drinks = [Drink]() {
        
        //Detect when drinks object is modified
        didSet {
            print("Drinks object count \(drinks.count)\n")
        }
    }
    
    func getDrinkIndex(for drinkID: String) -> Int? {
        guard FileManagerController.drinks.count > 0 else { return nil }
        
        for (index, drink) in FileManagerController.drinks.enumerated() {
            if drinkID == drink.id {
                return index
            }
        }
        return nil
    }
    
    func saveDrinks(_ completion: @escaping (String?, Error?) -> Void) {

        do {
            let encoder = JSONEncoder()
            let favorites = try encoder.encode(FileManagerController.drinks)
                    
            //Save Data object to UserDefaults
            let defaults = UserDefaults.standard
            defaults.set(favorites, forKey: "favorites")
            completion("Success! drinks object succeesfully saved\n", nil)
        
        //If save failed handle error
        } catch {
            completion(nil, error)
        }
    }
    
    func loadDrinks(_ completion: @escaping (String?, Error?) -> Void) {
        
        let defaults = UserDefaults.standard
        if let favorites = defaults.object(forKey: "favorites") as? Data {
            let encoder = JSONDecoder()
            
            do {
                FileManagerController.drinks = try encoder.decode([Drink].self, from: favorites)
                completion("Success! drinks object succeesfully loaded from user defaults\n", nil)
                
            } catch {
//                print("Failed! drinks object failed to load from user defualts with error: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
    }
}
