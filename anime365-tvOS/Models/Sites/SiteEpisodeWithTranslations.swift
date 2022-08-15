//
//  SiteEpisodeWithTranslations.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import Foundation

struct SiteEpisodeWithTranslations: Decodable {
    var id: Int
    var episodeFull: String
    var episodeInt: String
    var episodeType: String
    var isActive: Int
    var isFirstUploaded: Int
    var translations: [SiteTranslation]
}
