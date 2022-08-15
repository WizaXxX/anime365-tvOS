//
//  Anime.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import Foundation

struct Anime {
    var id: Int
    var title: String
    var posterUrlSmall: ImageFromInternet
    var posterUrl: ImageFromInternet
    var episodes: [Episode]
}
