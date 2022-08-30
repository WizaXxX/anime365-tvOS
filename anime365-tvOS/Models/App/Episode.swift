//
//  Episode.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import Foundation

struct Episode {
    init(from siteEpisode: SiteEpisode) {
        id = siteEpisode.id
        numerOfEpisode = Int(siteEpisode.numerOfEpisode) ?? 0
        tittle = siteEpisode.tittle
        episodeType = siteEpisode.episodeType
    }
    
    var id: Int
    var numerOfEpisode: Int
    var tittle: String
    var episodeType: String
}
