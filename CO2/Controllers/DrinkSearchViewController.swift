//
//  DrinkSearchController.swift
//  CO2
//
//  Created by Simon Italia on 10/12/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

class DrinkSearchViewController: UIViewController {
    
    enum TableViewSection {
        case main
    }
    
    
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
    var recentDrinks = [Drink]() //Recent drinks
    
    //For TableView
    var drinks = [Drink]() //Search drinks
    var ingredientDrinks: [DrinkList]? //List of drinks made with base ingredient
    var currentIngredient = String() //for tracking currently selected base ingredient
    var tableViewDataSource: UITableViewDiffableDataSource<TableViewSection, Drink>!
    
    //for searching
//    var filteredDrinks = [Drinks]()
//    var isSearching = false
    
    
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
        configureTableViewCell()
            //new method for configuring cells in iOS13
    }
    
    
    //MARK: ViewController setup
    func fireFetchData() {
        
        //Recents Drink data
        performSelector(inBackground: #selector(performFetchRecentDrinks), with: nil)

        //Drink name data
        guard drinks.isEmpty else { return }
                //TODO: TODO move to inside method call when time comes
        
        performSearchForDrinks(from: NetworkCallEndPoint.search, queryName: NetworkCallQueryType.drinkName, queryValue: Ingredient.margarita)
    }
    
    
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
    
    
    //tableViewCell setup
    func configureTableViewCell() {
        
        tableViewDataSource =  UITableViewDiffableDataSource<TableViewSection, Drink>(tableView: self.drinksTableView, cellProvider: {
            (tableView, indexPath, drink) -> UITableViewCell? in
            
            //same code tha usually goes in cellforRowAt dataSource delegate
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.tableViewCell, for: indexPath) as! DrinkTableViewCell
            
            //set cell lables text
            cell.setTitleLabel(text: drink.name)
            cell.setSubtitleLabel(text: drink.ingredient1 ?? "")
            
            //Fetch and set drink image
            if let urlString = drink.imageURL {
                cell.setImage(with: urlString)
                cell.setNeedsLayout()
            }
            
            return cell
        })
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
        guard recentDrinks.isEmpty else { return }
        
        spinner.startSpinner(viewController: self)

        //fire fetch recent drinks list method
        NetworkManager.shared.fetchDrinks(from: NetworkCallEndPoint.recent, using: nil) { [weak self] (result) in
            
            guard let self = self else { return }
                            
            self.spinner.stopSpinner()

            switch result {
            case .success(let drinks):
                self.recentDrinks = drinks
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
                self.drinks.sort(by: {$0.name < $1.name} )
                self.updateTableViewSnapshotData(with: self.drinks)
                    
                
//                self.updateUI(for: View.table)
                
                
                
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


//MARK:- TableView DataSource Methods
extension DrinkSearchViewController {
    
    //call after fetching drinks data to create table cells
    func updateTableViewSnapshotData(with drinks: [Drink]) {
        var snapshot = NSDiffableDataSourceSnapshot<TableViewSection, Drink>()
        snapshot.appendSections([.main])
        snapshot.appendItems(drinks)
        self.tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
}


//MARK:- TableView Delegate methods
extension DrinkSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let vc = storyboard?.instantiateViewController(withIdentifier: "DrinkDetailsVC") as? DrinkDetailsViewController {
            vc.drink = drinks[indexPath.item]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


//MARK:- CollectionView Data Source methods
extension DrinkSearchViewController: UICollectionViewDataSource {
    
    // Define number of sections
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    //Define number of items per section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { recentDrinks.count }

    //Define cells / content per section item
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Identifier.collectionViewCell, for: indexPath) as? DrinkCollectionViewCell else { preconditionFailure("Invalid cell type") }
        
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
}


//MARK:- CollectionView Delegate methods
extension DrinkSearchViewController: UICollectionViewDelegate {
    
    //Send to DrinkDetailsVC when cell tapped
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let vc = storyboard?.instantiateViewController(withIdentifier: "DrinkDetailsVC") as?         DrinkDetailsViewController {
            vc.drink = recentDrinks[indexPath.item]
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
