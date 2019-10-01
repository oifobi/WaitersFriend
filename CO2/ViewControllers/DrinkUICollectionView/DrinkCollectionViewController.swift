//
//  DrinkCollectionViewController.swift
//  CO2
//
//  Created by Simon Italia on 9/23/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

enum Section: Int {
    case baseIngredients
    case baseIngredientDrinks
    case drinks
}

class DrinkCollectionViewController: UICollectionViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    //IBOutlets
    @IBOutlet weak var headerSectionLabel: UILabel!
    
    //Properties for storing feteched drink/s data objects
    var baseIngredients = [String]() //Base ingredient
    var baseIngredientDrinks = [List]() //List of drinks made with base ingredient
    var drinks = [Drink]() //Recent drinks
    var drink: Drink?
    var currentBaseIngredient = String() //for tracking currently selected base ingredient
    
    //MARK:- Built-in CollectionView Life-Cycle handlers
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Fire fetch Base Ingrediets list
        performSelector(inBackground: #selector(fetchBaseIngredientList), with: nil)
        
        //Fetch List of Drinks made with Base Ingredient
        performSelector(inBackground: #selector(fetchDrinksList), with: "vodka")
        
        //Fire fetch Recents Drink
        performSelector(inBackground: #selector(performFetchRecentDrinks), with: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = true

        // Register cell classes and nibs
        //Section 0 cells
        collectionView.register(UINib(nibName: "BaseIngredientCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BaseIngredientCell")
        
//        //Section 1 cells
        collectionView.register(UINib(nibName: "DrinkCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BaseIngredientDrinkCell")

        //section 2 cells
        collectionView.register(UINib(nibName: "DrinkCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RecentDrinkCell")
        

        //Setup initial UI
        //Load navigationBar items
//        self.setUpNavigationBar()
        
        //set compositionViewLayout
        self.collectionView.collectionViewLayout = self.setUpUICollectionViewCompositionLayout()
        
    }
    
    //MARK:- UICollectionViewCompositionalLayout setup
    //Define / configure and create UICollectionView compositional layout
    func setUpUICollectionViewCompositionLayout() -> UICollectionViewCompositionalLayout {
        
        //Define Layout
        let layout = UICollectionViewCompositionalLayout { [weak self]
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
        
            switch Section(rawValue: sectionIndex) {
            
            case .baseIngredients:
                return self?.setUpBaseIngredientsSection()
            
            case .baseIngredientDrinks:
                return self?.setUpBaseIngredientDrinksSection()
            
            case .drinks:
                return self?.setUpRecentDrinksSection()
            
            case .none:
                fatalError("Should not be none ")
            }
        }
        return layout
    }
    
    //Section 0 setup
    func setUpBaseIngredientsSection() -> NSCollectionLayoutSection {
        
        //Define Item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 8.0, bottom: 0.0, trailing: 8.0)
        
        //Define Group
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .estimated(136),
                                               heightDimension: .absolute(44)),
            subitem: item,
            count: 1)
        
        //Define Section
        let section = NSCollectionLayoutSection(group: group)

        let headerView = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(44)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        headerView.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [headerView]

        section.contentInsets = NSDirectionalEdgeInsets(top: 16.0,
                                                        leading: 0.0,
                                                        bottom: 16.0,
                                                        trailing: 0.0)

        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        return section
    }
    
    //Section 1 setup
    func setUpBaseIngredientDrinksSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1.0)))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                               heightDimension: .absolute(80)),
            subitem: item,
            count: 1)
        let section = NSCollectionLayoutSection(group: group)

        let headerView = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(44)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        headerView.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [headerView]

        section.contentInsets = NSDirectionalEdgeInsets(top: 16.0,
                                                        leading: 0.0,
                                                        bottom: 16.0,
                                                        trailing: 0.0)
        
        //Set horizntal scrolling for this section
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
    
    //Section 2 setup
    func setUpRecentDrinksSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                               heightDimension: .fractionalHeight(0.9))) // This height does not have any effect. Bug?
        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(
            leading: NSCollectionLayoutSpacing.flexible(0.0),
            top: NSCollectionLayoutSpacing.flexible(0.0),
            trailing: NSCollectionLayoutSpacing.flexible(0.0),
            bottom: NSCollectionLayoutSpacing.flexible(0.0))

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.60)),
            subitem: item,
            count: 1)
        
        let section = NSCollectionLayoutSection(group: group)

        let headerView = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(44)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        headerView.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [headerView]

        section.interGroupSpacing = 20
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 16.0,
                                                        leading: 0.0,
                                                        bottom: 16.0,
                                                        trailing: 0.0)
        return section
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
            self.loadActivitySpinner()
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
                ActivitySpinnerViewController.shared.willMove(toParent: nil)
                ActivitySpinnerViewController.shared.view.removeFromSuperview()
                ActivitySpinnerViewController.shared.removeFromParent()
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
    func loadActivitySpinner() {
    
        //Add to relevant view
        addChild(ActivitySpinnerViewController.shared)
        
        //Add spinner view to view controller
        ActivitySpinnerViewController.shared.view.frame = view.bounds

        view.addSubview(ActivitySpinnerViewController.shared.view)
        ActivitySpinnerViewController.shared.didMove(toParent: self)
    }
    
    //MARK:- Data Fetching methods
    @objc func performFetchDrinksImage() {
        
        if let imageURL = drink?.imageURL {
            DrinksController.shared.fetchDrinkImage(with: imageURL) { (image, error) in
                if let drinkImage = image {
                
//                    self.drinkImage = drinkImage
                
                //catch any errors fetching image
                } else if let error = error {
                    print("Error fetching image with error \(error.localizedDescription)\n")
                }
            }
        }
    }
    
    //Fetch List of Base Ingredients (ie: Vodka, Bitters, etc)
    @objc func fetchBaseIngredientList() {
        
        //fire fetch drinks list method
        DrinksController.shared.fetchList(from: "/list.php", using: [URLQueryItem(name: "i", value: "list")]) { (fetchedList, error) in
        
            //If success, set fetechedList data to baseIngredients property
            if let list = fetchedList {
                self.baseIngredients = list.map( { $0.baseIngredient! } )
                self.updateUI()
                print("Fetched Base ingredient list. Items:  \(self.baseIngredients.count)\n")
            }
            
            //if error, fire error meessage
            if let error = error {
                print("Error fetching ingredients list with error: \(error.localizedDescription)\n")
            }
        }
    }
    
    
    //Fetch Selected Base Ingredient Drinks List (drinks made wih specific Base ingredient)
    @objc func fetchDrinksList(for baseIngredient: String) {
        
        //fire fetch list method
        DrinksController.shared.fetchList(from: "/filter.php", using: [URLQueryItem(name: "i", value: baseIngredient)]) { (fetchedList, error) in
       
           //If success, set fetechedList data to drinksList property
           if let list = fetchedList {
                self.baseIngredientDrinks = list
                self.currentBaseIngredient = baseIngredient
                self.updateUI()
                print("Fetched drink list made with Base ingredient. Items: \(self.baseIngredientDrinks.count)\n")
           }
           
           //if error, fire error meessage
           if let error = error {
               print("Error fetching drinks list with error: \(error.localizedDescription)\n")
           }
        }
    }
    
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
        return 3
    }

    //Define number of items per section
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch Section(rawValue: section) {
        
        case .baseIngredients:
            return baseIngredients.count
            
        case .baseIngredientDrinks:
            return baseIngredientDrinks.count
            
        case .drinks:
            return drinks.count
            
        case .none:
            fatalError("Section should not be none")
        }

    }
    
    //Define section headers
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            
            //Instantiate SectionHeaderCollectionReusableView
            let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView", for: indexPath)
            as! SectionHeaderCollectionReusableView
            
            switch Section(rawValue: indexPath.section) {
            
            case .baseIngredients:
                sectionHeaderView.setHeaderLabel(text: "Tap a Drink Base")
            
            case .baseIngredientDrinks:
                sectionHeaderView.setHeaderLabel(text: "'\(currentBaseIngredient.capitalized)' Drinks")
            
            case .drinks:
                sectionHeaderView.setHeaderLabel(text: "Drinks Trending")
            
            case .none:
                fatalError("Should not be none")
            }
            
            return sectionHeaderView
            
        } else {
            
            return UICollectionReusableView()
        }
    }
    
    //Define cells / content per section item
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Configure the cell for each section
        switch Section(rawValue: indexPath.section) {
            
        //Section 0
        case .baseIngredients:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BaseIngredientCell", for: indexPath) as? BaseIngredientCollectionViewCell
            else {
                preconditionFailure("Invalid cell type")
            }
            
            //Cell Button text
            let ingredient = baseIngredients[indexPath.item]
            cell.setButton(title: ingredient)
            return cell
        
        //Section 1
        case .baseIngredientDrinks:
            guard let cell = collectionView.dequeueReusableCell(
              withReuseIdentifier: "BaseIngredientDrinkCell", for: indexPath) as? DrinkCollectionViewCell
              else {
                preconditionFailure("Invalid cell type")
            }
            
            //Cell text
            let drink = baseIngredientDrinks[indexPath.item]
            cell.setLabel(text: drink.name!)
            
            //cell image
            //Fetch and set drink image
            if let imageURL = drink.imageURL {
               
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

                           //Refresh cell to display fetched image
                           cell.setNeedsLayout()
                       }

                   //catch any errors fetching image
                   } else if let error = error {
                       print("Error fetching image with error \(error.localizedDescription)\n")
                   }
               }
            
            }
        return cell
            
        //Section 2
        case .drinks:
            guard let cell = collectionView.dequeueReusableCell(
              withReuseIdentifier: "RecentDrinkCell", for: indexPath) as? DrinkCollectionViewCell
              else {
                preconditionFailure("Invalid cell type")
            }
            
            let drink = drinks[indexPath.item]
            
            //Set cell properties
            //Cell text
            cell.setLabel(text: drink.name)
            
            //cell image
            //Fetch and set drink image
            if let imageURL = drink.imageURL {
               
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

                           //Refresh cell to display fetched image
                           cell.setNeedsLayout()
                       }

                   //catch any errors fetching image
                   } else if let error = error {
                       print("Error fetching image with error \(error.localizedDescription)\n")
                   }
               }
            
            }
            return cell
        
        case .none:
            fatalError("Should not be none")
        }
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
    
    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
}
