//
//  CocktailDetailVC.swift
//  CO2
//
//  Created by Simon Italia on 9/9/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

class DrinkDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
//          print("Long Press started")
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
//          print("Long press ended")
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
    
    //MARK:- Built-in View managemenet
    //Prepare Drink data content
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //setup UI
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
        
        //unset drink image so it's not loaded on navigation back VC
        drinkImage = nil
        drinkDetailsImageView.setNeedsDisplay()
    }
    
    //MARK:- Custom View management
    //perform UI setup
    func updateUI(sender: String?) {
        
        print("Sender is: \(self.sender ?? "nil")")
        
        DispatchQueue.main.async {
            
            //Fire fetch data depending on sender
            if sender == nil {
                
                self.performSelector(inBackground: #selector(self.performFetchDrink), with: nil)
            }
            
            //Fetch drink image from API server and set
            self.performSelector(inBackground: #selector(self.performFetchDrinksImage), with: nil)
            
            //Get ingredients / meassure
            self.loadIngredientsTableData()
//            print("Drink: \(String(describing: self.drink?.name))\n ID: \(String(describing: self.drink?.id))\n")
            
            //Set up How to prepare text
            self.instructionsLabel.text = self.drink?.instructions
            self.instructionsLabel.sizeToFit()
            
            //Set navigation items
            self.title = self.drink?.name
            
            //Set Favorites icon state
            if let id = self.drink?.id {
                if let _ = FileManagerController.shared.getDrinkIndex(for: id) {
                        self.favoritesButton.image = UIImage(systemName: "heart.fill")
                    
                } else {
                    self.favoritesButton.image = UIImage(systemName: "heart")
                }
            }
        }
    }
    
    @objc func performFetchDrink() {
        let endpoint = EndPoint.random.rawValue
        DrinksController.shared.fetchDrink(from: endpoint, using: nil) { (fetchedDrink, error) in
        
            //fire fetch drinks method
            //If success,
            if let drink = fetchedDrink {
                self.updateUI(sender: "TabBarItem")
                self.drink = drink
//                print("Fetched drink: \(String(describing: self.drink))\n")
            }
            
            //if error, fire error meessage
            if let error = error {
                self.showErrorAlert(with: error)
                print("Error fetching drink with error: \(error.localizedDescription)\n")
            }
        }
    }
    
    @objc func performFetchDrinksImage() {
        
        //Show and start activity indicator animation
        DispatchQueue.main.async {
            self.startActivitySpinner()
        }
        
        if let imageURL = drink?.imageURL {
            DrinksController.shared.fetchDrinkImage(with: imageURL) { (fetchedImage, error) in
                
                if let image = fetchedImage {
                    self.drinkImage = image
                }
                
                //Stop and hide activity indicator animation
                DispatchQueue.main.async {
                    self.stopActivitySpinner()
                }
                //catch any errors fetching image
                if let error = error {
                    print("Error fetching image with error \(error.localizedDescription)\n")
                }
            }
        }
    }
    
    //Activity indicator / spinner
    func startActivitySpinner() {
    
        //Add to relevant view
        addChild(ActivitySpinnerViewController.shared)
        
        //Add spinner view to view controller
        ActivitySpinnerViewController.shared.view.frame = view.bounds

        view.addSubview(ActivitySpinnerViewController.shared.view)
        ActivitySpinnerViewController.shared.didMove(toParent: self)
    }
    
    func stopActivitySpinner() {
        
        ActivitySpinnerViewController.shared.willMove(toParent: nil)
        ActivitySpinnerViewController.shared.view.removeFromSuperview()
        ActivitySpinnerViewController.shared.removeFromParent()
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
        
        //If drink already saved, remove from favorites
        if let index = FileManagerController.shared.getDrinkIndex(for: drink!.id) {
            FileManagerController.drinks.remove(at: index)
            favoritesButton.image = UIImage(systemName: "heart")
            showAddToFavoritesAlert(title: "❌ Drink Removed", message: "\(drink!.name) removed from Favorites")

        //If drink not already saved, save to favorites
        } else {
            FileManagerController.drinks.append(drink!)
            favoritesButton.image = UIImage(systemName: "heart.fill")
            showAddToFavoritesAlert(title: "❤️ Drink Saved", message: "\(drink!.name) saved to Favorites")
        }
    }

    
    //MARK:- TableView methods
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
    
    //MARK:- Alert Controllers
    
    //Error alert handeler for data / image etc fetching issues
    func showErrorAlert(with error: Error, sender: String = #function) {
        
        print("Error Alert called by: \(sender)\n")
        
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Uh Oh!", message: "\(error.localizedDescription)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Try again?", style: .default, handler: {
                action in self.performFetchDrink()
            }))
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
    
    //Save to Favorites Alert confirmation
    func showAddToFavoritesAlert(title: String, message: String) {
//        print(title, message)
        DispatchQueue.main.async {
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
}

