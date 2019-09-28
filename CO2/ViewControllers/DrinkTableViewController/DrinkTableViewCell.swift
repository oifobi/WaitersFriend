//
//  File.swift
//  CO2
//
//  Created by Simon Italia on 9/27/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import Foundation
import UIKit

class DrinkTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var cellSubtitleLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    
    func setTitleLabel(text: String) {
        cellTitleLabel.text = text
    }
        
    func setSubtitleLabel(text: String) {
        cellSubtitleLabel.text = text
    }
    
    func setImage(_ image: UIImage) {
        cellImageView.image = image
    }
    
}
