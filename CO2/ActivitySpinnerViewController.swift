//
//  ActivitySpinnerViewController.swift
//  CO2
//
//  Created by Simon Italia on 9/22/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

class ActivitySpinnerViewController: UIViewController {
    
    static var sharedSpinner = ActivitySpinnerViewController()
    var spinner = UIActivityIndicatorView(style: .whiteLarge)

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        
        //set spinner constraints within parent view
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
 
    }
}
