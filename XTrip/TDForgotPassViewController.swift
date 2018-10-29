//
//  TDForgotPassViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 2/5/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit

enum ForgotPassStep {
    case sendCode
    case checkCode
    case createNewPass
}

class TDForgotPassViewController: UIViewController {
    
    // MARK:- Outlets
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var codeView: UIView!
    @IBOutlet weak var passView: UIView!
    @IBOutlet weak var rePassView: UIView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var codeTextField: UITextField!
    
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var rePassTextField: UITextField!
    
    @IBOutlet weak var stackView: UIStackView!
    
    // MARK:- Properties
    var forgotStep: ForgotPassStep = .sendCode
    var token: String?
    
    // MARK:- Public method
    static func newInstance() -> TDForgotPassViewController {
        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TDForgotPassViewController") as! TDForgotPassViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLayout()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupLayout() {
        switch self.forgotStep {
            
            case .checkCode:
                self.emailView.isUserInteractionEnabled = false
                self.codeView.isHidden = false
                self.passView.isHidden = true
                self.rePassView.isHidden = true
            case .createNewPass:
                self.emailView.isUserInteractionEnabled = false
                self.codeView.isUserInteractionEnabled = false
                self.codeView.isHidden = false
                self.passView.isHidden = false
                self.rePassView.isHidden = false
            default:
                self.codeView.isHidden = true
                self.passView.isHidden = true
                self.rePassView.isHidden = true
        }
    }
    
    fileprivate func handleSendCodeToEmail() {
        guard let email = self.emailTextField.text, email.isValidEmail else {
            UIAlertController.show(in: self, withTitle: "Reminder", message: "Your email is invalid", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            return
        }
        
        // Firebase analytics
        FIR_MANAGER.sendAppEvent(withEvent: FIREvent.FORGOT_PASS_FUNCTION.rawValue, userId: nil)
        
        xt_startNetworkIndicatorView(withMessage: "Sending...")
        API_MANAGER.forgotPass(email: email, success: {
            self.xt_stopNetworkIndicatorView()
            self.forgotStep = .checkCode
            self.setupLayout()
        }) { (error) in
            self.xt_stopNetworkIndicatorView()
            UIAlertController.show(in: self, withTitle: "Reminder", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        }
    }
    
    fileprivate func handleCheckCode() {
        guard let email = self.emailTextField.text, !email.isBlank else {
            UIAlertController.show(in: self, withTitle: "Reminder", message: "Your email is invalid", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            return
        }
        guard let code = self.codeTextField.text, !code.isBlank else {
            UIAlertController.show(in: self, withTitle: "Reminder", message: "Please enter your reset password code", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            return
        }
        xt_startNetworkIndicatorView(withMessage: "Cheking...")
        API_MANAGER.checkCodePass(email: email, code: code, success: { token in
            self.xt_stopNetworkIndicatorView()
            self.token = token
            self.forgotStep = .createNewPass
            self.setupLayout()
        }) { (error) in
            self.xt_stopNetworkIndicatorView()
            UIAlertController.show(in: self, withTitle: "Reminder", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        }
    }
    
    fileprivate func handleChangelPass() {
        guard let email = self.emailTextField.text, email.isValidEmail else {
            UIAlertController.show(in: self, withTitle: "Reminder", message: "Your email is invalid", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            return
        }
        
        guard let token = self.token else {
            UIAlertController.show(in: self, withTitle: "Reminder", message: "Your token is invalid", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            return
        }
        
        guard let  newPassword = self.passTextField.text, newPassword.isValidPassword else {
            UIAlertController.show(in: self, withTitle: "Password invalid", message: "Password should be at least 8 characters", cancelButtonTitle: "Try again", otherButtonTitles: nil, tap: nil)
            return
        }
        
        guard let newConfirmPassword = self.rePassTextField.text,  newConfirmPassword == newPassword else {
            UIAlertController.show(in: self, withTitle: "Password does not match", message: "Your password and confirmation don't match", cancelButtonTitle: "Try again", otherButtonTitles: nil, tap: nil)
            return
        }
        
        xt_startNetworkIndicatorView(withMessage: "Processing...")
        API_MANAGER.changeNewPass(email: email, token: token, pass: newPassword, rePass: newConfirmPassword, success: {
            self.xt_stopNetworkIndicatorView()
            UIAlertController.show(in: self, withTitle: "Reminder", message: "Change password successfully", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: {(alert) -> () in
                self.dismiss(animated: true, completion: nil)
            })
        }) { (error) in
            self.xt_stopNetworkIndicatorView()
            UIAlertController.show(in: self, withTitle: "Reminder", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        switch self.forgotStep {
            
        case .checkCode:
            self.handleCheckCode()
        case .createNewPass:
            self.handleChangelPass()
        default:
            self.handleSendCodeToEmail()
        }
    }
}
