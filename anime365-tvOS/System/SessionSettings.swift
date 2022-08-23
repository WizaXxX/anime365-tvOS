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

struct SessionSettings {
    
    init() {
        wrapper = UserDefaults(suiteName: "group.anime365.tvos.app")!
        let type = wrapper.string(forKey: nameOfcomfortTypeOfTranslation)
        if let typeString = type, let typeValue = TypeOfTranslation(rawValue: typeString) {
            comfortTypeOfTranslation = typeValue
        }
        
        showNewEpisodesOnlyWithComfortTypeOfTranslation = wrapper.bool(
            forKey: nameOfshowNewEpisodesOnlyWithComfortTypeOfTranslation)
        
    }
    
    var comfortTypeOfTranslation: TypeOfTranslation?
    var showNewEpisodesOnlyWithComfortTypeOfTranslation: Bool
    let wrapper: UserDefaults
    
    let nameOfcomfortTypeOfTranslation = "TypeOfTranslation"
    let nameOfshowNewEpisodesOnlyWithComfortTypeOfTranslation = "showNewEpisodesOnlyWithComfortTypeOfTranslation"
    
    mutating func saveComfortTypeOfTranslation(type: TypeOfTranslation) {
        self.comfortTypeOfTranslation = type
        wrapper.set(type.rawValue, forKey: nameOfcomfortTypeOfTranslation)
    }
    
    mutating func saveShowNewEpisodesOnlyWithComfortTypeOfTranslation(value: Bool) {
        self.showNewEpisodesOnlyWithComfortTypeOfTranslation = value
        wrapper.set(value, forKey: nameOfshowNewEpisodesOnlyWithComfortTypeOfTranslation)
    }
}
