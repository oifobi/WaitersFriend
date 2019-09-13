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
        let list: String
        
        switch navigationController?.tabBarItem.tag {
        
        //fetch popular
        case 0:
            list = DrinksController.popular
            DrinksController.shared.fetchDrinks(list: list)
            title = "Popular Drinks"
        
        //fetch recent
        case 1:
            list = DrinksController.recent
            DrinksController.shared.fetchDrinks(list: list)
            title = "Recent Drinks"
         
        //fetch random
        case 2:
            list = DrinksController.random
            DrinksController.shared.fetchDrinks(list: list)
            title = "Featured Drink"
            
        default:
            break
        }
    }

    // MARK: - Table view data source
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }

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
            cell.subtitleLabel.text = drink.classification
            
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
 
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
