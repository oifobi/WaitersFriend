//
//  UIView+Extensions.swift
//  CompositionalLayoutSample
//
//  Created by Yuichi Fujiki on 23/6/19.
//  Copyright © 2019 Yuichi Fujiki. All rights reserved.
//

//Global UIView attributes
import UIKit

extension UIView {

    @IBInspectable
    var viewCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable
    var viewBorderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable
    var viewBorderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
}
