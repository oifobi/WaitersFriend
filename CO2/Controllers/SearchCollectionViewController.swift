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
    var searchText: String!
    
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
    
    override func viewDidDisappear(_ animated: Bool) {
        collectionView.backgroundView = nil
            //reset bacground view to clear empty state view
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
        collectionView.collectionViewLayout = createCollectionViewFlowLayout()
        
    }
    
    
    //set flow layout
    func createCollectionViewFlowLayout() -> UICollectionViewFlowLayout {
            
        //configure width of cells / columns based on 3 column layout
        let numberOfColumns: CGFloat = 2
        
        //set properies to calculate cell width
        let viewWidth = view.bounds.width //CGFloat value
        let edgeInsetsPadding: CGFloat = 20
        let minimumCellSpacing: CGFloat = 20 * (numberOfColumns - 1)
            //*n to account for number of spcaes between all columns
        
        //calculate cell width
        let availableWidthForCell = viewWidth - (edgeInsetsPadding * 2) - minimumCellSpacing
            //edgeInsets *2 to allow for both left + right edges of screen
        
        //set cell width
        let cellWidth = availableWidthForCell / numberOfColumns
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = layout.setEdgeInsets(to: edgeInsetsPadding) 
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth + 20)
        
        return layout
    }


     func configureCollectionViewCell() {
        collectionViewDataSource = UICollectionViewDiffableDataSource<CollectionViewSection, Drink>(collectionView: self.collectionView, cellProvider: {
            
             (collectionView, indexPath, drink) -> UICollectionViewCell? in
             
             //same code tha usually goes in cellforRowAt dataSource delegate
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DrinkCollectionViewCell.reuseIdentifier, for: indexPath) as! DrinkCollectionViewCell
             
             //set cell lables text
             cell.setTitleLabel(text: drink.name)
             
             //Fetch and set drink image
             if let urlString = drink.imageURL {
                 cell.setImage(with: urlString)
                 cell.setNeedsLayout()
             }
             
             return cell
         })
     }
    
    
    func updateUI() {
        DispatchQueue.main.async {
            self.updateCollectionViewSnapshotData(with: self.drinks)
            
            if !self.drinks.isEmpty {
                self.collectionView.backgroundView = nil
            }
        }
    }
    
    
    //MARK:- CollectionView Data Fetching methods
    func performFetchDrinks(from endpoint: String, queryName: String, queryValue: String) {
        spinner.startSpinner(viewController: self)
        
        NetworkManager.shared.fetchDrinks(from: endpoint, using: [URLQueryItem(name: queryName, value: queryValue)]) { [weak self] (result) in
            guard let self = self else { return }
            
            self.spinner.stopSpinner()
            
            switch result {
            case .success(let drinks):
                self.drinks = drinks
                self.drinks.sort(by: {$0.name < $1.name} )
                self.updateUI()
                
            case .failure(let error):
                switch error {
                case .unableToCompleteRequest:
                    self.presentErrorAlertVC(title: "Uh Oh!", message: error.rawValue, buttonText: "OK",
                    action: UIAlertAction(title: "Try again?", style: .default, handler: { action in
                        self.performFetchDrinks(from: NetworkCallEndPoint.search, queryName: NetworkCallQueryType.drinkName, queryValue: self.searchText)
                    }))
                    
                //catch keyword search errrors
                case .unableToDecodeData:

                    DispatchQueue.main.async {
                        let emptyView = WFEmptyStateView(labelText: error.rawValue)
                        self.drinks.removeAll()
                        self.collectionView.backgroundView = emptyView
                        self.updateUI()
                    }
                    
                case .invalidDataReturned:
                    print("Data fetch error: \(error.rawValue)")
                    
                default:
                    break
                }//inner switch
                
            }//outer switch
        }
    }
}


//MARK:- Extension: UISearch Results / Delegate
extension SearchCollectionViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.isEmpty else { return }
 
        searchText = text.lowercased()
        
        //fetch drink name
        performFetchDrinks(from: NetworkCallEndPoint.search, queryName: NetworkCallQueryType.drinkName, queryValue: searchText)
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
