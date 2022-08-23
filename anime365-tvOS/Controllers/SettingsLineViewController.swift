//
//  SettingsLineViewController.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 23.08.2022.
//

import UIKit

class SettingsLineViewController: UIViewController {

    @IBOutlet weak var settingNameLabelView: UILabel!
    @IBOutlet weak var settingValueLabelView: UILabel!
    
    var nameSetting: String?
    var valueSetting: String?
    var typeOfSetting: SettingsType?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        settingNameLabelView.text = nameSetting
        settingValueLabelView.text = valueSetting
    }
    
    func configure(typeOfSetting: SettingsType) {
        self.typeOfSetting = typeOfSetting
        
        nameSetting = typeOfSetting.rawValue
        switch typeOfSetting {
        case .comfortTypeOfTranslation:
            guard let type = Session.instance.settings.comfortTypeOfTranslation else { return }
            valueSetting = type.rawValue
        case .showNewEpisodesOnlyWithComfortTypeOfTranslation:
            let value = Session.instance.settings.showNewEpisodesOnlyWithComfortTypeOfTranslation ? "Да" : "Нет"
            valueSetting = value
        }
    }
    
    func changeSetting() {
        
        switch typeOfSetting! {
        case .comfortTypeOfTranslation:
            changeComfortTypeSetting()
        case .showNewEpisodesOnlyWithComfortTypeOfTranslation:
            changeShowOnlySetting()
        }
    }
    
    fileprivate func changeComfortTypeSetting() {
        let alert = UIAlertController(
            title: "Типы переводов",
            message: nil,
            preferredStyle: .actionSheet)
        TypeOfTranslation.allCases.forEach { type in
            alert.addAction(UIAlertAction(title: type.rawValue, style: .default, handler: { [weak self] action in
                guard let actionTitle = action.title else { return }
                guard let actionValue = TypeOfTranslation(rawValue: actionTitle) else { return }

                Session.instance.settings.saveComfortTypeOfTranslation(type: actionValue)
                DispatchQueue.main.async {
                    self?.valueSetting = actionTitle
                    self?.settingValueLabelView.text = actionTitle
                }
            }))
        }

        alert.addAction(UIAlertAction(
            title: "Отмена",
            style: .cancel,
            handler: nil))

        present(alert, animated: true)
    }
    
    private func changeShowOnlySetting() {
        let alert = UIAlertController(
            title: "Показывть новые серии только с предпочитаемым переводом?",
            message: nil,
            preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(
            title: "Да",
            style: .default,
            handler: selectedShowNewEpisodesOnlyWithComfortTypeOfTranslation))
        alert.addAction(UIAlertAction(
            title: "Нет",
            style: .default,
            handler: selectedShowNewEpisodesOnlyWithComfortTypeOfTranslation))
        alert.addAction(UIAlertAction(
            title: "Отмена",
            style: .cancel,
            handler: nil))

        present(alert, animated: true)
    }
    
    private func selectedShowNewEpisodesOnlyWithComfortTypeOfTranslation(_ action: UIAlertAction) {
        let value = action.title == "Да" ? true : false
        Session.instance.settings.saveShowNewEpisodesOnlyWithComfortTypeOfTranslation(value: value)
        valueSetting = action.title
        settingValueLabelView.text = action.title
    }
    
}
