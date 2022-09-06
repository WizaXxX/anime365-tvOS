//
//  CloudUserSettings.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 06.09.2022.
//

import Foundation

struct CloudUserSettings: Codable {
    var comfortTypeOfTranslation: String
    var showNewEpisodesOnlyWithComfortTypeOfTranslation: Bool
}

extension CloudUserSettings {
    init() {
        let type = Session.instance.settings.comfortTypeOfTranslation
        if let type = type?.rawValue {
            self.comfortTypeOfTranslation = type
        } else {
            self.comfortTypeOfTranslation = ""
        }
        self.showNewEpisodesOnlyWithComfortTypeOfTranslation = Session.instance.settings.showNewEpisodesOnlyWithComfortTypeOfTranslation
    }
}
