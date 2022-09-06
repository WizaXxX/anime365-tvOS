//
//  AppDelegate.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 12.08.2022.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rootNavControl = AllControlles.getTabBarViewController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        guard let navController = window?.rootViewController as? UINavigationController else { return false }
        let urlComponents = URLComponents(string: url.absoluteString)
        
        guard let episodeId = urlComponents?.queryItems?.first(where: {$0.name == "episodeId"})?.value else { return false }
        guard let animeId = urlComponents?.queryItems?.first(where: {$0.name == "animeId"})?.value else { return false }
        
        Task {
            guard let data = await Networker.shared.getNewEpisodeData(episodeId: episodeId, animeId: animeId) else { return }
            let vc = AllControlles.getEpisodeViewController()
            vc.configure(from: data.1, anime: data.0)
            navController.pushViewController(vc, animated: true)
        }
        
        return true
    }

}

