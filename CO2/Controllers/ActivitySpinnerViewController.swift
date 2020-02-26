//
//  ActivitySpinnerViewController.swift
//  CO2
//
//  Created by Simon Italia on 9/22/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

class ActivitySpinnerViewController: UIViewController {
    static var shared = ActivitySpinnerViewController()
    
    var spinner = UIActivityIndicatorView(style: .large)
    
    override func loadView() {
        
        //create parent / superview to host spinner indicator
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        //start spinner animation and add to its parent view
        spinner.startAnimating()
        view.addSubview(spinner)
        
        //set spinner constraints within parent view
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
