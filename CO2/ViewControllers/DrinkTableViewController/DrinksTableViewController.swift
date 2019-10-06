//
//  TableViewController.swift
//  CO2
//
//  Created by Simon Italia on 9/10/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

//MARK:- Class Definition
class DrinksTableViewController: UITableViewController {
    
    //Property to store fetched data when called
    var drinks: [Drink]? 
    
    //Property to store Table section index
    var tableSectionsIndex: [(key: Substring, value: [Drink])]?
    
    //MARK:- Built in view management methods
    override func viewWillAppear(_ animated: Bool) {
        
        //Fire fetch data depending in Tab Bar Item selected
        if drinks == nil {
            performSelector(inBackground: #selector(performFetchDrinks), with: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK:- Custom Get Data / setup UI methods
    
    //Fire fetch reequest and pass in drinks list paramter, based on tab item selected by user
    @objc func performFetchDrinks() {
    
        //trigger fetch of JSON data from remote server
        DispatchQueue.main.async {
            
            //start / display activity spinner
            self.startActivitySpinner()

            //fire fetch drinks list method
            DrinksController.shared.fetchDrinks(from: EndPoints.popular.rawValue) { (fetchedDrinks, error) in
            
                //fire UI update if fetch successful
                if let drinks = fetchedDrinks {
                    self.drinks = drinks
                    self.updateUI()
    //                print("Fetched Drinks: \(drinks)\n")
                }
                
                //Stop and remove activity spinnner
                DispatchQueue.main.async() {
                    self.stopActivitySpinner()
                }
                
                //fire error handler if error
                if let error = error {
                    self.showAlert(with: error)
                }
            }
        }
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            self.title = "Top Rated Drinks"
            self.createTableSectionsIndex()
            self.tableView.reloadData()
        }
    }
    
    func showAlert(with error: Error, sender: String = #function) {
        print("Error Alert called by: \(sender)\n")
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Uh Oh!", message: "\(error.localizedDescription)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Try again?", style: .default, handler: {
                action in self.performFetchDrinks()
            }))
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
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
    
    //setup tableViewIndex
    func createTableSectionsIndex() {
        
        guard drinks != nil else { return }
        
        //create dictionary of letters to for index (based on first letter of Drinks name), then sort by keys
        let dict = Dictionary(grouping: drinks!, by: { $0.name.prefix(1)})
        
        tableSectionsIndex = dict.sorted(by: {$0.key < $1.key})
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard tableSectionsIndex != nil else { return 0 }
        
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
            if indexPath.row < drinks.count {
            
            let drink = drinks[indexPath.row]
            
                //set cell lables text
                cell.setTitleLabel(text: drink.name)
                cell.setSubtitleLabel(text: drink.ingredient1 ?? "")
                    
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
                                cell.setImage(drinkImage)

                                //Refresh cell to display fetched image
                                cell.setNeedsLayout()
                            }

                        //catch any errors fetching image
                        } else if let error = error {
                            print("Error fetching image with error \(error.localizedDescription)\n")
                        }
                    }
                }
            }
        }
        
        return cell
    }

    // MARK: - Navigation
    //Set and push selected cell data to DetailVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destination
        if segue.identifier == "DrinksTableVCToDrinkDetailsVC" {
            let vc = segue.destination as! DrinkDetailsViewController
            
            let sectionIndexOfRowTapped = tableView.indexPathForSelectedRow!.section
            let indexOfRowTapped = tableView.indexPathForSelectedRow!.row
            let indexItem = tableSectionsIndex?[sectionIndexOfRowTapped]
            vc.drink = indexItem?.value[indexOfRowTapped]
            vc.sender = "DrinksTableViewController"
        }
    }
}
