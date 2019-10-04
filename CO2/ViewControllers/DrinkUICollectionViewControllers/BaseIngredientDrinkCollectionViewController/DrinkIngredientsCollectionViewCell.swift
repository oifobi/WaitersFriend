//
//  DrinkCollectionViewController.swift
//  CO2
//
//  Created by Simon Italia on 9/23/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//  Acknowledgement to Yuichi Fujiki on 23/6/19.


import UIKit

class DrinkIngredientsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setButton(title text: String) {
        cellButton.setTitle(text, for: .normal)
    }
    
}
