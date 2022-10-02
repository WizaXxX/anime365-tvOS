//
//  SessionSettings.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 22.08.2022.
//

import Foundation

enum SettingsType: String {
    case comfortTypeOfTranslation = "Предпочитаемый вид перевода:"
    case showNewEpisodesOnlyWithComfortTypeOfTranslation = "Показывать новые серии только с предпочитаемым переводом:"
}

class SessionSettings {
    
    init() {
        showNewEpisodesOnlyWithComfortTypeOfTranslation = false
        episodeHistory = [CloudUserEpisodeHistory]()
    }
    
    init(from data: CloudUserData) {
        if let typeValue = TypeOfTranslation(rawValue: data.settings.comfortTypeOfTranslation) {
            self.comfortTypeOfTranslation = typeValue
        }
        self.showNewEpisodesOnlyWithComfortTypeOfTranslation = data.settings.showNewEpisodesOnlyWithComfortTypeOfTranslation
        if let episodeHistory = data.episodeHistory {
            self.episodeHistory = episodeHistory
        } else {
            self.episodeHistory = [CloudUserEpisodeHistory]()
        }
    }
    
    var comfortTypeOfTranslation: TypeOfTranslation?
    var showNewEpisodesOnlyWithComfortTypeOfTranslation: Bool
    var episodeHistory: [CloudUserEpisodeHistory]
    
    let nameOfcomfortTypeOfTranslation = "TypeOfTranslation"
    let nameOfshowNewEpisodesOnlyWithComfortTypeOfTranslation = "showNewEpisodesOnlyWithComfortTypeOfTranslation"
    
    func saveComfortTypeOfTranslation(type: TypeOfTranslation) {
        self.comfortTypeOfTranslation = type
        CloudHelper.shared.saveSettings()
    }
    
    func saveShowNewEpisodesOnlyWithComfortTypeOfTranslation(value: Bool) {
        self.showNewEpisodesOnlyWithComfortTypeOfTranslation = value
        CloudHelper.shared.saveSettings()
    }
}
