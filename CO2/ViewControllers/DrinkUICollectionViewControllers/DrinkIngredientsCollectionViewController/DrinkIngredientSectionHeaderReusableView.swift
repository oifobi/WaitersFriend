//
//  SectionHeaderCollectionReusableView.swift
//  CO2
//
//  Created by Simon Italia on 9/26/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

class DrinkIngredientSectionHeaderReusableView: UICollectionReusableView {
    
    @IBOutlet weak var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setHeaderLabel(text: String) {
        headerLabel.text = text
    }
}
