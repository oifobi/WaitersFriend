//
//  CocktailDetailVC.swift
//  CO2
//
//  Created by Simon Italia on 9/9/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit
import WebKit

class DrinkDetailsVC: UIViewController {
    
    @IBOutlet weak var drinkDetailsImage: UIImageView!
    
    //Property to receive drink object from Main VC
    var drink: Drink?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //fire updateUI
        updateUI()
    }
    
    //perform UI setup
    func updateUI() {
        
        //set nav title
        title = drink?.name
        
        //fetch image
        guard let drink = drink else {
            return
        }
        
        print("Drink object found. Loading contents")
        DrinksController.shared.fetchDrinkImage(from: drink.imageURL!) { (fetchedImage) in
            guard let image = fetchedImage else {
                return
            }
            
            DispatchQueue.main.async {
                self.drinkDetailsImage.image = image
            }
        }
    }
    
}
