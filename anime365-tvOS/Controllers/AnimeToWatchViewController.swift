//
//  animeToWatchViewController.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 12.08.2022.
//

import UIKit
import Alamofire

class AnimeToWatchViewController: UIViewController {

    @IBOutlet weak var textField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AF.request("https://smotret-anime.com").response { response in
            
            DispatchQueue.main.async { [weak self] in
                self?.textField.text = String(data: (response.data)!, encoding: .utf8)
                print(self?.textField.text)
            }
        }
        
    }
}
