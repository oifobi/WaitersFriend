//
//  DrinkCollectionViewCell.swift
//  CO2
//
//  Created by Simon Italia on 9/27/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

class DrinkCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "DrinkCollectionViewCell"
    static let nib = "DrinkCollectionViewCell"
    
    @IBOutlet weak var cellActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var cellSubtitleLabel: UILabel!
    
    
    func setTitleLabel(text: String) { cellTitleLabel.text = text }
    func setSubtitleLabel(text: String) { cellSubtitleLabel.text = text }
    

    func setImage(with urlString: String) {
        cellImageView.image = nil
        startActivityIndicator()
        
        NetworkManager.shared.fetchDrinkImage(with: urlString) { [weak self] (fetchedImage, error) in
            guard let self = self else { return }
            self.stopActivityIndicator()
            
            if let fetchedImage = fetchedImage {
                DispatchQueue.main.async { self.cellImageView.image = fetchedImage }
                
                //catch any errors fetching image
            } else if let error = error {
                print("Error fetching image with error \(error.localizedDescription)\n")
                return
            }
        }
    }
    
    
    func startActivityIndicator() {
        DispatchQueue.main.async {
            self.cellActivityIndicatorView.alpha = 1
            self.cellActivityIndicatorView.startAnimating()
        }
    }
    
    
    func stopActivityIndicator() {
        DispatchQueue.main.async {
            self.cellActivityIndicatorView.alpha = 0
            self.cellActivityIndicatorView.stopAnimating()
        }
    }

}
