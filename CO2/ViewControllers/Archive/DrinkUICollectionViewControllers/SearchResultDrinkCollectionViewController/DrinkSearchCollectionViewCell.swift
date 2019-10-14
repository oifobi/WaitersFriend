//
//  SearchResultDrinkCollectionViewCell.swift
//  CO2
//
//  Created by Simon Italia on 10/2/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

class DrinkSearchCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    
    func setImage(_ image: UIImage) {
        cellImageView.image = image
    }
    
    func setLabel(text: String) {
        cellLabel.text = text
    }
    
}
