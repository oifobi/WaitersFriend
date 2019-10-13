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
    @IBOutlet weak var cellLabel: UILabel!
    
    func setImage(_ image: UIImage) {
        cellImageView.image = image
    }
    
    func setLabel(text: String) {
        cellLabel.text = text
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
