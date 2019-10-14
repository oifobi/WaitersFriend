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
    
    func setImage(_ image: UIImage) {
        cellImageView.image = image
    }
    
    func setTitleLabel(text: String) {
        cellTitleLabel.text = text
    }
    
    func setSubtitleLabel(text: String) {
        cellSubtitleLabel.text = text
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
