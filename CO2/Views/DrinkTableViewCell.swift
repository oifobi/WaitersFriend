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
        cellImageView.image = nil
        startActivityIndicator()
        
        NetworkManager.shared.fetchDrinkImage(with: urlString) { [weak self ](fetchedImage, error) in
            guard let self = self else { return }
            self.stopActivityIndicator()
            
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
