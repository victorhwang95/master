//
//  TDLoginViewController.swift
//  XTrip
//
//  Created by Hoang Cap on 11/14/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation

class TDLoginViewController:UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        // Firebase analytics
        FIR_MANAGER.sendAppEvent(withEvent: FIREvent.SIGN_IN_FUNCTION.rawValue, userId: nil)
        
        self.xt_startNetworkIndicatorView(withMessage: "Logging in...")

        API_MANAGER.requestLogin(email: self.emailTextField.text!, password: self.passwordTextField.text!, success: { (user) in
            self.xt_stopNetworkIndicatorView();
            TDUser.save(user);
            print("User saved")
            AppDelegate.current.showMainScreen()
            // Update device token for push notification
            if let deviceToken = USER_DEFAULT_GET(key: .deviceToken) as? String {
                API_MANAGER.requestUpdateDeviceToken(deviceToken: deviceToken, success: {() -> () in
                    USER_DEFAULT_SET(value: true, key: .isUpdatedeviceToken)
                }, failure: nil)
            }
        }) { (error) in
            self.xt_stopNetworkIndicatorView();
            UIAlertController.show(in: self, withTitle: "Could not login", message: error.message, cancelButtonTitle: "Try again", otherButtonTitles: nil, tap: nil);
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil);
    }
}
