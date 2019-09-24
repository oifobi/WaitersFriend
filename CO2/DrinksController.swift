//
//  NetworkController.swift
//  CO2
//
//  Created by Simon Italia on 9/10/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import Foundation
import UIKit

public class DrinksController {
    
    //Global Property for VCs to access DrinkController methods
    static let shared = DrinksController()
    
    //Global property for VCs to store fetched data when called (set by callling VC)
    static var drinks: [Drink]? 
    
    //API end points and Url struturing
    static let popular = "/popular.php" // UI tag: 0 = Most Top rated
    static let recent = "/recent.php" // UI tag: 1 = Recents
    static let random = "/random.php" // UI tag: 2 = Featured
    
    //MARK:- Fetch data from given API end point based on list parameter passed in (set by user tab bar item selected)
    
    //Setup construction of URL
    func constructURLComponents() -> URLComponents {
        
        //API connectivity properties
        let apiKey = "8673533"
        let baseURLString = "www.thecocktaildb.com"
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = baseURLString
        components.path = "/api/json/v2/"+apiKey
        return components
    }
    
    //Fetch Drink Details
    func fetchDrinks(from endpoint: String, _ completion: @escaping ([Drink]?, Error?) -> Void)  {
        
        guard endpoint != "" else { return }
        
        //Create URL object and append endpoint
        let components = constructURLComponents()
        let url = components.url!.appendingPathComponent(endpoint)
        
        print("API endpoint: \(String(describing: url))\n")
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error == nil && data != nil {
                
                do {
                    let decoder = JSONDecoder()
                    
                    //map data fetched to Drink object
                    let drinks = try decoder.decode(Drinks.self, from: data!)
//                    print("json fetched successfully with data: \(json)\n")
                    
                    //Pass drinks back to caller
                    completion(drinks.drinks, nil)
                    
                //catch and print errors to console
                } catch {
                    print("Couldn't decode JSON data with error: \(error.localizedDescription)\n")
                    completion(nil, error)
                    return
                }
            } else if error != nil || data == nil {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
    //Fetch Drink images
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
    
    //Fetch List type (generic method to fetch any list type)
    func fetchList(from endpoint: String, using query: URLQueryItem, completion: @escaping ([List]?, Error?) -> Void) {
//        guard query != "" else { return }
        
        //Create URL object with querry item/s and append endpoint
        var components = constructURLComponents()
        components.queryItems = [query]
        
        let url = components.url!.appendingPathComponent(endpoint)
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            let jsonDecoder = JSONDecoder()
            if let data = data,
                
                let lists = try? jsonDecoder.decode(Lists.self, from: data) {
                completion(lists.list, nil)
                
            } else {
                if let error = error {
                    print("Couldn't decode JSON data with error: \(error.localizedDescription)\n")
                    completion(nil, error)
                }
            }
        }
        
        task.resume()
    }
}

