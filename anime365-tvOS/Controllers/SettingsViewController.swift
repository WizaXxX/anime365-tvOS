//
//  SettingsViewController.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 22.08.2022.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var subscriptionView: UIView!
    @IBOutlet weak var comfortTranslationTypeView: FocusableUIView!
    @IBOutlet weak var showNewEpisodeOnlyWithComfortTypeOfTranslation: FocusableUIView!
    
    let comfortSettingVC = AllControlles.getSettingsLineViewController()
    let showOnlyVC = AllControlles.getSettingsLineViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let subVC = AllControlles.getSubscriptionViewController()
        addChild(subVC)
        subVC.view.frame = subscriptionView.bounds
        subscriptionView.addSubview(subVC.view)
        subVC.didMove(toParent: self)
                
        comfortSettingVC.configure(typeOfSetting: .comfortTypeOfTranslation)
        addChild(comfortSettingVC)
        comfortSettingVC.view.frame = comfortTranslationTypeView.bounds
        comfortTranslationTypeView.addSubview(comfortSettingVC.view)
        comfortSettingVC.didMove(toParent: self)
        let tapForComfortTranslationTypeView = UITapGestureRecognizer(target: self, action:  #selector (self.changeComfortSetting (_:)))
        comfortTranslationTypeView.addGestureRecognizer(tapForComfortTranslationTypeView)
        
        showOnlyVC.configure(typeOfSetting: .showNewEpisodesOnlyWithComfortTypeOfTranslation)
        addChild(showOnlyVC)
        showOnlyVC.view.frame = showNewEpisodeOnlyWithComfortTypeOfTranslation.bounds
        showNewEpisodeOnlyWithComfortTypeOfTranslation.addSubview(showOnlyVC.view)
        showOnlyVC.didMove(toParent: self)
        let tapForShowNewEpisodeOnlyWithComfortTypeOfTranslation = UITapGestureRecognizer(target: self, action:  #selector (self.changeShowOnlySetting (_:)))
        showNewEpisodeOnlyWithComfortTypeOfTranslation.addGestureRecognizer(tapForShowNewEpisodeOnlyWithComfortTypeOfTranslation)
        
    }
    
    @objc private func changeComfortSetting(_ sender: UITapGestureRecognizer){
        comfortSettingVC.changeSetting()
    }
    
    @objc private func changeShowOnlySetting(_ sender: UITapGestureRecognizer){
        showOnlyVC.changeSetting()
    }
        
    private func getVCToChangeFocus(view: FocusableUIView) -> SettingsLineViewController? {
        var vc: SettingsLineViewController? = nil
        
        if view == comfortTranslationTypeView {
            vc = comfortSettingVC
        } else if view == showNewEpisodeOnlyWithComfortTypeOfTranslation {
            vc = showOnlyVC
        }
        
        return vc
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        if let view = context.nextFocusedView as? FocusableUIView {
            if let vc = getVCToChangeFocus(view: view) {
                coordinator.addCoordinatedAnimations {
                    view.backgroundColor = .white
                    view.transform = .identity
                    vc.settingNameLabelView.textColor = .darkGray
                    vc.settingValueLabelView.textColor = .gray
                }
            }
        }
        
        if let view = context.previouslyFocusedView as? FocusableUIView {
            if let vc = getVCToChangeFocus(view: view) {
                coordinator.addCoordinatedAnimations {
                    view.backgroundColor = .clear
                    view.transform = CGAffineTransform(scaleX: view.scale, y: view.scale)
                    vc.settingNameLabelView.textColor = .secondaryLabel
                    vc.settingValueLabelView.textColor = .quaternaryLabel
                }
            }
        }
    }
}
