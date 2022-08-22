//
//  SubscriptionViewController.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 22.08.2022.
//

import UIKit
import ParallaxView

class SubscriptionViewController: UIViewController {

    @IBOutlet weak var userIdLabelView: UILabel!
    @IBOutlet weak var statusLabelView: UILabel!
    @IBOutlet weak var descLabelView: UILabel!
    
    var spinner = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusLabelView.text = ""
        descLabelView.text = ""
        
        view.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        spinner.startAnimating()
        
        userIdLabelView.text = Session.instance.userId
        
        Task {
            guard let data = await Networker.shared.getSubscriptionData() else { return }
            DispatchQueue.main.async { [weak self] in
                self?.statusLabelView.text = data.0
                self?.descLabelView.text = data.1
                self?.spinner.stopAnimating()
            }
        }
        
    }
}
