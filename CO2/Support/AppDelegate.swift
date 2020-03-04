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
    
    enum TabBarItemTitle {
        static let Favorites = "Favorites"
    }
    
    
    enum StoryboardName {
        static let main = "Main"
    }

    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Setup favorites tab bar item
        if let tabBarController = window?.rootViewController as? UITabBarController {
            let storyboard = UIStoryboard(name: StoryboardName.main, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.mainNC)
            let image = UIImage(systemName: SFSymbol.heartFill)
            vc.tabBarItem = UITabBarItem.init(title: TabBarItemTitle.Favorites, image: image, tag: TabBarItem.Favorites)
            tabBarController.viewControllers?.append(vc)
        }
        
        return true
    }

    
    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}

    //MARK:- App Delegate stubs
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}

}

