//
//  TabBarViewController.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 16.08.2022.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.selectedIndex = 1        
    }
}

extension TabBarViewController: UITabBarControllerDelegate {
      
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if var vc = toVC as? LoadedUIViewController {
            vc.needLoadData = true
        }
        
        return nil
    }
}
