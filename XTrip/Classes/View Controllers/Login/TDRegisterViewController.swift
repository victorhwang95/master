//
//  TDRegisterViewController.swift
//  travelDiary
//
//  Created by Hoang Cap on 8/4/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation
import UIKit
import FacebookLogin
import FacebookCore
import KeychainAccess



import Spring

class TDRegisterViewController:UIViewController {
    
    // MARK:- Public method
    static func newInstance() -> TDRegisterViewController {
        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TDRegisterViewController") as! TDRegisterViewController
    }

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var countryButton: UIButton!
    
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var countryImage: UIImageView!
    
    var selectedCountryCode: String?
    
    deinit {
        log.info("dealloc");
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationManager.shared.requestLocationServiceIfNeeded()
    }
    
    @IBAction func forgotPassButtonTapped(_ sender: UIButton) {
        let forgotPassVC = TDForgotPassViewController.newInstance()
        self.present(forgotPassVC, animated: true, completion: nil)
    }
    
    @IBAction func countryButtonTapped(_ sender: Any) {
        let vc = TDCountrySelectionViewController.loadFromStoryboard();
        vc.delegate = self;
        let nav = UINavigationController.init(rootViewController: vc);
        
        self.present(nav, animated: true, completion: nil);
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        if (self.inputIsValid) {
            self.register();
        }
    }
    
    @IBAction func facebookButtonTapped(_ sender: UIButton) {
        let manager = LoginManager.init(loginBehavior: .native, defaultAudience: .everyone);
        
        manager.logIn(readPermissions: [.publicProfile, .email, .userFriends], viewController: self) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
                UIAlertController.show(in: self, withTitle: "Could not login to Facebook", message: "Something went wrong with your Facebook account, please try again later", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil);
            case .cancelled:
                print("User cancelled login.")
            case .success( _,  _, let accessToken):

                // Firebase analytics
                FIR_MANAGER.sendAppEvent(withEvent: FIREvent.SIGN_IN_FB_FUNCTION.rawValue, userId: nil)

                let expireTimeInterval = accessToken.expirationDate.timeIntervalSince1970;
                let token = accessToken.authenticationToken;

                self.xt_startNetworkIndicatorView(withMessage: "Logging in...")
                API_MANAGER.requestLoginWithFacebook(accessToken: token, expireIn: expireTimeInterval, success: { (user) in
                    self.xt_stopNetworkIndicatorView();

                    //Check for user's country
                    if (user.country != nil) {//If country is available -> Proceed to app
                        //Check if email presents -> Save the user and proceed to app
                        TDUser.save(user);
                        // Update device token for push notification
                        if let deviceToken = USER_DEFAULT_GET(key: .deviceToken) as? String {
                            API_MANAGER.requestUpdateDeviceToken(deviceToken: deviceToken, success: nil, failure: nil)
                            USER_DEFAULT_SET(value: true, key: .isUpdatedeviceToken)
                        }
                        AppDelegate.current.showMainScreen()
                    } else {//If keychain is not available -> Force user to choose country, then perform login with fb again.
                        Keychain.clear();
                        let vc = TDCountrySelectionViewController.loadFromStoryboard();
                        vc.facebookDelegate = self;
                        let nav = UINavigationController.init(rootViewController: vc);
                        self.present(nav, animated: true, completion: nil);
                    }
                }, failure: { (error) in
                    LoginManager().logOut();
                    UIAlertController.show(in: self, withTitle: "Could not register", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil);
                    self.xt_stopNetworkIndicatorView();
                })
            }
        }
        DispatchQueue.main.async {//Must call dispatch on main here to prevent warning log
            self.view.endEditing(true);
        }
    }
}

extension TDRegisterViewController {
    func register() {
        
        // Firebase analytics
        FIR_MANAGER.sendAppEvent(withEvent: FIREvent.SIGN_UP_FUNCTION.rawValue, userId: nil)
        
        self.xt_startNetworkIndicatorView(withMessage: "Signing up...");
        API_MANAGER.requestRegister(email: self.emailTextField.text!, name: self.nameTextField.text!, password: self.passwordTextField.text!, passwordComfirmation: self.confirmPasswordTextField.text!, country: self.selectedCountryCode!, success: { (user) in
            
            let vc = TDAccountVerificationViewController.loadFromStoryboard();
            vc.loginEmail = self.emailTextField.text!;
            vc.loginPassword = self.passwordTextField.text!;
            self.navigationController?.pushViewController(vc, animated: true);
            
            self.xt_stopNetworkIndicatorView();
        }) { (error) in
            UIAlertController.show(in: self, withTitle: "Could not register", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil);
            self.xt_stopNetworkIndicatorView();
        }
    }
}

fileprivate extension TDRegisterViewController {
    var userName: (String, String) {
        if let name =  self.nameTextField.text {
            let components = name.components(separatedBy: " ");
            
            if components.count > 1 {
                let firstName = components[0];
                let lastName = name.substring(firstName.length + 1);
                return (firstName, lastName);
            } else {
                return (name, "");
            }
        }
        return ("", "");
    }
    
    var inputIsValid: Bool {
        if let email = self.emailTextField.text, !email.isValidEmail {
            UIAlertController.show(in: self, withTitle: "Email invalid", message: "Your email is invalid", cancelButtonTitle: "Try again", otherButtonTitles: nil, tap: nil)
            return false;
        }
        
        let password = self.passwordTextField.text
        
        if let password = password, !password.isValidPassword {
            UIAlertController.show(in: self, withTitle: "Password invalid", message: "Password should be at least 8 characters", cancelButtonTitle: "Try again", otherButtonTitles: nil, tap: nil)
            return false;
        }
        
        if let confirmPassword = self.confirmPasswordTextField.text, confirmPassword != password {
            UIAlertController.show(in: self, withTitle: "Password does not match", message: "Your password and confirmation don't match", cancelButtonTitle: "Try again", otherButtonTitles: nil, tap: nil)
            return false;
        }
        
        if (self.selectedCountryCode == nil) {
            UIAlertController.show(in: self, withTitle: "Resident country needed", message: "Please select your resident country", cancelButtonTitle: "Try again", otherButtonTitles: nil, tap: nil)
            return false;
        }
        
        return true;
    }
}

extension TDRegisterViewController:TDCountrySelectionViewDelegate {
    func countrySelectionViewDidPickCountryCodes(_ codes: [String]) {
        self.dismiss(animated: true, completion: nil);
        
        let code = codes.first!;//Unwrapping is safe
        
        self.selectedCountryCode = code;
        self.countryLabel.text = code.countryName;
    
        self.countryImage.image = UIImage.init(named: code)!
    }
}

extension TDRegisterViewController: TDCountrySelectionViewFBDelegate {
    func countrySelectionViewDidPickCountryCodesForFacebook(_ codes: [String]) {
        let countryCode = codes.first!;//Unwrapping is safe because in case of FB register, codes always contains 1 country cod
        let accessToken = AccessToken.current!;//Unwrapping is safe because user must have logged in with FB before selecting country
        
        let expireTimeInterval = accessToken.expirationDate.timeIntervalSince1970;
        let token = accessToken.authenticationToken;
        self.xt_startNetworkIndicatorView(withMessage: "Proceeding to XTrip...")
        API_MANAGER.requestLoginWithFacebook(accessToken: token, expireIn: expireTimeInterval, countryCode: countryCode, success: { (user) in
            self.xt_stopNetworkIndicatorView();
            //Check if email presents -> Save the user and proceed to app
            TDUser.save(user);
            // Update device token for push notification
            if let deviceToken = USER_DEFAULT_GET(key: .deviceToken) as? String {
                API_MANAGER.requestUpdateDeviceToken(deviceToken: deviceToken, success: nil, failure: nil)
                USER_DEFAULT_SET(value: true, key: .isUpdatedeviceToken)
            }
            AppDelegate.current.showMainScreen()
        }, failure: { (error) in
            LoginManager().logOut();
            UIAlertController.show(in: self, withTitle: "Could not register", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil);
            self.xt_stopNetworkIndicatorView();
        })
        
    }
    
    func countrySelectionViewDidCancel() {
        LoginManager().logOut();//Log out of Facebook incase user didn't choose a country
    }
    
}

