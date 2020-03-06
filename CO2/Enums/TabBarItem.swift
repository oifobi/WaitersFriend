//
//  TabBarItem.swift
//  WaitersFriend
//
//  Created by Simon Italia on 3/3/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit

enum TabBarItemTitle {
    static let topRated = "Popular"
    static let featured = "Random"
    static let search = "Search"
    static let favorites = "Favorites"
}


enum TabBarItemTag {
    static let topRated = 0
    static let featured = 1
    static let search = 2
    static let favorites = 3
}


enum TabBarItemImage {
    static let topRated = UIImage(systemName: SFSymbol.thumbsUp)
    static let featured = UIImage(systemName: SFSymbol.starFill)
    static let search = UIImage(systemName: SFSymbol.search)
    static let favorites = UIImage(systemName: SFSymbol.heartFill)
}


enum TabBarItem {
        static let topRated = (
        title:  TabBarItemTitle.topRated,
        tag:    TabBarItemTag.topRated,
        image:  TabBarItemImage.topRated
    )
    
    static let featured = (
        title:  TabBarItemTitle.featured,
        tag:    TabBarItemTag.featured,
        image:  TabBarItemImage.featured
    )
    
    static let search = (
        title:  TabBarItemTitle.search,
        tag:    TabBarItemTag.search,
        image:  TabBarItemImage.search
    )
    
    static let favorites = (
        title:  TabBarItemTitle.favorites,
        tag:    TabBarItemTag.favorites,
        image:  TabBarItemImage.favorites
    )
}


