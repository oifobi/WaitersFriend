//
//  TableViewController.swift
//  CO2
//
//  Created by Simon Italia on 9/10/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

//Custom tableView cell definition
class drinkTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var drinkImageView: UIImageView!
    
}

class ViewController: UITableViewController, DrinkProtocol {
    
    //protocol conformance. Pass in drinks fetched to VC drinks property
    func jsonFetched(_ drinks: [Drink]) {
        self.drinks = drinks
        tableView.reloadData()
        print("protocol / delegate pattern working. Drink fetched")
    }
    
    //property to store drinks
    var drinks: [Drink]?
//    static var drinks2: [Drink]? //ViewController.drinks2

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure navigation bar title appearance
        navigationController?.navigationBar.prefersLargeTitles = true
       
        //Setup communication for when Drinks data is ready and needs to be passed from DrinkController to VC
        DrinksController.shared.delegate = self
        
        //Load performSelector on UI load
        performSelector(inBackground: #selector(fireFetchDrinks), with: nil)
    }
    
    //Fire fetch reequest and pass in drinks list paramter, based on tab item selected by user
    @objc func fireFetchDrinks() {
    
        //trigger fetch of JSON data from reemote server
        var list = String()
        var title = String()
        
        switch navigationController?.tabBarItem.tag {
        
        //fetch popular
        case 0:
            list = DrinksController.popular
            title = "Top Rated"
            
        //fetch recent
        case 1:
            list = DrinksController.recent
            title = "Recents"
            
        //fetch random
        case 2:
            list = DrinksController.random
            title = "Featured"
            
        default:
            break
        }
        
        //fire fetch drinks list method
        DrinksController.shared.fetchDrinks(list: list) { (error) in
        
            if let error = error {
                self.showErrorAlert(error)
            
            //Display VC title
            } else {
                DispatchQueue.main.async {
                    self.title = title
                }
            }
        }
        
    }
    
    func showErrorAlert(_ error: Error) {
        
        let ac = UIAlertController(title: "Error!", message: "\(error.localizedDescription)", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Try again?", style: .default, handler: {
            action in self.fireFetchDrinks()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .default))
        
        DispatchQueue.main.async {
            self.present(ac, animated: true)
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard drinks?.count != nil else {return 0}
        return drinks!.count
    }

    //method uses custome defined classs
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //point cellForRowAt method to custom cell class by down casting to custom class
        let cell = tableView.dequeueReusableCell(withIdentifier: "DrinkCell", for: indexPath) as! drinkTableViewCell
        
        if let drink = drinks?[indexPath.row] {
        
            //set text of cell labels
            cell.titleLabel.text = drink.name
            cell.subtitleLabel.text = drink.ingredient1
            
            //Fetch and set drink image
            DrinksController.shared.fetchDrinkImage(from: drink.imageURL!) { (fetchedImage) in
                guard let image = fetchedImage else { return }
                
                //Update cell image to fecthedImage via main thread
                DispatchQueue.main.async {

                    //Ensure wrong image isn't inserted into a recycled cell
                    if let currentIndexPath = self.tableView.indexPath(for: cell),

                        //If current cell index and table index don't match, exit method
                        currentIndexPath != indexPath {
                        return
                    }

                    //Set cell image
                    cell.drinkImageView?.image = image

                    //Update cell layout to accommodate image
                    cell.setNeedsLayout()
                }
            }
        }
        
        return cell
    }
    
    // MARK: - Navigation
    //Set and push selected cell data to DetailVC
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destination
        if segue.identifier == "DrinksVCtoDrinkDetailVC" {
            let vc = segue.destination as! DrinkDetailsVC
            let drink = tableView.indexPathForSelectedRow!.row
            vc.drink = drinks?[drink]
        }
     }
 
    
    

    

}
