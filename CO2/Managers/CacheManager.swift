//
//  CacheManager.swift
//  WaitersFriend
//
//  Created by Simon Italia on 2/26/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit

struct CacheManager {
    static let shared = CacheManager()
    let imageCache = NSCache<NSString, UIImage>()
}
