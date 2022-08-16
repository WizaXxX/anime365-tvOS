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
    
    let sessionIdKeyName = "sessionId"
    let userIdKeyName = "userId"
    
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
                guard let sessionId = sessionData?.sessionId else { return }
                guard let userId = sessionData?.userId else { return }
                
                self?.setSessionData(sessionId: sessionId, userId: userId)
                
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
        
        guard let sessionId = KeychainWrapper.standard.string(forKey: sessionIdKeyName) else { return true }
        if sessionId.isEmpty { return true }
        Session.instance.sessionId = sessionId
        
        guard let userId = KeychainWrapper.standard.string(forKey: userIdKeyName) else { return true }
        Session.instance.userId = userId
        
        return false
    }
    
    private func setSessionData(sessionId: String, userId: String) {
        
        Session.instance.sessionId = sessionId
        Session.instance.userId = userId
        
        KeychainWrapper.standard.set(sessionId, forKey: sessionIdKeyName)
        KeychainWrapper.standard.set(userId, forKey: userIdKeyName)
    }
    
    private func changeEnable(to value: Bool) {
        emailTextField.isEnabled = value
        passwordTextField.isEnabled = value
        loginButton.isEnabled = value
    }
    
    private func goToMainView() {
        Networker.shared.setSessionId()
        
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
        
        let stb = UIStoryboard(name: "Main", bundle: .main)
        let vc = stb.instantiateViewController(withIdentifier: "tab")
        if let control = navigationController {
            control.setViewControllers([vc], animated: true)
        }
    }

}
