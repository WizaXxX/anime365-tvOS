//
//  RealmEpisode.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import Foundation
import RealmSwift

class RealmEpisode: Object {
    @Persisted (primaryKey: true) var id: Int
    @Persisted var numerOfEpisode: Int
    @Persisted var tittle: String
    @Persisted var episodeType: String
}
