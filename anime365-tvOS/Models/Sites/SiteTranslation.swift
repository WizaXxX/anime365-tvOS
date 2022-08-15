//
//  SiteTranslation.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import Foundation

struct SiteTranslation: Decodable {
    var id: Int
    var type: String
    var typeKind: String
    var typeLang: String
    var authorsSummary: String
    var width: Int
    var height: Int
}
