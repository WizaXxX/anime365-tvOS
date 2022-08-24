//
//  SiteAnime.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import Foundation

struct SiteAnime: Decodable {
    var id: Int
    var title: String
    var season: String
    var year: Int
    var type: String
    var posterUrl: String
    var posterUrlSmall: String
    var titles: [String: String]
    var episodes: [SiteEpisode]?
    var genres: [SiteGenre]?
    var descriptions: [SiteAnimeDescription]?
    var myAnimeListScore: String
    var numberOfEpisodes: Int
}
