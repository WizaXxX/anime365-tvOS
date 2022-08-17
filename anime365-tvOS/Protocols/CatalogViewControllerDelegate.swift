//
//  CatalogViewControllerDelegate.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 17.08.2022.
//

import Foundation
import UIKit

protocol CatalogViewControllerDelegate: AnyObject {
    
    func showChildView(viewController: UIViewController)
    
}
