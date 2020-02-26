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
    
    func setImage(_ image: UIImage) {
        cellImageView.image = image
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
