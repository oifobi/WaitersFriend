//
//  DrinkCollectionViewCell.swift
//  CO2
//
//  Created by Simon Italia on 9/27/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

class DrinkCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var cellSubtitleLabel: UILabel!
    
    
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
