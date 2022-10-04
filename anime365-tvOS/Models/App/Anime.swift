//
//  Anime.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import Foundation

enum AnimeStatus: Int {
    case scheduled = 0
    case look = 1
    case viewed = 2
    case postponed = 3
    case thrown = 4
}

struct Anime {
    
    init(from siteAnime: SiteAnime) {
        id = siteAnime.id
        title = siteAnime.title
        posterUrlSmall = ImageFromInternet(url: siteAnime.posterUrlSmall)
        posterUrl = ImageFromInternet(url: siteAnime.posterUrl)
        titles = siteAnime.titles
        episodes = siteAnime.episodes?.map({ Episode(from: $0) })
        genres = siteAnime.genres?.map({ Genre(from: $0) })
        desc = siteAnime.descriptions?.map({ AnimeDescription(from: $0) })
        score = siteAnime.myAnimeListScore
        numberOfEpisodes = siteAnime.numberOfEpisodes
    }
    
    var id: Int
    var title: String
    var posterUrlSmall: ImageFromInternet
    var posterUrl: ImageFromInternet
    var titles: [String: String]
    var episodes: [Episode]?
    var genres: [Genre]?
    var desc: [AnimeDescription]?
    var score: String
    var numberOfEpisodes: Int
    
    func getStatus() async -> AnimeStatus? {
        return await Networker.shared.getAnimeStatusAsync(animeId: String(id))
    }
}
