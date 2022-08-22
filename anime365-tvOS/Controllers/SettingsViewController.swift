//
//  SettingsViewController.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 22.08.2022.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var subscriptionView: UIView!
    @IBOutlet weak var comfortTranslationTypeButton: UIButton!
    @IBOutlet weak var showNewEpisodesOnlyWithComfortTypeOfTranslationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let subVC = AllControlles.getSubscriptionViewController()
        addChild(subVC)
        subVC.view.frame = subscriptionView.bounds
        subscriptionView.addSubview(subVC.view)
        subVC.didMove(toParent: self)
            
        if let type = Session.instance.settings.comfortTypeOfTranslation {
            setTitleForComfortTypeOfTranslation(actionTitle: type.rawValue)
        }
        
        setTitleForshowNewEpisodesOnlyWithComfortTypeOfTranslationButton()
        
    }
    
    @IBAction func selectComforTranslationType() {
        let alert = UIAlertController(
            title: "Типы переводов",
            message: nil,
            preferredStyle: .actionSheet)
        
        TypeOfTranslation.allCases.forEach { type in
            alert.addAction(UIAlertAction(title: type.rawValue, style: .default, handler: { [weak self] action in
                guard let actionTitle = action.title else { return }
                guard let actionValue = TypeOfTranslation(rawValue: actionTitle) else { return }
                
                Session.instance.settings.saveComfortTypeOfTranslation(type: actionValue)
                self?.setTitleForComfortTypeOfTranslation(actionTitle: actionTitle)
            }))
        }
        present(alert, animated: true)
    }
    
    @IBAction func selectShowNewEpisodesOnlyWithComfortTypeOfTranslation() {
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
        
        present(alert, animated: true)
    }
    
    private func selectedShowNewEpisodesOnlyWithComfortTypeOfTranslation(_ action: UIAlertAction) {
        let value = action.title == "Да" ? true : false
        Session.instance.settings.saveShowNewEpisodesOnlyWithComfortTypeOfTranslation(value: value)
        setTitleForshowNewEpisodesOnlyWithComfortTypeOfTranslationButton()
    }
    
    private func setTitleForComfortTypeOfTranslation(actionTitle: String) {
        comfortTranslationTypeButton.setTitle("Предпочитаемый вид перевода:   \(actionTitle)", for: .normal)
    }
    
    private func setTitleForshowNewEpisodesOnlyWithComfortTypeOfTranslationButton() {
        let value = Session.instance.settings.showNewEpisodesOnlyWithComfortTypeOfTranslation ? "Да" : "Нет"
        showNewEpisodesOnlyWithComfortTypeOfTranslationButton.setTitle(
            "Показывать новые серии только с предпочитаемым переводом:  \(value)", for: .normal)
    }
}
