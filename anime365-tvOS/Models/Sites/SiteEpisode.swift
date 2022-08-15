//
//  SiteEpisode.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import Foundation

struct SiteEpisode: Decodable {
    var id: Int
    var numerOfEpisode: String
    var tittle: String
    var episodeType: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case numerOfEpisode = "episodeInt"
        case tittle = "episodeFull"
        case episodeType
    }
    
}
