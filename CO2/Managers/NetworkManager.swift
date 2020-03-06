//
//  NetworkController.swift
//  CO2
//
//  Created by Simon Italia on 9/10/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

//API end points and Url struturing
enum NetworkCallEndPoint {
    
    //Absolute endpoints
    static let random = "/random.php"
    static let popular = "/popular.php"
    static let recent = "/recent.php"
    
    //Endpoints for use with Queries
    static let search = "/search.php"
    static let lookup = "/lookup.php"
    static let filter = "/filter.php"
    static let list = "/list.php"
}


enum NetworkCallQueryType {
    static let drinkName = "s"
    static let firstLetter = "f"
    static let ingredient = "i"
    static let category = "c"
    static let glass = "g"
}


class NetworkManager {
    
    //Global Property for VCs to access DrinkController methods
    static let shared = NetworkManager()
    
    
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
    func fetchDrinks(from endpoint: String, using queryItems: [URLQueryItem]?, _ completion: @escaping (Result<[Drink], WFError>) -> Void)  {
        
        //check url is valid, return error if not
        guard let _ = URL(string: endpoint) else {
            completion(.failure(.invalidURLRequested))
            return
        }
        
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
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //handle error cases
            //random network error
            if let _ = error {
                completion(.failure(.unableToCompleteRequest))
                return
            }
            
            //bad http response
            guard let response = response as? HTTPURLResponse, response.statusCode == 200  else {
                completion(.failure(.invalidServerResposne))
                return
            }
            
            //bad data returned, or alternate message like api rate limit exceeded
            guard let data = data else {
                completion(.failure(.invalidDataReturned))
                return
            }
            
            //decode data
            do {
                let decoder = JSONDecoder()
                
                //map data fetched to Drink object
                let drinks = try decoder.decode(Drinks.self, from: data)
                
                //Pass drinks back to caller
                completion(.success(drinks.drinks))
                
            //catch any errrors
            } catch { completion(.failure(.invalidDataReturned)) }
            
        }
        
        task.resume()
    }
    
    
    //Fetch Drink images
    func fetchDrinkImage(with url: String, completion: @escaping (UIImage?, Error?) -> Void) {
        
        //check cache for image, load if cached
        let imageCacheKey = NSString(string: url)
        if let image = CacheManager.shared.imageCache.object(forKey: imageCacheKey) {
            completion(image, nil)
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
                    completion(image, nil)
                
                } else { completion(nil, error) }
            }
        }
        
        task.resume()
    }
    
    
    //Fetch List type (generic method to fetch any list type)
    func fetchList(from path: String, using queryItems: [URLQueryItem], completion: @escaping (Result<[DrinkList], WFError>) -> Void) {
        
        //check url is valid, return error if not
        guard let _ = URL(string: path) else {
            completion(.failure(.invalidURLRequested))
            return
        }
        
        //Create URL object with querry item/s and append endpoint
        var components = constructURLComponents()
        components.queryItems = queryItems
        
        let url = components.url!.appendingPathComponent(path)
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //handle error cases
            //random network error
            if let _ = error {
                completion(.failure(.unableToCompleteRequest))
                return
            }
            
            //bad http response
            guard let response = response as? HTTPURLResponse, response.statusCode == 200  else {
                completion(.failure(.invalidServerResposne))
                return
            }
            
            //bad data returned, or alternate message like api rate limit exceeded
            guard let data = data else {
                completion(.failure(.invalidDataReturned))
                return
            }
            
            
            //decode data
            do {
                let jsonDecoder = JSONDecoder()
                let list = try jsonDecoder.decode(DrinkListType.self, from: data)
                
                //Pass list back to caller
                completion(.success(list.type))
                    
            //catch any errors
            } catch { completion(.failure(.invalidDataReturned)) }
            
        }

        task.resume()
    }
    
    
    //Fetch drink details by drink id lookup
    func fetchDrink(from path: String, using queryItems: [URLQueryItem]?, completion: @escaping (Result<Drink, WFError>) -> Void) {
        
        //check url is valid, return error if not
        guard let _ = URL(string: path) else {
            completion(.failure(.invalidURLRequested))
            return
        }
        
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
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //handle error cases
            //random network error
            if let _ = error {
                completion(.failure(.unableToCompleteRequest))
                return
            }
            
            //bad http response
            guard let response = response as? HTTPURLResponse, response.statusCode == 200  else {
                completion(.failure(.invalidServerResposne))
                return
            }
            
            //bad data returned, or alternate message like api rate limit exceeded
            guard let data = data else {
                completion(.failure(.invalidDataReturned))
                return
            }
            
            //decode data
            do {
                let jsonDecoder = JSONDecoder()
                
                //map data fetched to Drink object
                let drinks = try jsonDecoder.decode(Drinks.self, from: data)
                
                //Pass drinks back to caller
                if let drink = drinks.drinks.first { completion(.success(drink)) }
                    
            //catch any errrors
            } catch { completion(.failure(.invalidDataReturned)) }
        }
        
        task.resume()
    }
}

