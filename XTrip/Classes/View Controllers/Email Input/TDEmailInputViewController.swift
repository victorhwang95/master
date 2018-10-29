//
//  TDEmailInputViewController.swift
//  travelDiary
//
//  Created by Hoang Cap on 8/4/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation

import FacebookLogin
import FacebookCore

class TDEmailInputViewController:UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        
        //Double check for facebook token and expired date
        guard let _ = AccessToken.current?.authenticationToken, let expire = AccessToken.current?.expirationDate.timeIntervalSince1970, expire > Date().timeIntervalSince1970 else {
            log.error("Facebook token not available or expired");
            
            UIAlertController.show(in: self, withTitle: "Could not register", message: "Facebook login session expired", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil);
            self.xt_stopNetworkIndicatorView();
            
            return;
        }
        
        API_MANAGER.requestUpdateProfile(email: emailTextField.text, name: nil, password: nil, passwordComfirmation: nil, contact: nil, country: nil, fbId: nil, allowNotification: nil, allowTagMe: nil, receiveMessage: nil, profilePicture: nil, coverPicture: nil, success: { (user) in
            log.info("Registered: \(user.email)")
            
            let vc = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "TDOnboardingViewController");
            
            AppDelegate.current.setRootViewController(vc, true);
            
            self.presentingViewController?.dismiss(animated: false, completion: nil);
            
            
        }) { (error) in
            log.info("Registered error: \(error.message)")
        }
    }
    
    deinit {
        log.info("dealloc");
    }
    
}
