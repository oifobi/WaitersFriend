//
//  EndPoints.swift
//  CO2
//
//  Created by Simon Italia on 9/24/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import Foundation

enum EndPoint: String {
    
    //Absolute endpoints
    case random = "random.php"
    case popular = "popular.php"
    case recent = "recent.php"
    
    //Endpoints for use with Queries
    case search = "search.php"
    case lookup = "lookup.php"
    case filter = "filter.php"
    case list = "list.php"
    
}
