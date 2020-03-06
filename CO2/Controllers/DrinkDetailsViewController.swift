//
//  CocktailDetailVC.swift
//  CO2
//
//  Created by Simon Italia on 9/9/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

class DrinkDetailsViewController: UIViewController {
    
    enum CellIdentifier {
        static let tableViewCell = "IngredientCell"
    }
        
    //Handle switching between segments
    var segmentControlIndex = 0 {
        didSet {
        
            switch segmentControlIndex {
            case 1:
                ingredientsTableView.isHidden = true
                segmentedControl.selectedSegmentIndex = 1
                
            default:
                ingredientsTableView.isHidden = false
                segmentedControl.selectedSegmentIndex = 0
            }
        }
    }
    
    //MARK:- Inteface Builder outlets and Actions
    //Navigation Bar button Items
    //Favorites Button
    @IBOutlet weak var favoritesButton: UIBarButtonItem!
    @IBAction func favoritesButtonTapped(_ sender: UIBarButtonItem) {
        updateFavorites()
    }
    
    //Scrollview outlets
    @IBOutlet weak var instructionsScrollView: UIScrollView!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    //Stackview outlets
    //ImageView
    @IBOutlet weak var drinkDetailsImageView: UIImageView!
    
    //Detect and take action with Long press on UIViewImage
    @IBAction func drinkDetailsImageViewGesture(recognizer: UILongPressGestureRecognizer) {
      
      //set min duration before recognizer actions fire
      recognizer.minimumPressDuration = 0.25

      //trigger transform
      if recognizer.state == .began {
          self.becomeFirstResponder()
          
          //move recognizer view to front of all other views
          recognizer.view?.superview?.bringSubviewToFront(recognizer.view!)

          //set new image scaling
          drinkDetailsImageView.contentMode = .scaleAspectFit
          
          //set transforms
          recognizer.view?.transform = CGAffineTransform(scaleX: 2.5, y: 2.5).translatedBy(x: 0, y: 50)
      }
      
      //stop transform, reset to pre-transform state
      if recognizer.state == .ended {
          self.resignFirstResponder()
          
          //reset new image scaling
          drinkDetailsImageView.contentMode = .scaleAspectFill
          
          //reset transform
          recognizer.view?.transform = CGAffineTransform.identity
      }
    }
    
    //Segmenet controller
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl){
        segmentControlIndex = sender.selectedSegmentIndex
    }
    
    //tableView outlets
    @IBOutlet weak var ingredientsTableView: UITableView!

    //MARK:- View / Class properties
    //Properties to receive drink object data from sender VC/s
    var drink: Drink? {
        didSet {
            self.fireFetchImage()
        }
    }
    
    var image = UIImage()
    var isFavorite = false
        //track if drink is favorite
    
    var isFeatured = false
        //track if drink displayed is from featured
    
    //properties to construct and save ingredients
    var ingredients = [(key: String, value: String)]()
    var measures = [(key: String, value: String)]()
    
    //create spinner
    let spinner = SpinnerViewController()
    
    
    //MARK:- UIView Lifecycle
    //Prepare Drink data content
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if navigationController?.tabBarItem.tag == TabBarItemTag.featured {
            isFeatured = true
            fireFetchDrinkData()
        }
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureTabBar()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSegmentedControl()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Reset segmented control default state
        segmentControlIndex = 0
    }
    
    
    //MARK:- Fetch data methods
    func fireFetchDrinkData() {
        self.performSelector(inBackground: #selector(self.performFetchDrink), with: nil)
    }
    

    //Fetch drink image from API server and set
    func fireFetchImage() {
        self.performSelector(inBackground: #selector(self.performFetchDrinksImage), with: nil)
    }
    
    
    //MARK:- Custom View management
    func configureTabBar() {
        if isFeatured {
            self.tabBarController?.tabBar.isHidden = false
        
        } else {
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    

    func configureSegmentedControl() {
        
        //unselected
        segmentedControl.setTitleTextAttributes( [NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        //selected
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.black],
            for: .selected)
    }
    
    
    //Set navigation items
    func configureNavigationBar() {
        guard let drink = self.drink else { return }
        
        //set title
        self.title = drink.name
        
        //configue done button
        if !isFeatured {
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissViewController))
            navigationItem.leftBarButtonItem = doneButton
        }
        
        //configure favorites button
        if let _ = DataPersistenceManager.shared.getIndexOfFavorite(for: drink.id) {
             isFavorite = true
             favoritesButton.image = UIImage(systemName: SFSymbol.heartFill)
        
         } else { favoritesButton.image = UIImage(systemName: SFSymbol.heart) }
    }

    
    func configureTableView() {
        self.ingredientsTableView.hideEmptyCells()
        
        //Get ingredients / meassure
        self.loadIngredientsTableData()
        
        //Set up How to prepare text
        self.instructionsLabel.text = self.drink?.instructions
        self.instructionsLabel.sizeToFit()
    }
    
    
    //setup UI (triggered once image is set)
    func updateUI() {
        DispatchQueue.main.async {
            self.configureNavigationBar()
            self.drinkDetailsImageView.image = self.image
            self.configureTableView()
        }
    }
    
    
    //MARK:- Data fetch methods
    @objc func performFetchDrinksImage() {
        guard let drink = self.drink else { return }
        spinner.startSpinner(viewController: self)
        
        if let imageURL = drink.imageURL {
            NetworkManager.shared.fetchDrinkImage(with: imageURL) { [weak self] (fetchedImage, error) in
                guard let self = self else { return }
                
                self.spinner.stopSpinner()

                if let image = fetchedImage {
                    self.image = image
                    self.updateUI()
                }
                
                //catch any errors fetching image
                if let error = error {
                    print("Error fetching image with error \(error.localizedDescription)\n")
                }
            }
        }
    }
    
    
    @objc func performFetchDrink() {
        guard isFeatured else { return }
        
        let endpoint = NetworkCallEndPoint.random
        NetworkManager.shared.fetchDrink(from: endpoint, using: nil) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let drink):
                self.drink = drink
                    //triggers fetch of image
                
            case .failure(let error):
                self.presentErrorAlertVC(title: "Uh Oh!", message: error.rawValue, buttonText: "OK",
                action: UIAlertAction(title: "Try again?", style: .default, handler: { action in
                        self.performFetchDrink()
                }))
            }
        }
    }
    
  
    //MARK:- TableView data prep method/s (TO BE REFACTORED!)
    func loadIngredientsTableData() {
        ingredients = getIngredients()
        measures = getMeasures()
        ingredientsTableView.reloadData()
    }
    
    
    func getIngredients() -> [(key: String, value: String)] {
        var dict = [String: String]()
        
            dict["ingredient01"] = drink?.ingredient1
            dict["ingredient02"] = drink?.ingredient2
            dict["ingredient03"] = drink?.ingredient3
            dict["ingredient04"] = drink?.ingredient4
            dict["ingredient05"] = drink?.ingredient5
            dict["ingredient06"] = drink?.ingredient6
            dict["ingredient07"] = drink?.ingredient7
            dict["ingredient08"] = drink?.ingredient8
            dict["ingredient09"] = drink?.ingredient9
            dict["ingredient10"] = drink?.ingredient10
            dict["ingredient11"] = drink?.ingredient11
            dict["ingredient12"] = drink?.ingredient12
            dict["ingredient13"] = drink?.ingredient13
            dict["ingredient14"] = drink?.ingredient14
            dict["ingredient15"] = drink?.ingredient15
        
        //sort by key and transform into array of key/value pairs
        let sorted = dict.sorted(by: { $0.key < $1.key } )
        
        //filter empty properties and return result
        return sorted.filter({$0.value != "" || $0.value != " "})
    }
    
    
    func getMeasures() -> [(key: String, value: String)] {
        var dict = [String: String]()

            dict["measure01"] = drink?.measure1
            dict["measure02"] = drink?.measure2
            dict["measure03"] = drink?.measure3
            dict["measure04"] = drink?.measure4
            dict["measure05"] = drink?.measure5
            dict["measure06"] = drink?.measure6
            dict["measure07"] = drink?.measure7
            dict["measure08"] = drink?.measure8
            dict["measure09"] = drink?.measure9
            dict["measure10"] = drink?.measure10
            dict["measure11"] = drink?.measure11
            dict["measure12"] = drink?.measure12
            dict["measure13"] = drink?.measure13
            dict["measure14"] = drink?.measure14
            dict["measure15"] = drink?.measure15
        
        //sort by key and transform into array of key/value pairs
        let sorted = dict.sorted(by: { $0.key < $1.key } )
        
        //filter empty properties and return result
        return sorted.filter({$0.value != "" || $0.value != " "})
    }
    
    
    @objc func updateFavorites() {
        guard let drink = drink else { return }

        //remove
        if isFavorite {
            DataPersistenceManager.shared.updateFavorites2(with: drink, action: .remove) { (result) in
                
                switch result {
                case .success(let message):
                    self.favoritesButton.image = UIImage(systemName: SFSymbol.heart)
                    self.presentAlertVC(title: "💔 Drink Removed", message: "\(drink.name) \(message.rawValue)", buttonText: "OK")
                    self.isFavorite = false
                    
                case .failure(let error):
                    print(error.rawValue)
                }
            }
  
        //add
        } else {
            DataPersistenceManager.shared.updateFavorites2(with: drink, action: .add) { (result) in
                switch result {
                case .success(let message):
                    self.favoritesButton.image = UIImage(systemName: SFSymbol.heartFill)
                    self.presentAlertVC(title: "❤️ Drink Saved", message: "\(drink.name) \(message.rawValue)", buttonText: "OK")
                    self.isFavorite = true
                    
                case .failure(let error):
                    print(error.rawValue)
                }
            }
        }
    }
}


//MARK:- Extension TableView extension
extension DrinkDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { ingredients.count }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.tableViewCell, for: indexPath)
        
        //set cell ingredient text
        if  indexPath.row < ingredients.count {
            let ingredient = ingredients[indexPath.row]
            cell.textLabel!.text = ingredient.value
        }
        
        //set cell measure text
        if  indexPath.row < measures.count {
            let measure = measures[indexPath.row]
            cell.detailTextLabel!.text = measure.value
        }
        
        return cell
    }
}
