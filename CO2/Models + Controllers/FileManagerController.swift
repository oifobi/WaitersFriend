//
//  FileManager.swift
//  CO2
//
//  Created by Simon Italia on 10/8/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import Foundation

struct FileManagerController: Codable {
    
    //Propeerty to access this classes properties globally
    static var shared = FileManagerController()
    
    //Properties to track favorited drinks
    static var drinkIDs = [String]()
    static var drinks = [Drink]() {
        
        //When drinks object is modified, trigger save of drinks data object to disk
        didSet {
//            print("Favorite drink saved")
            FileManagerController.shared.save() { (message, error) in
                if let message = message {
                    print(message)
                    
                } else {
                    if let error = error {
                        print("Failed! drinks object failed to save with error: \(error.localizedDescription)\n")
                    }
                }
            }
            
            print("Drinks object count \(drinks.count)\n")
        }
    }
    
    func save(_ completion: @escaping (String?, Error?) -> Void) {

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
    
    
    func loadDrinks() {
        
    }

}
