//
//  DrinkCollectionViewController.swift
//  CO2
//
//  Created by Simon Italia on 9/23/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

class DrinkSearchCollectionViewController: UICollectionViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    var drinks: [Drink]? //Recent drinks
    var drink: Drink?
    var currentBaseIngredient = String() //for tracking currently selected base ingredient
    
    //MARK:- Built-in CollectionView Life-Cycle handlers
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Fire fetch Recents Drink
        if drinks == nil {
            performSelector(inBackground: #selector(performFetchRecentDrinks), with: nil)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set initial title and collectionView data
        self.title = "Recent Drinks"
        
        // preserve selection between presentations
//         self.clearsSelectionOnViewWillAppear = true
        
        //Register cell classes and nibs
        //Section 1 cells (UIImageView + UILabel)
        collectionView.register(UINib(nibName: "DrinksCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DrinksCollectionView")
        
        self.setUpNavigationBar()
        
    }
    
    //MARK:- Custom Methods
    func updateUI() {
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    //UISearch Delegate conformance method
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text)
    }
    
    func setUpNavigationBar() {
        
        DispatchQueue.main.async {
            self.title = "Search"
            let search = UISearchController(searchResultsController: nil)
            search.searchBar.placeholder = "Search by cocktail (e.g. Margarita)"
            search.obscuresBackgroundDuringPresentation = false
            search.searchBar.delegate = self
            search.searchResultsUpdater = self
            self.navigationItem.searchController = search
            self.navigationItem.hidesSearchBarWhenScrolling = false
            self.definesPresentationContext = true
                //this property ensures any VCs displayed from this viewController can navigate back
        }
    }
    
    //Fetch Recent Drinks
    @objc func performFetchRecentDrinks() {
        
        //start / display activity spinner
        DispatchQueue.main.async {
            self.startActivitySpinner()
        }
        
        //fire fetch recent drinks list method
        DrinksController.shared.fetchDrinks(from: EndPoints.recent.rawValue) { (fetchedDrinks, error) in
        
            //fire UI update if fetch successful
            if let drinks = fetchedDrinks {
                self.drinks = drinks
                self.updateUI()
                print("Fetched Recent Drinks. Items: \(drinks.count)\n")
            }
            
            //Stop and remove activity spinnner
            DispatchQueue.main.async() {
                self.stopActivitySpinner()
            }
            
            //fire error handler if error
            if let error = error {
                self.showAlert(with: error)
            }
        }
    }
    
    func showAlert(with error: Error, sender: String = #function) {
           print("Error Alert called by: \(sender)\n")
           
           DispatchQueue.main.async {
               let ac = UIAlertController(title: "Uh Oh!", message: "\(error.localizedDescription)", preferredStyle: .alert)
               ac.addAction(UIAlertAction(title: "Try again?", style: .default, handler: {
                   action in self.performFetchRecentDrinks()
               }))
               ac.addAction(UIAlertAction(title: "OK", style: .default))
               self.present(ac, animated: true)
           }
       }
    
    //Activity indicator / spinner
    func startActivitySpinner() {
        addChild(ActivitySpinnerViewController.shared)
        ActivitySpinnerViewController.shared.view.frame = view.bounds
        view.addSubview(ActivitySpinnerViewController.shared.view)
        ActivitySpinnerViewController.shared.didMove(toParent: self)
    }
    
    func stopActivitySpinner() {
        ActivitySpinnerViewController.shared.willMove(toParent: nil)
        ActivitySpinnerViewController.shared.view.removeFromSuperview()
        ActivitySpinnerViewController.shared.removeFromParent()
    }
    
    //MARK:- Data Fetching methods
    //Fetch drink details in prep tp pass to DrinkDetailsVC
    @objc func performFetchDrink() {
        
        //fire fetch drink method
         DrinksController.shared.fetchDrink(from: "/lookup.php", using: [URLQueryItem(name: "i", value: "14282")]) { (fetchedDrink, error) in
        
            //If success,
            if let drink = fetchedDrink {
                self.drink = drink
                print("Fetched drink: \(String(describing: self.drink))\n")
            }
            
            //if error, fire error meessage
            if let error = error {
                print("Error fetching drink with error: \(error.localizedDescription)\n")
            }
         }
    }
    
    //MARK:- CollectionView Data Source / Delegate methods
    
    // Define number of sections
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    //Define number of items per section
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard drinks != nil else { return 0 }
        
        return drinks!.count
        
    }
    
    //Define cells / content per section item
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: "DrinksCollectionView", for: indexPath) as? DrinksCollectionViewCell
        
        else {
            preconditionFailure("Invalid cell type")
        }
        
        guard drinks != nil else {preconditionFailure("Drinks property is nil") }
        
        let drink = drinks![indexPath.item]
        
        //Set cell properties
        //Cell text
        cell.setLabel(text: drink.name)
        
        //Cell image
        //Fetch and set drink image
        if let imageURL = drink.imageURL {
            
            //Show and start cell activity indicator animation
            cell.startActivityIndicator()
            
            DrinksController.shared.fetchDrinkImage(with: imageURL) { (fetchedImage, error) in
               if let drinkImage = fetchedImage {

                   //Update cell image to fecthedImage via main thread
                   DispatchQueue.main.async {

                       //Ensure wrong image isn't inserted into a recycled cell
                        if let currentIndexPath = self.collectionView.indexPath(for: cell),

                           //If current cell index and table index don't match, exit fetch image method
                           currentIndexPath != indexPath {
                               return
                           }
                    
                        //Set cell image
                        cell.setImage(drinkImage)
                    
                        //Stop acell activity indicator animation and hide
                        cell.stopActivityIndicator()

                        //Refresh cell to display fetched image
                        cell.setNeedsLayout()
                    
                   }

               //Catch any errors fetching image
               } else if let error = error {
                   print("Error fetching image with error \(error.localizedDescription)\n")
               }
           }
        }
        return cell
    }
    
    // MARK: - Navigation
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard drinks != nil else { return }
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "DrinkDetailsVC") as? DrinkDetailsViewController {
                
            vc.drink = drinks![indexPath.item]
            vc.sender = "SearchCollectionViewController"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//    }
}
