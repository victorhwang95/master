//
//  TDAccountVerificationViewController.swift
//  XTrip
//
//  Created by Hoang Cap on 11/16/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation
//
//protocol TDAccountVerificationViewDelegate: class {
//    func accountVerificationDidFinished(fromViewController: TDAccountVerificationViewController);
//}

class TDAccountVerificationViewController: UIViewController {
    
//    weak var delegate: TDAccountVerificationViewDelegate?;
    
    var loginEmail: String!
    var loginPassword: String!
    
    @IBOutlet var verificationTextFields: [UITextField]!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        self.verificationTextFields.first?.becomeFirstResponder();
    }

    @IBAction func textFieldDidChange(_ sender: UITextField) {
        self.handleTextFieldChange(forTextField: sender);
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true);
    }
    
    
    @IBAction func verifyButtonTapped(_ sender: Any) {
        
        self.xt_startNetworkIndicatorView(withMessage: "Verifying...")
        
        let code = self.verificationCode;
        if (code.length != 6) {
            UIAlertController.show(in: self, withTitle: "Invalid code", message: "Please enter all 6 digits", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil);
            self.xt_stopNetworkIndicatorView();
        } else {
            API_MANAGER.requestAccountVerification(verificationCode: code, success: { () in
                API_MANAGER.requestLogin(email: self.loginEmail, password: self.loginPassword, success: { (user) in
                    TDUser.save(user);
                    print("User saved")
                    // Update device token for push notification
                    if let deviceToken = USER_DEFAULT_GET(key: .deviceToken) as? String {
                        API_MANAGER.requestUpdateDeviceToken(deviceToken: deviceToken, success: nil, failure: nil)
                        USER_DEFAULT_SET(value: true, key: .isUpdatedeviceToken)
                    }
                    AppDelegate.current.showMainScreen();
                    
                }) { (error) in
                    self.xt_stopNetworkIndicatorView();
                    UIAlertController.show(in: self, withTitle: "Could not login", message: error.message, cancelButtonTitle: "Try again", otherButtonTitles: nil, tap: nil);
                }
            }, failure: { (error) in
                UIAlertController.show(in: self, withTitle: "Could not verify your account", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil);
                self.xt_stopNetworkIndicatorView();
            })
        }
    }
}

extension TDAccountVerificationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string.length > 1) {
            return false;
        }
        
        textField.text = "";
        
        return true;
    }
}

extension TDAccountVerificationViewController {
    func handleTextFieldChange(forTextField textField:UITextField) {
        if (textField.text?.length == 1) {
            let nextIndex = self.verificationTextFields.index(of: textField)! + 1;
            
            if (nextIndex == self.verificationTextFields.count) {
                self.view.endEditing(true);
            } else {
                self.verificationTextFields[nextIndex].becomeFirstResponder();
            }
        }
    }
    
    var verificationCode: String {
        var result = "";
        for textField in self.verificationTextFields {
            let digit = textField.text!;
            result.append(digit);
        }
        return result;
    }
}
