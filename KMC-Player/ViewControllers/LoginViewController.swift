//
//  LoginViewController.swift
//  KMC-Player
//
//  Created by Nilit Danan on 3/15/18.
//  Copyright © 2018 Nilit Danan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var partnerIdTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.showActivityView(false)
        partnerIdTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private Functions
    
    func showActivityView(_ show: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.activityView.alpha = show ? 1.0 : 0.0
        }
    }
    
    func loginAlert(message: String) {
        let alert = UIAlertController(title: "Login", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.show(alert, sender: nil)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch textField {
        case partnerIdTextField:
            if string.count != 0 {
                if Int(string) == nil {
                    return false
                }
            }
        default:
            return true
        }
        
        return true
    }
    
    // MARK: - IBAction
    
    @IBAction func loginTouched(_ sender: Any) {
        
        guard let partnerId = self.partnerIdTextField.text else {
            self.loginAlert(message: "Partner Id is missing")
            return
        }
        
        if partnerId.isEmpty {
            self.loginAlert(message: "Partner Id is missing")
            return
        }
        
        guard let userId = self.userIdTextField.text else {
            self.loginAlert(message: "User name is missing")
            return
        }
        
        if userId.isEmpty {
            self.loginAlert(message: "User name is missing")
            return
        }
        
        guard let password = self.passwordTextField.text else {
            self.loginAlert(message: "Password is missing")
            return
        }
        
        if password.isEmpty {
            self.loginAlert(message: "Password is missing")
            return
        }
        
        UserManager.shared.login(partnerId: Int(partnerId)!, userId: userId, password: password) { (error) in
            self.showActivityView(false)
            
            if error != nil {
                let alert = UIAlertController(title: "Login", message: error?.message, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.cancel, handler: nil))
                self.show(alert, sender: nil)
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        self.showActivityView(true)
    }
}
