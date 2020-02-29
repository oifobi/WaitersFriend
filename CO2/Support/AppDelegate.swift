//
//  AppDelegate.swift
//  CO2
//
//  Created by Simon Italia on 9/9/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        //Load Favorite drinks data (if any) from user default
        DataPersistenceManager.shared.loadFavorites() { (result) in
            
            switch result {
            case .success(let message):
                print(message.rawValue)
                
            case .failure(let error):
                print(error.rawValue)
            }
        }
        
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Setup favorites tab bar item
        if let tabBarController = window?.rootViewController as? UITabBarController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "DrinksTableViewNavController")
            let image = UIImage(systemName: SFSymbol.heartFill)
            vc.tabBarItem = UITabBarItem.init(title: "Favorites", image: image, tag: 3)
            tabBarController.viewControllers?.append(vc)
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        //Save Favorite drinks data to user defaults
        DataPersistenceManager.shared.saveFavorites() { (result) in
            
            switch result {
            case .success(let message):
                print(message.rawValue)
                
            case .failure(let error):
                print(error.rawValue)
            }
        }
    }

    //MARK:- App Delegate stubs
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}

}

