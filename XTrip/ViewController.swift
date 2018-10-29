//
//  ViewController.swift
//  travelDiary
//
//  Created by Hoang Cap on 7/9/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import GooglePlaces
import FacebookLogin

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    
    @IBOutlet weak var testLabel: UILabel!
    
    deinit {
        log.info("dealloc");
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func tapped(_ sender: Any) {
        
        let email = self.emailTextField.text!;
        if email.isValidEmail {
            self.register();
        } else {
            self.testLabel.text = "Email invalid"
        }
        
        self.view.endEditing(true);
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func loginTapped(_ sender: Any) {
        let email = self.emailTextField.text!.appending("@email.com");
        if email.isValidEmail {
//            self.login();
        } else {
            self.testLabel.text = "Email invalid at login"
        }
        self.view.endEditing(true);
    }
    
    @IBAction func facebookTapped(_ sender: UIButton) {
        let manager = LoginManager.init(loginBehavior: .systemAccount, defaultAudience: .everyone);
        
        manager.loginBehavior = .native;
        
        manager.logIn(readPermissions: [.publicProfile], viewController: self) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success( _,  _, let accessToken):
                
                let expireTimeInterval = accessToken.expirationDate.timeIntervalSince1970;
                let token = accessToken.authenticationToken;
                
                API_MANAGER.requestLoginWithFacebook(accessToken: token, expireIn: expireTimeInterval, success: { (user) in

                    if let _ = user.email {

                        let vc = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "TDOnboardingViewController");

                        AppDelegate.current.setRootViewController(vc, true);
                    } else {

                        let vc = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "TDEmailInputViewController");
                        self.present(vc, animated: true, completion: nil);
                    }

                }, failure: { (error) in
                    print(error);
                    self.testLabel.text = error.message;
                })
            }
        }
        self.view.endEditing(true);
    }
    @IBAction func googleTapped(_ sender: UIButton) {
        
        
    }
}

extension ViewController {
    func register() {
        
        API_MANAGER.requestRegister(email: self.emailTextField.text!, name: self.firstNameTextField.text!, password: self.passwordTextField.text!, passwordComfirmation: self.passwordConfirmationTextField.text!, country: self.lastNameTextField.text!, success: { (_) in
            self.testLabel.text = "Successful";
            
        }) { (error) in
            self.testLabel.text = error.message;
        }
    }
    
}


