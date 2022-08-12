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
    
    var needLoginToSite: Bool = false
    
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
        needLoginToSite = needLogin()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !needLoginToSite {
            goToMainView()
        }
    }
    
    private func needLogin() -> Bool {
        
        guard let sessionId = KeychainWrapper.standard.string(forKey: sessionIdKeyName) else { return true }
        Session.instance.sessionId = sessionId
        
        guard let userId = KeychainWrapper.standard.string(forKey: userIdKeyName) else { return true }
        Session.instance.sessionId = userId
        
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
        performSegue(withIdentifier: "fromLoginToMain", sender: nil)
    }

}
