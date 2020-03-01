//
//  CocktailDetailVC.swift
//  CO2
//
//  Created by Simon Italia on 9/9/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

class DrinkDetailsViewController: UIViewController {
    
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
    //Favorites on NavigationBarItem
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
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
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
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        
        segmentControlIndex = sender.selectedSegmentIndex
    }
    
    //tableView outlets
    @IBOutlet weak var ingredientsTableView: UITableView!

    //MARK:- View / Class properties
    
    //Properties to receive drink object data from sender VC/s
    var drink: Drink?
    var sender: String?
    
    //update view image
    var drinkImage: UIImage? {
        didSet  {
            DispatchQueue.main.async {
                self.drinkDetailsImageView.image = self.drinkImage
                self.drinkDetailsImageView.setNeedsDisplay()
            }
        }
    }
    
    //properties to construct and save ingredients
    var ingredients: [(key: String, value: String)]?
    var measures: [(key: String, value: String)]?
    
    //create spinner
    let spinner = SpinnerViewController()
    
    //MARK:- Built-in View managemenet
    //Prepare Drink data content
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI(sender: self.sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.popToRootViewController(animated: false)
        
        //Reset segmented control default state
        segmentControlIndex = 0
        
//        //unset drink image so it's not loaded on navigation back VC
//        drinkImage = nil
//        drinkDetailsImageView.setNeedsDisplay()
    }
    
    
    //MARK:- Custom View management
    //perform UI setup
    func updateUI(sender: String?) {
        
        DispatchQueue.main.async {
            
            //Fire fetch data depending on sender (if featured tab item tapped)
            if sender == nil {
                
                //ovveride hideBottomBarOnPush (from storyboard)
                self.tabBarController?.tabBar.isHidden = false
                self.performSelector(inBackground: #selector(self.performFetchDrink), with: nil)
            }

            //Fetch drink image from API server and set
            self.performSelector(inBackground: #selector(self.performFetchDrinksImage), with: nil)
            
            //Setup tableView
            //Hide footer section
            self.ingredientsTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            
            //Get ingredients / meassure
            self.loadIngredientsTableData()

            //Set up How to prepare text
            self.instructionsLabel.text = self.drink?.instructions
            self.instructionsLabel.sizeToFit()
            
            //Set navigation items
            self.title = self.drink?.name
            
            //Set Favorites icon state
            if let id = self.drink?.id {
                if let _ = DataPersistenceManager.shared.getDrinkIndex(for: id) {
                    self.favoritesButton.image = UIImage(systemName: SFSymbol.heartFill)
                    
                } else {
                    self.favoritesButton.image = UIImage(systemName: SFSymbol.heart)
                }
            }
        }
    }
    
    
    @objc func performFetchDrink() {
        let endpoint = EndPoint.random
        NetworkManager.shared.fetchDrink(from: endpoint, using: nil) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let drink):
                self.updateUI(sender: "TabBarItem")
                self.drink = drink
                
            case .failure(let error):
                self.presentErrorAlertVC(title: "Uh Oh!", message: error.rawValue, buttonText: "OK",
                action: UIAlertAction(title: "Try again?", style: .default, handler: { action in
                        self.performFetchDrink()
                }))
            }
        }
    }
    
    
    @objc func performFetchDrinksImage() {
        self.drinkImage = nil
        spinner.startSpinner(viewController: self)

        if let imageURL = drink?.imageURL {
            NetworkManager.shared.fetchDrinkImage(with: imageURL) { [weak self] (fetchedImage, error) in
                guard let self = self else { return }
                
                self.spinner.stopSpinner()
                if let image = fetchedImage {
                    self.drinkImage = image
                }
                
                //catch any errors fetching image
                if let error = error {
                    print("Error fetching image with error \(error.localizedDescription)\n")
                }
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
    
    
    func updateFavorites() {
        guard let drinkID = drink?.id, let drinkName = drink?.name else { return }
        
        //If drink already saved, remove from favorites
        if let index = DataPersistenceManager.shared.getDrinkIndex(for: drinkID) {
            DataPersistenceManager.favorites.remove(at: index)
            favoritesButton.image = UIImage(systemName: SFSymbol.heart)
            presentAlertVC(title: "\(Emoji.redBrokenHeart) Drink Removed", message: "\(drinkName) \(WFSuccess.favoriteRemoved.rawValue)", buttonText: "OK")

        //If drink not already saved, save to favorites
        } else {
            DataPersistenceManager.favorites.append(drink!)
            favoritesButton.image = UIImage(systemName: SFSymbol.heartFill)
            presentAlertVC(title: "\(Emoji.redHeart) Drink Saved", message: "\(drinkName) \(WFSuccess.favoriteSaved.rawValue).", buttonText: "OK")
        }
    }
}


//MARK:- TableView extension
extension DrinkDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath)
        
        //set cell ingredient text
        if  indexPath.row < ingredients!.count {
            if let ingredient = ingredients?[indexPath.row] {
                cell.textLabel!.text = ingredient.value
            }
        }
        
        //set cell measure text
        if  indexPath.row < measures!.count {
            if let measure = measures?[indexPath.row] {
                cell.detailTextLabel!.text = measure.value
            }
        }
        
        return cell
    }
}
