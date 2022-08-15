//
//  EpisodeWithTranslations.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import Foundation

struct EpisodeWithTranslations {
    var id: Int
    var episodeFull: String
    var episodeInt: Int
    var episodeType: String
    var isActive: Bool
    var translations: [Translation]
}
