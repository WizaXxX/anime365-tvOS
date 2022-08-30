//
//  Genre.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 19.08.2022.
//

import Foundation

struct Genre {
    init(from siteGenre: SiteGenre) {
        id = siteGenre.id
        title = siteGenre.title
        url = siteGenre.url
    }
    
    var id: Int
    var title: String
    var url: String
}
