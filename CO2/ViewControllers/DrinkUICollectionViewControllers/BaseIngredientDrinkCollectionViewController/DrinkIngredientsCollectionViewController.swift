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
}

class DrinkIngredientsCollectionViewController: UICollectionViewController {
    
    //Properties for storing feteched drink/s data objects
    var ingredients = [String]() //Base ingredient
    var ingredientDrinks = [List]() //List of drinks made with base ingredient
    var drink: Drink?
    var currentIngredient = String() //for tracking currently selected base ingredient
    
    //MARK:- Built-in CollectionView Life-Cycle handlers
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Fire fetch Base Ingrediets list
        performSelector(inBackground: #selector(fetchIngredientList), with: nil)
        
        //Fetch List of Drinks made with Base Ingredient
        performSelector(inBackground: #selector(fetchDrinksList), with: "vodka")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // preserve selection between presentations
//         self.clearsSelectionOnViewWillAppear = true

        // Register cell classes and nibs
        //Section Header (UILabel)
        collectionView.register(UINib(nibName: "DrinkIngredientSectionHeaderReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView")
        
        //Section 0 cells (UIButtons)
        collectionView.register(UINib(nibName: "DrinkIngredientsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BaseIngredientCell")
        
        //Section 1 cells (UIImageView + UILabel)
        collectionView.register(UINib(nibName: "DrinksCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DrinksCollectionView")
        
        
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
        
        //Define Section header
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
            
            //Set initial title and collectionView data
            self.title = "Drinks made by Ingredient"
            self.collectionView.reloadData()
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
    
    //Fetch List of Base Ingredients (ie: Vodka, Bitters, etc)
    @objc func fetchIngredientList() {
        
        //fire fetch drinks list method
        DrinksController.shared.fetchList(from: "/list.php", using: [URLQueryItem(name: "i", value: "list")]) { (fetchedList, error) in
        
            //If success, set fetechedList data to baseIngredients property
            if let list = fetchedList {
                self.ingredients = list.map( { $0.baseIngredient! } )
                self.updateUI()
                print("Fetched Base ingredient list. Items:  \(self.ingredients.count)\n")
            }
            
            //if error, fire error meessage
            if let error = error {
                print("Error fetching ingredients list with error: \(error.localizedDescription)\n")
            }
        }
    }
    
    
    //Fetch Selected Base Ingredient Drinks List (drinks made wih specific Base ingredient)
    @objc func fetchDrinksList(for ingredient: String) {
        
        //start / display activity spinner
        DispatchQueue.main.async {
            self.loadActivitySpinner()
        }
        
        //fire fetch list method
        DrinksController.shared.fetchList(from: "/filter.php", using: [URLQueryItem(name: "i", value: ingredient)]) { (fetchedList, error) in
       
           //If success, set fetechedList data to drinksList property
           if let list = fetchedList {
                self.ingredientDrinks = list
                self.currentIngredient = ingredient
                self.updateUI()
                print("Fetched drink list made with Base ingredient. Items: \(self.ingredientDrinks.count)\n")
           }
            
            //Stop and remove activity spinnner
            DispatchQueue.main.async() {
                ActivitySpinnerViewController.shared.willMove(toParent: nil)
                ActivitySpinnerViewController.shared.view.removeFromSuperview()
                ActivitySpinnerViewController.shared.removeFromParent()
            }
           
           //if error, fire error meessage
           if let error = error {
               print("Error fetching drinks list with error: \(error.localizedDescription)\n")
           }
        }
    }
    
    //Fetch drink details in prep tp pass to DrinkDetailsVC
    @objc func performFetchDrink(with id: String) {
        
        //fire fetch drink method
         DrinksController.shared.fetchDrink(from: "/lookup.php", using: [URLQueryItem(name: "i", value: id)]) { (fetchedDrink, error) in
        
            //If success,
            if let drink = fetchedDrink {
                self.drink = drink
                print("Fetched drink: \(String(describing: self.drink))\n")
                
                //perform segue to detailsVC
                DispatchQueue.main.async {
                
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "DrinkDetailsVC") as? DrinkDetailsViewController {
                        vc.drink = drink
                        vc.sender = "DrinkIngredientCollectionViewController"
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
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
        return 2
    }

    //Define number of items per section
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch Section(rawValue: section) {
        
        case .baseIngredients:
            return ingredients.count
            
        case .baseIngredientDrinks:
            return ingredientDrinks.count
            
        case .none:
            fatalError("Section should not be none")
        }

    }
    
    //Define section headers
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            
            //Instantiate SectionHeaderCollectionReusableView
            let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView", for: indexPath)
            as! DrinkIngredientSectionHeaderReusableView
            
            switch Section(rawValue: indexPath.section) {
            
            case .baseIngredients:
                sectionHeaderView.setHeaderLabel(text: "Base Ingredients")
            
            case .baseIngredientDrinks:
                sectionHeaderView.setHeaderLabel(text: "\(currentIngredient.capitalized) Drinks")
            
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
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BaseIngredientCell", for: indexPath) as? DrinkIngredientsCollectionViewCell
            else {
                preconditionFailure("Invalid cell type")
            }
            
            //Cell Button text
            let ingredient = ingredients[indexPath.item]
            cell.setButton(title: ingredient.capitalized)
            return cell
        
        //Section 1
        case .baseIngredientDrinks:
            guard let cell = collectionView.dequeueReusableCell(
              withReuseIdentifier: "DrinksCollectionView", for: indexPath) as? DrinksCollectionViewCell
              else {
                preconditionFailure("Invalid cell type")
            }
            
            //Cell text
            let drink = ingredientDrinks[indexPath.item]
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

        case .none:
            fatalError("Should not be none")
        }
        
        
    }
    
    // MARK: - Navigation
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //Fetch drink details
        let drink = ingredientDrinks[indexPath.item]
        performFetchDrink(with: drink.id!)
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//    }
    
}
