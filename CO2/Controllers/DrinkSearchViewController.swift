//
//  DrinkSearchController.swift
//  CO2
//
//  Created by Simon Italia on 10/12/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

class DrinkSearchViewController: UIViewController {
    
    enum Section { case main }
    
    
    enum View {
        static let table = "tableView"
        static let collection = "collectionView"
    }
    
    
    enum Identifier {
        static let tableViewCell = "DrinkTableViewCell"
        static let collectionViewCell = "DrinkCollectionViewCell"
        
    }
    
    
    enum Ingredient { static let margarita = "margarita" }
    
    
    //IBOutles
    @IBOutlet weak var drinksCollectionView: UICollectionView!
    @IBOutlet weak var drinksTableView: UITableView!
    
    //Properties for storing feteched drink/s data objects
    //For CollectionView
//    var recentDrinks: [Drink]? //Recent drinks
    var recentDrinks = [Drink]() //Recent drinks
    
    //For TableView
//    var drinks[Drink]? //Search drinks
    var drinks = [Drink]() //Search drinks
    var ingredientDrinks: [DrinkList]? //List of drinks made with base ingredient
    var currentIngredient = String() //for tracking currently selected base ingredient
    var tableViewDataSource: UITableViewDiffableDataSource<Section, Drink>!
    
    //for searching
    var filteredDrinks = [Drinks]()
    var isSearching = false
    
    
    //Common/shared properties b/w TableView
    var drink: Drink?
    
    
    //create spinner
    let spinner = SpinnerViewController()
    
    
    //MARK:- UIView Lifecycle
    //Start fetch of data
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fireFetchData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        createSearchController()
        configureCollectionView()
    }
    
    
    //Data management
    func fireFetchData() {
        
        //Recents Drink data
//        if recent Drinks == nil {
            performSelector(inBackground: #selector(performFetchRecentDrinks), with: nil)
//        }
        
        //Drink name data
//        if drinks == nil {
            performSearchForDrinks(from: NetworkCallEndPoint.search, queryName: NetworkCallQueryType.drinkName, queryValue: Ingredient.margarita)
//        }
    }
    
    
    //MARK: ViewController configuration
    func configureViewController() { title = "Search" }
    
    
    //MARK:- Search Controller setup (updates TableView Data)
    func createSearchController() {
        
        //Create / configure onfigure Search Controller
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.searchBar.delegate = self
        sc.searchBar.placeholder = "Search by cocktail (e.g. Margarita)"
        sc.obscuresBackgroundDuringPresentation = false
        
        //set created search controller to navigation controller
        navigationItem.searchController = sc
    }
    
    
    //MARK: - Configure Views
    //CollectionView setup
    func configureCollectionView() {

        //CollectionView
        //Register cell classes and nibs
        drinksCollectionView.register(UINib(nibName: Identifier.collectionViewCell, bundle: nil), forCellWithReuseIdentifier: Identifier.collectionViewCell)
        
        //Set compositionViewLayout
        drinksCollectionView.collectionViewLayout = createCompositionalLayout()
    }
    
    
    //tableView setup
    func configureTableViewCell() {
        
        
    }
    
    
    
    
    

    
    
    //MARK: - UI Management
    func updateUI(for view: String) {
        
        DispatchQueue.main.async {
            if view == View.collection { self.drinksCollectionView.reloadData()
            }
            else if view == View.table { self.drinksTableView.reloadData() }
        }
    }
    
    
    //MARK:- CollectionView Data Fetching methods
    //Fetch Recent Drinks
    @objc func performFetchRecentDrinks() {
        spinner.startSpinner(viewController: self)

        //fire fetch recent drinks list method
        NetworkManager.shared.fetchDrinks(from: NetworkCallEndPoint.recent, using: nil) { [weak self] (result) in
            
            guard let self = self else { return }
                            
            self.spinner.stopSpinner()

            switch result {
            case .success(let drinks):
                self.recentDrinks = drinks
//                self.trendingDrinks?.sort(by: {$0.name < $1.name} )
                self.recentDrinks.sort(by: {$0.name < $1.name} )
                self.updateUI(for: View.collection)
                
            case .failure(let error):
                self.presentErrorAlertVC(title: "Uh Oh!", message: error.rawValue, buttonText: "OK",
                action: UIAlertAction(title: "Try again?", style: .default, handler: { action in
                        self.fireFetchData()
                }))
            }
        }
    }
    
    
    //MARK:- TableView Data Fetching methods
    //Fetch Selected Base Ingredient Drinks List (drinks made wih specific Base ingredient)
    @objc func performFetchDrinksList(for ingredient: String) {
        spinner.startSpinner(viewController: self)

        //fire fetch list method
        NetworkManager.shared.fetchList(from: "/filter.php", using: [URLQueryItem(name: "i", value: ingredient)]) { [weak self] (fetchedList) in
            guard let self = self else { return }
            self.spinner.stopSpinner()
            
            switch fetchedList {
            case .success(let list):
                self.ingredientDrinks = list
                self.currentIngredient = ingredient
                self.updateUI(for: View.table)
                
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
//                self.drinks?.sort(by: {$0.name < $1.name} )
                self.drinks.sort(by: {$0.name < $1.name} )
                self.updateUI(for: View.table)
                
            case .failure(let error):
                print(error.rawValue)
            }
        }
    }
}


//MARK:- UISearch Results / Delegate
extension DrinkSearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else { return }

        //fetch drink name
        performSearchForDrinks(from: NetworkCallEndPoint.search, queryName: NetworkCallQueryType.drinkName, queryValue: text)
    }
}


//MARK:- TableView Data Source / Delegate
extension DrinkSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    //TableViewDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let drinks = drinks else { return 0 }
        return drinks.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //point cellForRowAt method to custom cell class by down casting to custom class
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.tableViewCell, for: indexPath) as! DrinkTableViewCell
        
        //Get reference to row
//        if indexPath.row < drinks!.count {
        if indexPath.row < drinks.count {
            
            //Get drink
//            if let drink = drinks?[indexPath.row] {
            let drink = drinks[indexPath.row]
                
                //set cell lables text
                cell.setTitleLabel(text: drink.name)
                cell.setSubtitleLabel(text: drink.ingredient1 ?? "")
                
                //set cell image
                //Fetch and set drink image
                if let urlString = drink.imageURL {
                    
                    //Update cell image to fecthedImage via main thread
                    DispatchQueue.main.async {
                        
                        //Ensure wrong image isn't inserted into a recycled cell
                        if let currentIndexPath = self.drinksTableView.indexPath(for: cell),
                            
                            //If current cell index and table index don't match, exit fetch image method
                            currentIndexPath != indexPath {
                            return
                        }
                        
                        //Set cell image
                        cell.setImage(with: urlString)
                        
                        //Refresh cell to display fetched image
                        cell.setNeedsLayout()
                    }
                }
//            }
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard drinks != nil else { return }

        if let vc = storyboard?.instantiateViewController(withIdentifier: "DrinkDetailsVC") as? DrinkDetailsViewController {
               
//            vc.drink = drinks![indexPath.item]
            vc.drink = drinks[indexPath.item]
            vc.sender = ViewControllerSender.drinkSearchVC
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


//MARK:- CollectionView Data Source / Delegate
extension DrinkSearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // Define number of sections
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    

    //Define number of items per section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        guard let recentDrinks = trendingDrinks else { return 0 }
        return recentDrinks.count
    }
        
    
    //Define cells / content per section item
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Identifier.collectionViewCell, for: indexPath) as? DrinkCollectionViewCell else { preconditionFailure("Invalid cell type") }
        
//        guard let drink = trendingDrinks?[indexPath.item] else { preconditionFailure("Drinks property is nil") }
        let drink = recentDrinks[indexPath.item]
        
        //Set cell properties
        //Cell text
        cell.setTitleLabel(text: drink.name)
        cell.setSubtitleLabel(text: drink.ingredient1 ?? "")
        
        //Cell image
        //Fetch and set drink image
        if let urlString = drink.imageURL {
            
            //Update cell image to fecthedImage via main thread
            DispatchQueue.main.async {
                
                //Ensure wrong image isn't inserted into a recycled cell
                if let currentIndexPath = self.drinksCollectionView.indexPath(for: cell),
                    currentIndexPath != indexPath {
                    return
                }
                
                //Set cell image
                cell.setImage(with: urlString)
                
                //Refresh cell to display fetched image
                cell.setNeedsLayout()
            }
        }
        
        return cell
    }
    
    
    //Send to DrinkDetailsVC when cell tapped
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard trendingDrinks != nil else { return }

        if let vc = storyboard?.instantiateViewController(withIdentifier: "DrinkDetailsVC") as?         DrinkDetailsViewController {
               
//            vc.drink = trendingDrinks![indexPath.item]
            vc.drink = recentDrinks[indexPath.item]
            vc.sender = ViewControllerSender.drinkSearchVC
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


//MARK:- UICollectionView Create Layout (for Trending Drinks)
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
