//
//  ViewController.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 12.08.2022.
//

import UIKit
import SwiftKeychainWrapper

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
        
    @IBAction func pressLogin() {
        
        guard let email = emailTextField.text, emailTextField.text != "" else {
            emailTextField.showError()
            return
        }
        
        guard let pass = passwordTextField.text, passwordTextField.text != "" else {
            passwordTextField.showError()
            return
        }
        
        changeEnable(to: false)
        Networker.shared.login(email: email, password: pass) { [weak self] result in
            self?.changeEnable(to: true)
            switch result {
            case .failure(let error):
                print(error)
            case .success(let sessionData):
                guard let currentSession = sessionData else { return }
                Session.setSessionData(sessionData: currentSession)
                Session.saveSessionData(sessionData: currentSession)
                
                DispatchQueue.main.async { [weak self] in
                    self?.goToMainView()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !needLogin() {
            goToMainView()
        }
    }
        
    private func needLogin() -> Bool {
        guard let sessionData = Session.getSessionData() else { return true }
        Session.setSessionData(sessionData: sessionData)
        return false
    }
    
    private func changeEnable(to value: Bool) {
        emailTextField.isEnabled = value
        passwordTextField.isEnabled = value
        loginButton.isEnabled = value
    }
    
    private func goToMainView() {
        Networker.shared.setSessionData()
        
        emailTextField.isHidden = true
        passwordTextField.isHidden = true
        loginButton.isHidden = true
        
        let spinner = UIActivityIndicatorView(style: .large)
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        let vc = AllControlles.getTabBarViewController()
        navigationController?.setViewControllers([vc], animated: true)
    }

}
