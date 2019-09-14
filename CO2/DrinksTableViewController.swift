//
//  TableViewController.swift
//  CO2
//
//  Created by Simon Italia on 9/10/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

enum TabBarItem: Int  {
    case Popular = 0
    case Recents = 1
    case Random = 2
    case Search = 3
}

//Custom tableView cell definition
class drinkTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var drinkImageView: UIImageView!
    
}

class DrinksTableViewController: UITableViewController, DrinkProtocol {
    
    //protocol conformance. Pass in drinks fetched to VC drinks property
    func json(fetched drinks: [Drink]) {
        self.drinks = drinks
//        tableView.reloadData()
        updateUI()
        print("DrinksTableViewController protocol / delegate pattern working. Drinks fetched")
    }
    
    //properties to store drinks and related images
    var drinks: [Drink]?
    var drinkImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup communication for when Drinks data is ready and needs to be passed from DrinkController to VC
        DrinksController.shared.delegate = self
        
        //Fire fetch data depending in Tab Bar Item selected
        performSelector(inBackground: #selector(fireFetchDrinks), with: nil)
    }
    
    //Fire fetch reequest and pass in drinks list paramter, based on tab item selected by user
    @objc func fireFetchDrinks() {
    
        //trigger fetch of JSON data from remote server
        var endpoint = String()
        
        //Fetch json from "Popular" and "Recents" API end points
        switch navigationController?.tabBarItem.tag {
        //fetch popular
        case TabBarItem.Popular.rawValue:
            endpoint = DrinksController.popular
        
        //fetch recent
        case TabBarItem.Recents.rawValue:
            endpoint = DrinksController.recent
        
        default:
            break
        }
    
        //fire fetch drinks list method
        DrinksController.shared.fetchDrinks(from: endpoint) { (error) in
        
            //fire error handler if error
            if let error = error {
                self.showAlert(with: error)
            }
        }
        
        //fire updateUI if no error
        updateUI()
       
    }
    
    func updateUI() {
        
        var title = String()
        
        switch navigationController?.tabBarItem.tag {
        case TabBarItem.Popular.rawValue:
            title = "Top Rated"
            
        case TabBarItem.Recents.rawValue:
            title = "Recents"
            
        default:
            break
        }
        
        DispatchQueue.main.async {
            self.title = title
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.tableView.reloadData()
        }
    }
    
    func showAlert(with error: Error) {
        
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Uh Oh!", message: "\(error.localizedDescription)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Try again?", style: .default, handler: {
                action in self.fireFetchDrinks()
            }))
            ac.addAction(UIAlertAction(title: "OK", style: .default))
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
            if let imageURL = drink.imageURL {
                
//                let image = fireFetchDrinkImage(with: imageURL)
                DrinksController.shared.fetchDrinkImage(with:imageURL) { (fetchedImage) in
                    guard let image = fetchedImage else { return }
                
                    //Update cell image to fecthedImage via main thread
                    DispatchQueue.main.async {

                        //Ensure wrong image isn't inserted into a recycled cell
                        if let currentIndexPath = self.tableView.indexPath(for: cell),

                            //If current cell index and table index don't match, exit method
                            currentIndexPath != indexPath {
                            return
                            }
                        
                        //append drinks images array with image
                        self.drinkImages.append(image)
                        
                        //Set cell image
                        cell.drinkImageView?.image = image

                        //Update cell layout to accommodate image
                        cell.setNeedsLayout()
                    }
                }
            }
        }
        return cell
    }
    
    @objc func fireFetchDrinkImage(with url: String) -> UIImage {
       
        var drinkImage = UIImage()
        DrinksController.shared.fetchDrinkImage(with: url) { (fetchedImage) in
            guard let image = fetchedImage else { return }
            drinkImage = image
        }
        
        return drinkImage
    }
    
    
    
    // MARK: - Navigation
    //Set and push selected cell data to DetailVC
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destination
        if segue.identifier == "TableVCToDrinkDetailsVC" {
            let vc = segue.destination as! DrinkDetailsViewController
            let drinkTapped = tableView.indexPathForSelectedRow!.row
            vc.drink = drinks?[drinkTapped]
            vc.drinkImage = drinkImages[drinkTapped]
            vc.sender = "DrinksTableViewController" 
        }
     }
    
}
