//
//  DrinkCollectionViewController.swift
//  CO2
//
//  Created by Simon Italia on 9/23/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//  Acknowledgement to Yuichi Fujiki on 23/6/19.


import UIKit

class DrinkIngredientsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setLabel(text: String) {
        cellLabel.text = text
    }
}
