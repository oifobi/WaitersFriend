//
//  NetworkController.swift
//  CO2
//
//  Created by Simon Italia on 9/10/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import Foundation
import UIKit

protocol DrinkProtocol {
    func json(fetched drinks: [Drink])
    
}

public class DrinksController {
    
    //set protocol delegate to communicate with ViewController
    var delegate: DrinkProtocol?
    static let shared = DrinksController()
    
    //API end points
    static let popular = "/popular.php" // UI tag: 0 = Top Rated
    static let recent = "/recent.php" // UI tag: 1 = Recents
    static let random = "/random.php" // UI tag: 2 = Featured
    
    //API connectivity properties
    let apiKey = "8673533"
    let baseURLString = "https://www.thecocktaildb.com/api/json/v2/"
    
    //Fetch data from given API end point based on list parameter passed in (set by user tab bar item selected)
    func fetchDrinks(from endpoint: String, _ completion: @escaping (Error?) -> Void)  {
        
        guard endpoint != "" else { return }
        
        //Create URL object
        let url = URL(string: baseURLString+apiKey)?.appendingPathComponent(endpoint)
        print("API endpoint: \(String(describing: url))")
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error == nil && data != nil {
                
                do {
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(Drinks.self, from: data!)
                        //map data fetched to Drink object
                    print("json fetched successfully with data: \(json)")
                    
                    let drinks = json.drinks!
                    print("Drinks list succesfully fetched with content: \(drinks)")
                    
                    //Pass results back to meain thread / ViewController
                    //via delegate property
                    DispatchQueue.main.async {
                        self.delegate?.json(fetched: drinks)
                    }
                    
                //catch and print errors to console
                } catch {
                    print("Couldn't decode JSON data with error: \(error.localizedDescription)")
                    completion(error)
                    return
                }
            } else if error != nil || data == nil {
                completion(error)
            }
            
        }
        
        task.resume()
      
    }
    
    //Fetch drink images
    func fetchDrinkImage(with url: String, completion: @escaping (UIImage?, Error?) -> Void) {

        if let urlString = URL(string: url) {
            let task = URLSession.shared.dataTask(with: urlString) {
                (data, response, error) in
                
                if let data = data,
                    let image = UIImage(data: data) {
                    completion(image, nil)
                    
                } else {
                    completion(nil, error)
                }
            }
            task.resume()
        }
    }
    
    
    
}

