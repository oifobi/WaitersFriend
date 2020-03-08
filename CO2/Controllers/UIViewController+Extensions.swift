//
//  UIViewController+Extension.swift
//  WaitersFriend
//
//  Created by Simon Italia on 2/26/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit

extension UIViewController {
    
    //alert controller
    func presentAlertVC(title: String, message: String, buttonText: String) {
        DispatchQueue.main.async { [unowned self] in
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: buttonText, style: .default))
            ac.modalPresentationStyle = .overFullScreen
                //take over full screen esp. in iOS 13's new card style ui
            ac.modalTransitionStyle = .crossDissolve
            self.present(ac, animated: true)
        }
    }
    
    //error alert controller
    func presentErrorAlertVC(title: String, message: String, buttonText: String, action: UIAlertAction, sender: String = #function) {
        print("Error Alert called by: \(sender)\n")
        
        DispatchQueue.main.async {
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(action)
            ac.addAction(UIAlertAction(title: buttonText, style: .default))
            self.present(ac, animated: true)
        }
    }
    
    
    func showEmptyStateView(with text: String, in parentView: UIView) {
        let emptyStateView = WFEmptyStateView(labelText: text)
        emptyStateView.frame = parentView.bounds
        parentView.addSubview(emptyStateView)
    }
    
    
    func presentDestinationVC(with identifier: String, for item: Drink) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: identifier) as? DrinkDetailsViewController {
            vc.drink = item
            
            let nc = UINavigationController(rootViewController: vc)
            present(nc, animated: true)
        }
    }
    

    @objc func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
}
