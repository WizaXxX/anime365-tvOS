//
//  AnimeDescription.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 19.08.2022.
//

import Foundation

struct AnimeDescription {
    init(from siteDesc: SiteAnimeDescription) {
        source = siteDesc.source
        value = siteDesc.value
    }
    
    var source: String
    var value: String
}
