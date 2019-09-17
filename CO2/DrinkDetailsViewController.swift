//
//  CocktailDetailVC.swift
//  CO2
//
//  Created by Simon Italia on 9/9/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

class DrinkDetailsViewController: UIViewController, DrinkProtocol, UITableViewDataSource, UITableViewDelegate {
    
    //Delegate Method
    func json(fetched drinks: [Drink]) {
        self.drink = drinks[0]
        updateUI(sender: "TabBarItem")
        print("DrinkDetailsViewController protocol / delegate pattern working. Drinks fetched\n")
    }
    
    //Handle switching between segments
    var segmentControlIndex = 0 {
        didSet {
        
            switch segmentControlIndex {
            case 1:
                containerScrollView.isHidden = false
                ingredientsTableView.isHidden = true
                segmentedControl.selectedSegmentIndex = 1
                
            default:
                containerScrollView.isHidden = true
                ingredientsTableView.isHidden = false
                segmentedControl.selectedSegmentIndex = 0
            }
        }
    }
    
    //MARK:- Inteface Builder outlets and Actions
    @IBOutlet weak var drinkDetailsImageView: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        
        segmentControlIndex = sender.selectedSegmentIndex
    }
    
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    
    //MARK:- View / Class properties
    
    //Properties to receive drink object data from sender VC/s
    var drink: Drink?
    var sender: String?
    
    //update view image
    var drinkImage: UIImage? {
        didSet  {
            DispatchQueue.main.async {
                self.drinkDetailsImageView.image = self.drinkImage
            }
        }
    }
    
    //properties to construct and save ingredients
    var ingredients: [(key: String, value: String)]?
    var measures: [(key: String, value: String)]?
    
    
    //MARK:- Built-in View managemenet
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //Prepare Drink data content
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI(sender: self.sender)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        drinkImage = nil
        navigationController?.popToRootViewController(animated: false)
        
        //Reset segmented control default state
        segmentControlIndex = 0
    }
    
    //MARK:- Custom View management
    //perform UI setup
    func updateUI(sender: String?) {
        
        print("Sender is: \(self.sender ?? "nil")")
        
        //Set view as delegate
        DrinksController.shared.delegate = self
        
        DispatchQueue.main.async {
            
            //Fire fetch data depending on sender
            if sender == nil {
                self.performSelector(inBackground: #selector(self.fireFetchDrinks), with: nil)
                
            }
            
            //Fetch drink image from API server and set
            self.performSelector(inBackground: #selector(self.fireFetchDrinksImage), with: nil)
            
            //Get ingredients / meassure
            self.loadIngredientsTableData()
            print("Drink: \(String(describing: self.drink?.name))\n ID: \(String(describing: self.drink?.id))\n")
            
            //Set up How to prepare text
            self.instructionsLabel.text = self.drink?.instructions
            self.instructionsLabel.sizeToFit()
//            self.containerScrollView.contentSize = CGSize(width: self.view.frame.width - 10, height: 500)
            
            //Set navigation items
            self.title = self.drink?.name
            
        }
    }
    
    @objc func fireFetchDrinks() {
        let endpoint = DrinksController.random
        
        //fire fetch drinks list method
        DrinksController.shared.fetchDrinks(from: endpoint) { (error) in
            
            //fire error handler if error
            if let error = error {
                self.showAlert(with: error)
            }
        }
    }
    
    @objc func fireFetchDrinksImage() {
        
        if let imageURL = drink?.imageURL {
            DrinksController.shared.fetchDrinkImage(with: imageURL) { (image, error) in
                if let drinkImage = image {
                
                    self.drinkImage = drinkImage
                
                    //catch any errors fetching image
                } else if let error = error {
                    print("Error fetching image with error \(error.localizedDescription)\n")
                }
            }
        }
    }
    
    //Error alert handeler for data / image etc fetching issues
    func showAlert(with error: Error, sender: String = #function) {
        
        print("Error Alert called by: \(sender)\n")
        
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Uh Oh!", message: "\(error.localizedDescription)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Try again?", style: .default, handler: {
                action in self.fireFetchDrinks()
            }))
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
    
    //MARK:- TableView data prep method/s (TO BE FIXED!!)
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
    
}

