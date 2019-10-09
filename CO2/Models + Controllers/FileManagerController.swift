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
    static var drinks: [Drink]? {
        
        
        //When drinks object is modified, trigger save of drinks data object to disk
        didSet {
            print("Favorite drink saved")
//            saveDrinks()
        }

    }
    
    func saveDrinks(_ completion: @escaping (String?, Error?) -> Void) {
        guard FileManagerController.drinks != nil else { return }

        do {
            let favorites = try NSKeyedArchiver.archivedData(withRootObject: FileManagerController.drinks!,
            requiringSecureCoding: false)
                
                //Save Data object to UserDefaults
                let defaults = UserDefaults.standard
                defaults.set(favorites, forKey: "favorites")
                
                completion("Successfully saved drinks data", nil)
        
        //If save failed handle error 
        } catch {
            completion(nil, error)
        }
    }
    
    func loadDrinks() {
        
    }
    
    
    
    
    
    
}
