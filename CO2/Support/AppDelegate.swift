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
    
    
    enum StoryboardName {
        static let main = "Main"
    }

    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if let rootVC = window?.rootViewController as? UITabBarController {
            
            //embed navigation controllers in root tab bar controller
            rootVC.viewControllers = getNavigationControllers()
            
            //get and add to storyboard
            let storyboard = UIStoryboard(name: StoryboardName.main, bundle: nil)
            storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.rooTabBarVC)
            
            //setup navigation bar
            configureNavigationBar()
        }
        
        return true
    }
    
    
    func configureNavigationBar() {
        UINavigationBar.appearance().tintColor = .systemGreen
            //set navBar tint color to system green app wide
    }
    
    
    func getNavigationControllers() -> [UINavigationController] {

        //create navigation controllers
        let topRatedVC = createTopRatedNavigationController()
        let featuredVC = createFeaturedNavigationController()
        let searchVC = createSearchNavigationController()
        let favoritesVC = createFavoritesNavigationController()
        
        return [topRatedVC, featuredVC, searchVC, favoritesVC]
    }
    
    
    func createTopRatedNavigationController() -> UINavigationController {
        //get and add vc to storyboard
        let storyboard = UIStoryboard(name: StoryboardName.main, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.drinksTableVC)
        
        //add tab bar item to vc
        vc.tabBarItem = UITabBarItem(title: TabBarItem.topRated.title, image: TabBarItem.topRated.image, tag: TabBarItem.topRated.tag)
        
        return UINavigationController(rootViewController: vc)
    }
    
    
    func createFeaturedNavigationController() -> UINavigationController {
        let storyboard = UIStoryboard(name: StoryboardName.main, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.drinkDetailsVC)
        vc.tabBarItem = UITabBarItem(title: TabBarItem.featured.title, image: TabBarItem.featured.image, tag: TabBarItem.featured.tag)

        return UINavigationController(rootViewController: vc)
    }
    
    
    func createSearchNavigationController() -> UINavigationController {
        let storyboard = UIStoryboard(name: StoryboardName.main, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.drinkSearchVC)
        vc.tabBarItem = UITabBarItem(title: TabBarItem.search.title, image: TabBarItem.search.image, tag: TabBarItem.search.tag)
        
        return UINavigationController(rootViewController: vc)
    }
    
    
    func createFavoritesNavigationController() -> UINavigationController {
        let storyboard = UIStoryboard(name: StoryboardName.main, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: StoryboardIdentifier.drinksTableVC)
        vc.tabBarItem = UITabBarItem(title: TabBarItem.favorites.title, image: TabBarItem.favorites.image, tag: TabBarItem.favorites.tag)
        
        return UINavigationController(rootViewController: vc)
    }

    
    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}

    //MARK:- App Delegate stubs
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}

}

