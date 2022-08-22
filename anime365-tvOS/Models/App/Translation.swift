//
//  Translation.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import Foundation

enum TypeOfTranslation: String, CaseIterable {
    case subEn = "Английские субтитры"
    case voiceEn = "Английская озвучка"
    case voiceOther = "Разная озвучка"
    case subRu = "Русские субтитры"
    case voiceRu = "Русская озвучка"
    case raw = "Японская озвучка"
    case some = "Что то не ясное"
    
    init(type: String) {
        switch type {
        case "subEn": self = .subEn
        case "voiceEn": self = .voiceEn
        case "voiceOther": self = .voiceOther
        case "subRu": self = .subRu
        case "voiceRu": self = .voiceRu
        case "raw": self = .raw
        default:
            self = .some
        }
    }
    
    func getIndex() -> Int {
        switch self {
        case .subRu: return 0
        case .voiceRu: return 1
        case .subEn: return 2
        case .voiceEn: return 3
        case .voiceOther: return 4
        case .raw: return 5
        default: return 6
        }
    }
}

struct Translation {
    var id: Int
    var type: TypeOfTranslation
    var typeKind: String
    var typeLang: String
    var author: String
    var width: Int
    var height: Int
}
