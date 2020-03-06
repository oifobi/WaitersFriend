//
//  DrinkSearchController.swift
//  CO2
//
//  Created by Simon Italia on 10/12/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

class SearchCollectionViewController: UICollectionViewController {
    
    
    enum CollectionViewSection {
        case main
    }
    
    
    enum Ingredient { static let margarita = "margarita" }
    
    
    //Properties for storing feteched drink/s data objects
    var drinks = [Drink]() //Search drinks
    var collectionViewDataSource: UICollectionViewDiffableDataSource<CollectionViewSection, Drink>!
    
    //Common/shared properties b/w TableView
    var drink: Drink?
    
    //create spinner
    let spinner = SpinnerViewController()
    
    
    //MARK:- UIView Lifecycle
    //Start fetch of data
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createSearchController()
            //applied here so kb will be active on each load of view
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureCollectionView()
        configureCollectionViewCell()
            //new method for configuring cells in iOS13
    }
    
    
    //MARK: ViewController setup
    func configureViewController() { title = ViewTitle.search }
    
    
    //MARK:- Search Controller setup (updates TableView Data)
    func createSearchController() {
        
        //Create / configure onfigure Search Controller
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.searchBar.delegate = self
        sc.searchBar.placeholder = "Search by cocktail (e.g. Margarita)"
        sc.searchBar.returnKeyType = UIReturnKeyType.search
        sc.obscuresBackgroundDuringPresentation = false
        
        //set created search controller to navigation controller
        navigationItem.searchController = sc
        
        //set sc as focus to trigger kb on load
        didPresentSearchController(sc)
    }
    
    
    //MARK: - Configure Views
    func configureCollectionView() {

        //CollectionView
        //Register cell classes and nibs
         collectionView.register(UINib(nibName: DrinkCollectionViewCell.nib, bundle: nil), forCellWithReuseIdentifier: DrinkCollectionViewCell.reuseIdentifier)
        
        //Set compositionViewLayout
        let layout = createCompositionalLayout()
        collectionView.collectionViewLayout = layout
    }
    
    
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {

        //Define Layout
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            //Define Item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 10.0, leading: 25.0, bottom: 15.0, trailing: 0.0)

            //Define Group
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .estimated(345),
                heightDimension: .estimated(250)), //wass .absolute(170)
                subitem: item,
                count: 2)

            //Define Section
            let section = NSCollectionLayoutSection(group: group)
            return section
        }

        return layout
    }
    
    
    func createFlowLayout() -> UICollectionViewFlowLayout {

        //Define Layout
        
        
        

        return UICollectionViewFlowLayout()
    }
    
    
    
    
    
     func configureCollectionViewCell() {
        collectionViewDataSource = UICollectionViewDiffableDataSource<CollectionViewSection, Drink>(collectionView: self.collectionView, cellProvider: {
            
             (collectionView, indexPath, drink) -> UICollectionViewCell? in
             
             //same code tha usually goes in cellforRowAt dataSource delegate
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkCollectionViewCell.reuseIdentifier, for: indexPath) as! DrinkCollectionViewCell
             
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
    
    
    //MARK:- CollectionView Data Fetching methods
    func performSearchForDrinks(from endpoint: String, queryName: String, queryValue: String) {
        spinner.startSpinner(viewController: self)
        
        NetworkManager.shared.fetchDrinks(from: endpoint, using: [URLQueryItem(name: queryName, value: queryValue)]) { [weak self] (result) in
            guard let self = self else { return }
            
            self.spinner.stopSpinner()
            
            switch result {
            case .success(let drinks):
                self.drinks = drinks
                self.drinks.sort(by: {$0.name < $1.name} )
                self.updateCollectionViewSnapshotData(with: self.drinks)
                
            case .failure(let error):
                print(error.rawValue)
            }
        }
    }
}


//MARK:- Extension: UISearch Results / Delegate
extension SearchCollectionViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else { return }
 
        
        //fetch drink name
        performSearchForDrinks(from: NetworkCallEndPoint.search, queryName: NetworkCallQueryType.drinkName, queryValue: text.lowercased())
    }
    
    
    //deelgate method to detect when sc is presented
    func didPresentSearchController(_ searchController: UISearchController) {

        DispatchQueue.main.async {
            searchController.searchBar.becomeFirstResponder()
        }
    }
    
    
}


//MARK:- Extension CollectionView Diffable DataSource
extension SearchCollectionViewController {
    
    func updateCollectionViewSnapshotData(with drinks: [Drink]) {
        var snapshot = NSDiffableDataSourceSnapshot<CollectionViewSection, Drink>()
        snapshot.appendSections([.main])
        snapshot.appendItems(drinks)
        self.collectionViewDataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
}


//MARK:- Extension CollectionView Delegate
//extension DrinkSearchViewController: UICollectionViewDelegate {
extension SearchCollectionViewController {

    //MARK:- Navigation
    //Send to DrinkDetailsVC when cell tapped
        override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let drink = drinks[indexPath.item]
        presentDestinationVC(with: StoryboardIdentifier.drinkDetailsVC, for: drink)
    }
}
