//
//  CocktailDetailVC.swift
//  CO2
//
//  Created by Simon Italia on 9/9/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

class DrinkDetailsViewController: UIViewController, DrinkProtocol {
    
    func json(fetched drinks: [Drink]) {
        self.drinks = drinks
        self.drink = drinks[0]
        updateUI()
        print("DrinkDetailsViewController protocol / delegate pattern working. Drinks fetched")
        
    }
    
    @IBOutlet weak var drinkDetailsImageView: UIImageView!
    
    //Property to store drinks data received via deleegat / protocol pattern
    var drinks: [Drink]?
    
    //Properties to receive drink object data from DrinksTableViewController
    var drink: Drink?
    var sender: Any?
    
    //Property to set Drink detail image. Set by either sending VC/s or by delegate pattern
    var drinkImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //Prepare data contents
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //if sender is DrinksTableVC, updateUI
        if let sender = sender {
            if sender as! String == "DrinksTableViewController" {
                updateUI()
            }
            
        //Get Drinks data and image
        } else {
            
            //Setup communication for when Drinks data is ready and needs to be passed from DrinkController to VC
            DrinksController.shared.delegate = self
            
            //Fire fetch data depending in Tab Bar Item selected
            performSelector(inBackground: #selector(fireFetchDrinks), with: nil)
        }
    }
    
    //perform UI setup
    func updateUI() {
        
        DispatchQueue.main.async {
            self.title = self.drink?.name
            self.navigationController?.navigationBar.prefersLargeTitles = true
            
            //load UIImage set by a sending VC
            if self.sender != nil {
                self.drinkDetailsImageView.image = self.drinkImage
            
            //load image fetched by this VC
            } else {
                //Fetch and set drink image
                self.performSelector(inBackground: #selector(self.fireFetchDrinksImage), with: nil)
            }
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
        
        if let imageURL = drinks?[0].imageURL {
            DrinksController.shared.fetchDrinkImage(with: imageURL) { (image, error) in
                if let drinkImage = image {
                
                    //set UIView image to image fetched
                    DispatchQueue.main.async {
                        self.drinkDetailsImageView.image = drinkImage
                    }
                
                    //catch any errors fetching image
                } else if let error = error {
                    print("Error fetching image with error \(error.localizedDescription)")
                }
            }
        }
    }
    
    //Error alert handeler for data / image etc fetching issues
    func showAlert(with error: Error, sender: String = #function) {
        
        print("Error Alert called by: \(sender)")
        
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Uh Oh!", message: "\(error.localizedDescription)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Try again?", style: .default, handler: {
                action in self.fireFetchDrinks()
            }))
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
    
}
