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
}
