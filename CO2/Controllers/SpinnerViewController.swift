//
//  ActivitySpinnerViewController.swift
//  CO2
//
//  Created by Simon Italia on 9/22/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit

class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        view.backgroundColor = UIColor(white: 0, alpha: 0.25)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        //start spinner animation and add to its parent view
        spinner.startAnimating()
        view.addSubview(spinner)
        
        //set spinner constraints within parent view
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    func startSpinner(viewController vc: UIViewController) {
        DispatchQueue.main.async {
            vc.addChild(self)
            self.view.frame = vc.view.bounds
            vc.view.addSubview(self.view)
            self.didMove(toParent: vc)
        }
    }

    
    func stopSpinner() {
        DispatchQueue.main.async {
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
}
