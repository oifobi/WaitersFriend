//
//  DrinkSearchController.swift
//  CO2
//
//  Created by Simon Italia on 10/12/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

class DrinkSearchViewController: UIViewController {
    
    //IBOutles
    @IBOutlet weak var trendingDrinksCollectionView: UICollectionView!
    @IBOutlet weak var searchDrinksTableView: UITableView!
    
    //Properties for storing feteched drink/s data objects
    //For CollectionView
    var trendingDrinks: [Drink]? //Recent drinks
    
    //For TableView
    var drinks: [Drink]? //Search drinks
    var ingredients = [String]() //Base ingredient
    var ingredientDrinks: [DrinkList]? //List of drinks made with base ingredient
    var currentIngredient = String() //for tracking currently selected base ingredient
    
    //Common/shared properties b/w TableView and CollectionView
    var drink: Drink?
    
    //create spinner
    let spinner = SpinnerViewController()
    
    
    //MARK:- Built-in UIView Life-Cycle handlers
    //Start fetch of data
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //CollectionView setup
        //Fire fetch Recents Drink
        if trendingDrinks == nil {
            performSelector(inBackground: #selector(performFetchRecentDrinks), with: nil)
        }

        //TableView setup
        //Fire fetch Base Ingrediets list
        if ingredients == [] {
            performSelector(inBackground: #selector(performFetchIngredientList), with: nil)
        }

        //fetch drink name
        if drinks == nil {
            performSearchForDrinks(from: EndPoint.search.rawValue, queryName: QueryType.drinkName.rawValue, queryValue: "Margarita")
        }
    }
    
    //Setup interface
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set NavigationBar items
        self.setUpNavigationBar()
        
        //CollectionView
        //Register cell classes and nibs
        trendingDrinksCollectionView.register(UINib(nibName: "DrinkCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DrinkCollectionViewCell")
        
        //Set compositionViewLayout
        trendingDrinksCollectionView.collectionViewLayout = self.createCompositionalLayout()
    }
    
    
    //MARK:- CollectionView Data Fetching methods
    //Fetch Recent Drinks
    @objc func performFetchRecentDrinks() {
        
        //create / start activity spinner
        spinner.startSpinner(viewController: self)

        //fire fetch recent drinks list method
        NetworkManager.shared.fetchDrinks(from: EndPoint.recent.rawValue, using: nil) { [weak self] (result) in
            
            guard let self = self else { return }
                            
            self.spinner.stopSpinner()

            switch result {
            case .success(let drinks):
                self.trendingDrinks = drinks
                self.trendingDrinks?.sort(by: {$0.name < $1.name} )
                self.updateUI(for: "collectionView")
                
            case .failure(let error):
                self.presentErrorAlertVC(title: "Uh Oh!", message: error.rawValue, buttonText: "OK",
                action: UIAlertAction(title: "Try again?", style: .default, handler: { action in
                        self.performFetchRecentDrinks()
                }))
            }
        }
    }
    
    
    //MARK:- TableView Section methods (Search Results)
    func setUpNavigationBar() {
        DispatchQueue.main.async {
            
            //Search Controller
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

    
    //MARK:- TableView Data Fetching methods
    //Fetch List of Base Ingredients (ie: Vodka, Bitters, etc)
    @objc func performFetchIngredientList() {
        
        //fire fetch drinks list method
        NetworkManager.shared.fetchList(from: "/list.php", using: [URLQueryItem(name: "i", value: "list")]) { [weak self] (result) in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let list):
                self.ingredients = list.map( { $0.baseIngredient! } )
                
                //Sort Ingredients array (ascending order)
                self.ingredients.sort()
                self.updateUI(for: "tableView")
            
            case .failure(let error):
                self.presentErrorAlertVC(title: "Uh Oh!", message: error.rawValue, buttonText: "OK",
                action: UIAlertAction(title: "Try again?", style: .default, handler: { action in
                        self.performFetchIngredientList()
                }))
            }
        }
    }
    
    //Fetch Selected Base Ingredient Drinks List (drinks made wih specific Base ingredient)
    @objc func performFetchDrinksList(for ingredient: String) {
        
        //start spinner
        spinner.startSpinner(viewController: self)

        //fire fetch list method
        NetworkManager.shared.fetchList(from: "/filter.php", using: [URLQueryItem(name: "i", value: ingredient)]) { [weak self] (fetchedList) in
            
            guard let self = self else { return }
            
            //Stop and remove activity spinnner
            self.spinner.stopSpinner()
            
            switch fetchedList {
            case .success(let list):
                self.ingredientDrinks = list
                self.currentIngredient = ingredient
                self.updateUI(for: "tableView")
                
            case .failure(let error):
                print("Error fetching drinks list with error: \(error.rawValue)\n")
            }
        }
    }
    
    //Fetch drink names from user's search query
    func performSearchForDrinks(from endpoint: String, queryName: String, queryValue: String) {
        
        NetworkManager.shared.fetchDrinks(from: endpoint, using: [URLQueryItem(name: queryName, value: queryValue)]) { [weak self] (result) in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let drinks):
                self.drinks = drinks
                self.drinks?.sort(by: {$0.name < $1.name} )
                self.updateUI(for: "tableView")
                
            case .failure(let error):
                self.presentErrorAlertVC(title: "Uh Oh!", message: error.rawValue, buttonText: "OK",
                action: UIAlertAction(title: "Try again?", style: .default, handler: { action in
                        self.performFetchRecentDrinks()
                }))
            }
        }
    }
    
    
    //MARK:- Custom Shared methods
    func updateUI(for view: String) {
        
        DispatchQueue.main.async {
            if view == "collectionView" {
                self.trendingDrinksCollectionView.reloadData()
            
            } else if view == "tableView" {
                self.searchDrinksTableView.reloadData()
                self.view.bringSubviewToFront(self.searchDrinksTableView)
            }
        }
    }
    
    
    //Fetch drink details in prep tp pass to DrinkDetailsVC
    @objc func performFetchDrink(with id: String) {
        
        //start activity spinner
        spinner.startSpinner(viewController: self)

        //fire fetch drink method
        let endpoint = EndPoint.lookup.rawValue
        NetworkManager.shared.fetchDrink(from: endpoint, using: [URLQueryItem(name: QueryType.ingredient.rawValue, value: id)]) { (fetchedDrink, error) in
        
            //If success,
            if let drink = fetchedDrink {
                self.drink = drink
                
                //perform segue to detailsVC
                DispatchQueue.main.async {
                
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "DrinkDetailsVC") as? DrinkDetailsViewController {
                        vc.drink = drink
                        vc.sender = "DrinkIngredientCollectionViewController"
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            
            //Stop and remove activity spinnner
            self.spinner.stopSpinner()
            
            //if error, fire error meessage
            if let error = error {
                print("Error fetching drink with error: \(error.localizedDescription)\n")
            }
         }
    }
}

//MARK:- TableView Data Source / Delegate
extension DrinkSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    //TableViewDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard drinks != nil else { return 0 }
        return drinks!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //point cellForRowAt method to custom cell class by down casting to custom class
        let cell = tableView.dequeueReusableCell(withIdentifier: "DrinkTableViewCell", for: indexPath) as! DrinkTableViewCell
        
        //Get reference to row
        if indexPath.row < drinks!.count {
        
            //Get drinkk
            if let drink = drinks?[indexPath.row] {
            
                //set cell lables text
                cell.setTitleLabel(text: drink.name)
                cell.setSubtitleLabel(text: drink.ingredient1 ?? "")
                    
                //Fetch and set drink image
                if let imageURL = drink.imageURL {
                    
                    //Start cell activity indicator
                    cell.startActivityIndicator()
                    
                    NetworkManager.shared.fetchDrinkImage(with:imageURL) { (fetchedImage, error) in
                    if let drinkImage = fetchedImage {

                            //Update cell image to fecthedImage via main thread
                            DispatchQueue.main.async {

                                //Ensure wrong image isn't inserted into a recycled cell
                                if let currentIndexPath = self.searchDrinksTableView.indexPath(for: cell),

                                    //If current cell index and table index don't match, exit fetch image method
                                    currentIndexPath != indexPath {
                                        return
                                    }

                                //Set cell image
                                cell.setImage(drinkImage)
                                
                                //Stop cell activity indicator
                                cell.stopActivityIndicator()

                                //Refresh cell to display fetched image
                                cell.setNeedsLayout()
                            }

                        //catch any errors fetching image
                        } else if let error = error {
                            print("Error fetching image with error \(error.localizedDescription)\n")
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard drinks != nil else { return }

        if let vc = storyboard?.instantiateViewController(withIdentifier: "DrinkDetailsVC") as? DrinkDetailsViewController {
               
            vc.drink = drinks![indexPath.item]
            vc.sender = "DrinkSearchViewController"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


//MARK:- CollectionView Data Source / Delegate
extension DrinkSearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Define number of sections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    //Define number of items per section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard trendingDrinks != nil else { return 0 }
        return trendingDrinks!.count
    }
        
    //Define cells / content per section item
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: "DrinkCollectionViewCell", for: indexPath) as? DrinkCollectionViewCell
        
        else {
            preconditionFailure("Invalid cell type")
        }
        
        guard trendingDrinks != nil else { preconditionFailure("Drinks property is nil") }
        let drink = trendingDrinks![indexPath.item]
        
        //Set cell properties
        //Cell text
        cell.setTitleLabel(text: drink.name)
        cell.setSubtitleLabel(text: drink.ingredient1 ?? "")
        
        //Cell image
        //Fetch and set drink image
        if let imageURL = drink.imageURL {
            
            //Show and start cell activity indicator animation
            cell.startActivityIndicator()
            
            NetworkManager.shared.fetchDrinkImage(with: imageURL) { (fetchedImage, error) in
               if let drinkImage = fetchedImage {

                   //Update cell image to fecthedImage via main thread
                   DispatchQueue.main.async {

                       //Ensure wrong image isn't inserted into a recycled cell
                        if let currentIndexPath = self.trendingDrinksCollectionView.indexPath(for: cell),

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
    
    //Send to DrinkDetailsVC when cell tapped
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard trendingDrinks != nil else { return }

        if let vc = storyboard?.instantiateViewController(withIdentifier: "DrinkDetailsVC") as? DrinkDetailsViewController {
               
           vc.drink = trendingDrinks![indexPath.item]
           vc.sender = "DrinkSearchViewController"
           navigationController?.pushViewController(vc, animated: true)
        }
    }
}


//MARK:- UISearch Results / Delegate
extension DrinkSearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else { return }

        //fetch drink name
        performSearchForDrinks(from: EndPoint.search.rawValue, queryName: QueryType.drinkName.rawValue, queryValue: text)
    }
}


//MARK:- UICollectionView Section methods (Trending Drinks)
extension DrinkSearchViewController {

    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {

        //Define Layout
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            //Define Item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 5.0, bottom: 0.0, trailing: 5.0)

            //Define Group
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .estimated(250),
                heightDimension: .absolute(170)),
                subitem: item,
                count: 1)

            //Define Section
            let section = NSCollectionLayoutSection(group: group)

            //Define Section header
            let headerView = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .absolute(1.0)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)

            headerView.pinToVisibleBounds = true
            section.boundarySupplementaryItems = [headerView]
            section.contentInsets = NSDirectionalEdgeInsets(top: 5.0,
                                                            leading: 0.0,
                                                            bottom: 16.0,
                                                            trailing: 0.0)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            return section
        }

        return layout
    }
}




