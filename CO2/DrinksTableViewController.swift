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

//MARK:- Custom tableView cell definition
class DrinkTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var drinkImageView: UIImageView!
}

//MARK:- Class Definition
class DrinksTableViewController: UITableViewController {
    
    //Property to store Table section index
    var tableSectionsIndex: [(key: Substring, value: [Drink])]?
    
    //MARK:- Built in view management methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Fire fetch data depending in Tab Bar Item selected
        performSelector(inBackground: #selector(fireFetchDrinks), with: nil)
    }
    
    //MARK:- Custom Get Data / setup UI methods
    
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
        DrinksController.shared.fetchDrinks(from: endpoint) { (fetchedDrinks, error) in
        
            //fire UI update if fetch successful
            if let drinks = fetchedDrinks {
                DrinksController.drinks = drinks
                self.updateUI()
//                print("Fetched Drinks: \(drinks)\n")
            
            //fire error handler if error
            } else {
                if let error = error {
                self.showAlert(with: error)
                }
            }
        }
    }
    
    func updateUI() {
        
        var title = String()
        switch navigationController?.tabBarItem.tag {
        case TabBarItem.Popular.rawValue:
            title = "Top Rated Drinks"
            
        case TabBarItem.Recents.rawValue:
            title = "Trending Drinks"
            
        default:
            break
        }
        
        DispatchQueue.main.async {
            self.title = title
            self.createTableSectionsIndex()
            self.tableView.reloadData()
        }
    }
    
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
    
    //setup tableViewIndex
    func createTableSectionsIndex() {
        
        guard DrinksController.drinks != nil else {return }
        
        let names = DrinksController.drinks!.map {$0.name}.sorted()
        print("Drink names: \(names)\n")
        
        //create dictionary of letters to for index (based on first letter of Drinks name), then sort by keys
        let dict = Dictionary(grouping: DrinksController.drinks!, by: { $0.name.prefix(1)})
        
        tableSectionsIndex = dict.sorted(by: {$0.key < $1.key})
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        guard tableSectionsIndex != nil else {return 0}
        
        //set number of sections based on number of section title objects
        return tableSectionsIndex!.count
    }
    
    //set number of section rows based on number of drinks contained within in each section title
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard tableSectionsIndex != nil else { return 0 }
        
        //Get the number of rows per section by accessing the key's drinks count
        let section = tableSectionsIndex![section]
        return section.value.count
    }
    
    //set and display tbale section headings in tableView (Letter)
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard tableSectionsIndex != nil else { return "" }
        
        //Pull out the key value (Letter) and set as Section heading
        let title = tableSectionsIndex![section].key
        return String(title)
    }
    
    //set titles to display in index on RHS of tableView
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        guard tableSectionsIndex != nil else { return [""] }
        
        //create an array of all the letters for the table index, using the keys and transform to type string
        let titles = tableSectionsIndex!.map( { String($0.key) } )
        return titles
    }
    

    //method uses custom defined classs
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //point cellForRowAt method to custom cell class by down casting to custom class
        let cell = tableView.dequeueReusableCell(withIdentifier: "DrinkCell", for: indexPath) as! DrinkTableViewCell
        
    
        //get reference to the section (being shown
        if let section = tableSectionsIndex?[indexPath.section] {
        
            //get drinks for the section to be shown
            let drinks = section.value
        
        
            //ensure table rows matches drinks object array since the same tableView controller is used for different calls to fetch data
            if indexPath.row < DrinksController.drinks!.count {
            
//                if let drink = DrinksController.drinks?[indexPath.row] {
                let drink = drinks[indexPath.row]
                
                //set text of cell labels
                cell.titleLabel.text = drink.name
                cell.subtitleLabel.text = drink.ingredient1
            
                    //Fetch and set drink image
                    if let imageURL = drink.imageURL {
                        
                        DrinksController.shared.fetchDrinkImage(with:imageURL) { (fetchedImage, error) in
                            if let drinkImage = fetchedImage {

                                //Update cell image to fecthedImage via main thread
                                DispatchQueue.main.async {

                                    //Ensure wrong image isn't inserted into a recycled cell
                                    if let currentIndexPath = self.tableView.indexPath(for: cell),

                                        //If current cell index and table index don't match, exit fetch image method
                                        currentIndexPath != indexPath {
                                            return
                                        }

                                    //Set cell image
                                    cell.drinkImageView?.image = drinkImage

                                    //Update cell layout to accommodate image
                                    cell.setNeedsLayout()
                                }

                            //catch any errors fetching image
                            } else if let error = error {
                                print("Error fetching image with error \(error.localizedDescription)\n")
                            }
                        }
                    }
//                }
            }
        }
    

        return cell
    }
    
    
    // MARK: - Navigation
    //Set and push selected cell data to DetailVC
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destination
        if segue.identifier == "TableVCToDrinkDetailsVC" {
            let vc = segue.destination as! DrinkDetailsViewController
            let drinkTapped = tableView.indexPathForSelectedRow!.row
            vc.drink = DrinksController.drinks?[drinkTapped]
            vc.sender = "DrinksTableViewController"
            
        }
     }
    
}
