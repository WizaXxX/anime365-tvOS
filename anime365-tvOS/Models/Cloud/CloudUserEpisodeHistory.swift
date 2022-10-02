//
//  CloudUserUnwatchedEpisode.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 30.09.2022.
//

import Foundation

struct CloudUserEpisodeHistory: Codable {
    var date: Date
    var id: Int
    var time: Int64
    var title: String
    var translationId: Int
}
