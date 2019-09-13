//
//  CocktailDetailVC.swift
//  CO2
//
//  Created by Simon Italia on 9/9/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

class DrinkItemDetailVC: UIViewController {
    
    @IBOutlet weak var drinkItemImage: UIImageView!
    
    //Property to receive drink object from Main VC
    var drink: Drink?
    var drinkImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let image = drinkImage {
            drinkItemImage.image = image
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
