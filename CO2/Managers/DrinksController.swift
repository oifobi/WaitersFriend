//
//  NetworkController.swift
//  CO2
//
//  Created by Simon Italia on 9/10/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

//API end points and Url struturing
enum EndPoint: String {
    
    //Absolute endpoints
    case random = "/random.php"
    case popular = "/popular.php"
    case recent = "/recent.php"
    
    //Endpoints for use with Queries
    case search = "/search.php"
    case lookup = "/lookup.php"
    case filter = "/filter.php"
    case list = "/list.php"
}

enum QueryType: String {
    
    case drinkName = "s"
    case firstLetter = "f"
    case ingredient = "i"
    case category = "c"
    case glass = "g"
}

public class DrinksController {
    
    //Global Property for VCs to access DrinkController methods
    static let shared = DrinksController()
    
    //MARK:- Fetch data from given API end point based on list parameter passed in (set by user tab bar item selected)
    //Setup construction of URL
    func constructURLComponents() -> URLComponents {
        
        //API connection properties
        let apiKey = "8673533"
        let baseURLString = "www.thecocktaildb.com"
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = baseURLString
        components.path = "/api/json/v2/"+apiKey
        return components
    }
    
    //Fetch Drink Details
    func fetchDrinks(from endpoint: String, using queryItems: [URLQueryItem]?, _ completion: @escaping ([Drink]?, Error?) -> Void)  {
        guard endpoint != "" else { return }
        
        //Create URL object and append endpoint
        var components = constructURLComponents()
        let url: URL
        
        switch queryItems {
        case nil:
            url = components.url!.appendingPathComponent(endpoint)
            
        default:
            components.queryItems = queryItems
            url = components.url!.appendingPathComponent(endpoint)
        }
        
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
        
        //check cache for image, load if cached
        let imageCacheKey = NSString(string: url)
        if let image = CacheManager.shared.imageCache.object(forKey: imageCacheKey) {
            completion(image, nil)
            print("Image loaded from cache")
            return
        }
        
        //fetch image from remote server
        guard let urlString = URL(string: url) else { return }

        let task = URLSession.shared.dataTask(with: urlString) {
            (data, response, error) in
            
            if let data = data {
                if let image = UIImage(data: data) {
                    
                    //save image to cache with url to image as key
                    CacheManager.shared.imageCache.setObject(image, forKey: imageCacheKey)
                    print("Image saved to cache")
                    
                    completion(image, nil)
                
                } else {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    //Fetch List type (generic method to fetch any list type)
    func fetchList(from path: String, using queryItems: [URLQueryItem], completion: @escaping ([DrinkList]?, Error?) -> Void) {
        
        //Create URL object with querry item/s and append endpoint
        var components = constructURLComponents()
        components.queryItems = queryItems
        
        let url = components.url!.appendingPathComponent(path)
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            let jsonDecoder = JSONDecoder()
            if let data = data,
                
                let list = try? jsonDecoder.decode(DrinkListType.self, from: data) {
                completion(list.type, nil)
                
            } else {
                if let error = error {
                    print("Couldn't decode JSON data with error: \(error.localizedDescription)\n")
                    completion(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    //Fetch drink details by drink id lookup
    func fetchDrink(from path: String, using queryItems: [URLQueryItem]?, completion: @escaping (Drink?, Error?) -> Void) {
        
        //Create URL object and append endpoint as needed
        var components = constructURLComponents()
        let url: URL
        
        switch queryItems {
        case nil:
            url = components.url!.appendingPathComponent(path)
            
        default:
            components.queryItems = queryItems
            url = components.url!.appendingPathComponent(path)
        }
        
        print("API endpoint: \(String(describing: url))\n")
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            let jsonDecoder = JSONDecoder()
            if let data = data,
                
                let drinks = try? jsonDecoder.decode(Drinks.self, from: data) {
                let drink = drinks.drinks?.first
                completion(drink, nil)
                
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

