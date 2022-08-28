//
//  AllControlles.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 16.08.2022.
//

import Foundation
import UIKit

struct AllControlles {

    static func getCatalogViewController() -> CatalogViewController {
        return getViewControllerInstance(viewController: CatalogViewController(), name: "CatalogViewController")
    }
    
    static func getEpisodeViewController() -> EpisodeViewController {
        return getViewControllerInstance(viewController: EpisodeViewController(), name: "EpisodeViewController")
    }
    
    static func getAnimeViewController() -> AnimeViewController {
        return getViewControllerInstance(viewController: AnimeViewController(), name: "AnimeViewController")
    }
    
    static func getTabBarViewController() -> TabBarViewController {
        return getViewControllerInstance(viewController: TabBarViewController(), name: "TabBarViewController")
    }
    
    static func getPlayerViewController() -> PlayerViewController {
        return getViewControllerInstance(viewController: PlayerViewController(), name: "PlayerViewController")
    }
    
    static func getNewEpisodesViewController() -> EpisodesToWatchViewController {
        return getViewControllerInstance(viewController: EpisodesToWatchViewController(), name: "NewEpisodesViewController")
    }
    
    static func getSubscriptionViewController() -> SubscriptionViewController {
        let storyBoard = UIStoryboard(name: "Subscription", bundle: .main)
        return storyBoard.instantiateViewController(withIdentifier: "SubscriptionViewController") as! SubscriptionViewController
    }
    
    static func getSettingsLineViewController() -> SettingsLineViewController {
        let storyBoard = UIStoryboard(name: "SettingsLine", bundle: .main)
        return storyBoard.instantiateViewController(withIdentifier: "SettingsLineViewController") as! SettingsLineViewController
    }
    
    private static func getViewControllerInstance<T>(viewController: T, name: String) -> T {
        let storyBoard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyBoard.instantiateViewController(withIdentifier: name) as! T
        return viewController
    }
    
}
    
