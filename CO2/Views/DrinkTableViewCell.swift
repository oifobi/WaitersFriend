//
//  File.swift
//  CO2
//
//  Created by Simon Italia on 9/27/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

class DrinkTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var cellSubtitleLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellActivityIndicatorView: UIActivityIndicatorView!

    
    //Set cell padding
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
    
    
    //Set cell properties
    func setTitleLabel(text: String) {
        cellTitleLabel.text = text
    }
       
    
    func setSubtitleLabel(text: String) {
        cellSubtitleLabel.text = text
    }
    
    
    func setImage(with urlString: String) {
        NetworkManager.shared.fetchDrinkImage(with: urlString) { (fetchedImage, error) in
            if let fetchedImage = fetchedImage {
                
                DispatchQueue.main.async {
                    self.cellImageView.image = fetchedImage
                }
                
                //catch any errors fetching image
            } else if let error = error {
                print("Error fetching image with error \(error.localizedDescription)\n")
                return
            }
        }
    }
       

    func startActivityIndicator() {
        cellActivityIndicatorView.isHidden = false
        cellActivityIndicatorView.startAnimating()
    }
    
    
    func stopActivityIndicator() {
        cellActivityIndicatorView.isHidden = true
        cellActivityIndicatorView.stopAnimating()
    }
}
