//
//  UICollectionViewFlowLayout+Extensions.swift
//  WaitersFriend
//
//  Created by Simon Italia on 3/6/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit

extension UICollectionViewFlowLayout {
    
    //set edgeInsets
    func setEdgeInsets(to edgeInset: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: edgeInset, left: edgeInset, bottom: edgeInset, right: edgeInset)
    }
}
