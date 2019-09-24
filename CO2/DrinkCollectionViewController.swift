//
//  DrinkCollectionViewController.swift
//  CO2
//
//  Created by Simon Italia on 9/23/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class DrinkCollectionViewController: UICollectionViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    var baseIngredients = [String]()
    var drinksList = [String]()
    
    //MARK:- Built-in CollectionView handlers
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Fire fetch Base Ingredients List
        performSelector(inBackground: #selector(fireFetchBaseIngredients), with: nil)
        
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        
    }
    
    //MARK:- Custom Methods
    func updateUI() {
        
        //load navigationBar items
        setupNavigationBar()
        
    }
    
    //Fetch List of Base Ingredients (ie: Vodka, Bitters, etc)
    @objc func fireFetchBaseIngredients() {
        
        //fire fetch drinks list method
        DrinksController.shared.fetchList(from: "/list.php", using: URLQueryItem(name: "i", value: "list")) { (fetchedLists, error) in
        
            //fire UI update if fetch successful
            if let lists = fetchedLists {
                
                //set fetechedList data to baseIngredients property
                self.baseIngredients = lists.map( { $0.ingredients!} )
                
//                self.updateUI()
                print("Successfully fetched list: \(self.baseIngredients)\n")
            }
            
            //fire error meessage if error
            if let error = error {
                print("Error fetching list with error: \(error.localizedDescription)\n")
            }
        }
    }
    
    //Fetch Drinks List made from a specific Base Ingredient
    @objc func fireFetchDrinkList() {
        
        
    }
    
    
    

    //MARK:- Custom methods
    func setupNavigationBar() {
        
        title = "Search"
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.placeholder = "Search by ingredient (eg. vodka)"
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.delegate = self
        search.searchResultsUpdater = self
        
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
            //this property ensures any VCs displayed from this viewController can navigate back
        
    }
    
    //UISearch Delegate conformance method
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text)
    }
    

    // UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }

    // UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
}
