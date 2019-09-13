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
    func jsonFetched(_ drinks: [Drink])
    
}

public class DrinksController {
    
    static let shared = DrinksController()
    
    //API end points
    static let popular = "/popular.php" // UI tag: 0
    static let recent = "/recent.php" // UI tag: 1
    static let random = "/random.php" // UI tag: 2
    
    //API connectivity properties
    let apiKey = "8673533"
    let baseURLString = "https://www.thecocktaildb.com/api/json/v2/"
    
    //set protocol delegate to communicate with ViewController
    var delegate: DrinkProtocol?
    
    //Fetch data from given API end point based on list parameter passed in (set by user tab bar item selected)
    func fetchDrinks(list: String) {
        
        //Create URL object
        let url = URL(string: baseURLString+apiKey)?.appendingPathComponent(list)
        print("API endpoint: \(String(describing: url))")
        
        //ensure urlObject is not nil nor has encountered an error
        guard url != nil else {
            print("Couldn't create Url object")
            return
        }
        
        let urlSession = URLSession.shared
        let dataTask = urlSession.dataTask(with: url!) { (data, response, error) in
            
            if error == nil && data != nil {
                
                do {
                    let decoder = JSONDecoder()
                    let jsonResults = try decoder.decode(Drinks.self, from: data!)
                    let drinks = jsonResults.drinks!
                    print("Drinks list succesfully fetched with content: \(drinks)")
                    
                    //Pass results back to meain thread / ViewController via delegate property
                    DispatchQueue.main.async {
                        self.delegate?.jsonFetched(drinks)
                    }
                
                //catch and print errors to console
                } catch {
                    print("Couldn't decode JSON data with error: \(error.localizedDescription)")
                    return
                }
            }
        }
        dataTask.resume()
    }
    
    //Fetch drink images
    func fetchDrinkImage(from url: String, completion: @escaping (UIImage?) -> Void) {

        if let urlString = URL(string: url) {
            let task = URLSession.shared.dataTask(with: urlString) {
                (data, response, error) in
                
                if let data = data,
                    let image = UIImage(data: data) {
                    completion(image)
                    
                } else {
                    completion(nil)
                }
            }
            
            task.resume()
        }
    }
    
}

