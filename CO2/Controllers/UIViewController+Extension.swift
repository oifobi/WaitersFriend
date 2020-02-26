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
    func presentAlertViewController(title: String, message: String, buttonText: String) {
        DispatchQueue.main.async { [unowned self] in
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: buttonText, style: .default))
            ac.modalPresentationStyle = .overFullScreen
                //take over full screen esp. in iOS 13's new card style ui
            ac.modalTransitionStyle = .crossDissolve
            self.present(ac, animated: true)
        }
    }
}
