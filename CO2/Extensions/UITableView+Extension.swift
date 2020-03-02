//
//  UITableView+Extension.swift
//  WaitersFriend
//
//  Created by Simon Italia on 3/2/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit

extension UITableView {

func hideEmptyCells() {
    tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
}
