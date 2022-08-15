//
//  RealmGenre.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import Foundation
import RealmSwift

class RealmGenre: Object {
    @Persisted (primaryKey: true) var id: Int
    @Persisted var tittle: String
    @Persisted var url: String
}
