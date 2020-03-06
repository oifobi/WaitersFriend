//
//  TableViewController.swift
//  CO2
//
//  Created by Simon Italia on 9/10/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

//MARK:- Class Definition
class DrinksTableViewController: UITableViewController {
    
    
    enum TableViewSection { case main }
    
    
    enum SegueIdentifier { static let selfToDrinkDetailsVC = "DrinksTableVCToDrinkDetailsVC" }
    
 
    //For drinks fetched from Top Rated API
    var drinks = [Drink]()
    var tableViewDataSource: UITableViewDiffableDataSource<TableViewSection, Drink>!
    
    var isFavoritesDisplayed = false
    
    //Property to store Table section index
    var tableSectionsIndex = [(key: Substring, value: [Drink])]()
    
    //create spinner
    let spinner = SpinnerViewController()
    
    //MARK:- UIView Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTableView()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set self as delegate for when favorites are modified
        DataPersistenceManager.shared.delegate = self
//        configureTableViewCell()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        self.view = nil
            //reset views to avoid overlapping with  empty state
    }
    
    
    //MARK:- Custom Get Data / setup UI methods
    func configureTableView() {
        
        switch navigationController?.tabBarItem.tag {
        
        case TabBarItemTag.topRated:
            configureTopRated()
            
        case TabBarItemTag.favorites:
            configureFavorites()
            
        default:
            break
        }
    }
    
    
   //tableViewCell setup
    func configureTableViewCell() {

        tableViewDataSource =  UITableViewDiffableDataSource<TableViewSection, Drink>(tableView: tableView, cellProvider: {
            (tableView, indexPath, drink) -> UITableViewCell? in

            //same code tha usually goes in cellforRowAt dataSource delegate
            let cell = tableView.dequeueReusableCell(withIdentifier: DrinkTableViewCell.reuseIdentifier, for: indexPath) as! DrinkTableViewCell

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
    
    
    func updateTableViewSnapshotData(with drinks: [Drink]) {
        var snapshot = NSDiffableDataSourceSnapshot<TableViewSection, Drink>()
        snapshot.appendSections([.main])
        snapshot.appendItems(drinks)
        self.tableViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }

    
    
    func configureTopRated() {
        
        //trigger fetch of top rated drinks, if favorites screen not displayed
        guard !isFavoritesDisplayed else { return }
        self.title = ViewTitle.topRated
        
        if drinks.isEmpty {
            performSelector(inBackground: #selector(performFetchDrinks), with: nil)
        }
    }
    
    
    func configureFavorites() {
        isFavoritesDisplayed = true
        self.title = ViewTitle.favorites
        
        //Load Favorite drinks data (if any) from user default
        DataPersistenceManager.shared.loadSavedFavorites { (result) in
            
            switch result {
            case .success(let success):
                if success == .noFavorites {
                    self.showEmptyState(with: success.rawValue, in: self.view)
                    self.tableView.hideEmptyCells()
                    self.tableView.isScrollEnabled = false
                }
                
            case .failure(let error):
                print(error.rawValue)
            }
        }
    }
    
    
    //Fire request to fetch top rated drinks
    @objc func performFetchDrinks() {
        spinner.startSpinner(viewController: self)

        //fire fetch drinks list method
        let endpoint = NetworkCallEndPoint.popular
        NetworkManager.shared.fetchDrinks(from: endpoint, using: nil) { [weak self] (result) in
            guard let self = self else { return }
            self.spinner.stopSpinner()
            
            switch result {
            case .success(let drinks):
                self.drinks = drinks
//                self.updateTableViewSnapshotData(with: drinks)
                self.updateUI()
                
            case .failure(let error):
                self.presentErrorAlertVC(title: "Uh Oh!", message: error.rawValue, buttonText: "OK",
                action: UIAlertAction(title: "Try again?", style: .default, handler: { action in
                        self.performFetchDrinks()
                }))
            }
        }
    }
    
    
    func updateUI() {
        DispatchQueue.main.async {
            self.createTableSectionsIndex()
            self.tableView.reloadData()
            self.view.bringSubviewToFront(self.tableView)
                //brings table view to front to hide empty state if shown
        }
    }
    
    
    //setup tableViewIndex
    func createTableSectionsIndex() {
        switch navigationController?.tabBarItem.tag {

        case TabBarItemTag.topRated:
            let dict = Dictionary(grouping: drinks, by: { $0.name.prefix(1)})
            tableSectionsIndex = dict.sorted(by: {$0.key < $1.key})

        case TabBarItemTag.favorites:
            let dict = Dictionary(grouping: DataPersistenceManager.shared.favorites, by: { $0.name.prefix(1)})
            tableSectionsIndex = dict.sorted(by: {$0.key < $1.key})

        default:
            break
        }
    }
}
 

//MARK:- Extension TableView Datasource
extension DrinksTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int { tableSectionsIndex.count }
        
    
    //set number of section rows based on number of drinks contained within in each section title
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //Get the number of rows per section by accessing the key's drinks count
        let section = tableSectionsIndex[section]
        return section.value.count
    }
    
    
    //set and display tbale section headings in tableView (Letter)
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //Pull out the key value (Letter) and set as Section heading
        let title = tableSectionsIndex[section].key
        return String(title)
    }
    
    
    //set titles to display in index on RHS of tableView
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        //create an array of all the letters for the table index, using the keys and transform to type string
        let titles = tableSectionsIndex.map( { String($0.key) } )
        return titles
    }
    
    
    //set cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //point cellForRowAt method to custom cell class by down casting to custom class
        let cell = tableView.dequeueReusableCell(withIdentifier: DrinkTableViewCell.reuseIdentifier, for: indexPath) as! DrinkTableViewCell
        
        //get reference to the section (being shown)
        let section = tableSectionsIndex[indexPath.section]
        
        //get drinks for the section to be shown
        let drinks = section.value
        
        //ensure table rows matches drinks object array since the same tableView controller is used for different calls to fetch data
        if indexPath.row < drinks.count {
            
            let drink = drinks[indexPath.row]
            
            //set cell lables text
            cell.setTitleLabel(text: drink.name)
            cell.setSubtitleLabel(text: drink.ingredient1 ?? "")
            
            //Cell image
            //Fetch and set drink image
            if let urlString = drink.imageURL {
                
                //Update cell image to fecthedImage via main thread
                DispatchQueue.main.async {
                    
                    //Ensure wrong image isn't inserted into a recycled cell
                    if let currentIndexPath = self.tableView.indexPath(for: cell),
                        
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
        }
        
        return cell
    }
}
    

//MARK:- Extension TableView Delegate
extension DrinksTableViewController {
    
    //Enable table row delete when an Action is triggered (swipe to delete or Edit Button)
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        //Enable row delete only for favorites
        guard navigationController?.tabBarItem.tag == TabBarItemTag.favorites else { return false }
        return true
    }
    
    
    //Enable swipe to delete on table row for Favorites
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard navigationController?.tabBarItem.tag == TabBarItemTag.favorites else { return }
        
        if editingStyle == .delete {
            
            //get drink
            let item = tableSectionsIndex[indexPath.section]
            let drinks = item.value
            let drink = drinks[indexPath.row]

            //remove drink
            DataPersistenceManager.shared.updateFavorites(with: drink, action: .remove) { (result) in
                
                switch result {
                case .success(let message):
                    print("\(drink.name) \(message.rawValue)\n")
                    
                case .failure(let error):
                    print("\(drink.name) \(error.rawValue)\n")
                }
            }
        }
    }
    
    
    //MARK:- Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = tableView.indexPathForSelectedRow!.section
        let row = tableView.indexPathForSelectedRow!.row
        let item = tableSectionsIndex[section]
        let drink = item.value[row]
        
        presentDestinationVC(with: StoryboardIdentifier.drinkDetailsVC, for: drink)
    }
}


//MARK:- Extension Protocol delegate method to update drinks property when user modifies favorites from DrinksTableVC (Favorites mode)
extension DrinksTableViewController: FavoriteDrinksDelegate {
    func update() {
        updateUI()
    }
}
