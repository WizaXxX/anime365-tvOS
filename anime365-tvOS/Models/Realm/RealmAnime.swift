//
//  RealmAnime.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import Foundation
import RealmSwift

class RealmAnime: Object {
    @Persisted (primaryKey: true) var id: Int
    @Persisted var title: String
    @Persisted var season: String
    @Persisted var year: Int
    @Persisted var type: String
    @Persisted var posterUrl: String
    @Persisted var posterUrlSmall: String
    @Persisted var episodes: List<RealmEpisode>
    @Persisted var genres: List<RealmGenre>
}
