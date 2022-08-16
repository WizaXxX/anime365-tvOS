//
//  AllControlles.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 16.08.2022.
//

import Foundation
import UIKit

class AllControlles {
    private init(){}
    
    static let shared = AllControlles()
    
    func getCatalogController() -> CatalogViewController {
        let stb = UIStoryboard(name: "Main", bundle: .main)
        let vc = stb.instantiateViewController(withIdentifier: "CatalogViewController") as! CatalogViewController
        
        return vc
    }
    
    func getLoginController() -> LoginViewController {
        let stb = UIStoryboard(name: "Main", bundle: .main)
        let vc = stb.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        
        return vc
    }
    
}
    
