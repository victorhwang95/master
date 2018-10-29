//
//  TravelDiaryExtension.swift
//  travelDiary
//
//  Created by Hoang Cap on 7/11/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//


import UIKit
import NVActivityIndicatorView

//Specific extension for checking email and password
extension String {
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,5}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    var isValidPassword: Bool {
        return self.length >= 8;
    }
}

extension UIViewController {
    //MARK: Show HUD-like network indicator
    func xt_startNetworkIndicatorView(withMessage message:String) {
        
        self.view.endEditing(true);
        self.startAnimating(CGSize.init(width: 100, height: 100), message: message, messageFont: UIFont.xt_mainFont(20), type: .ballRotateChase, color: .white, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: UIColor.black.withAlphaComponent(0.5), textColor: .white);
    }
    
    func xt_stopNetworkIndicatorView() {
        self.stopAnimating()
    }
}

//MARK: Indicator show/hide

extension UIViewController:NVActivityIndicatorViewable {
    fileprivate func startAnimating(
        _ size: CGSize? = nil,
        message: String? = nil,
        messageFont: UIFont? = nil,
        type: NVActivityIndicatorType? = nil,
        color: UIColor? = nil,
        padding: CGFloat? = nil,
        displayTimeThreshold: Int? = nil,
        minimumDisplayTime: Int? = nil,
        backgroundColor: UIColor? = nil,
        textColor: UIColor? = nil) {
        let activityData = ActivityData(size: size,
                                        message: message,
                                        messageFont: messageFont,
                                        type: type,
                                        color: color,
                                        padding: padding,
                                        displayTimeThreshold: displayTimeThreshold,
                                        minimumDisplayTime: minimumDisplayTime,
                                        backgroundColor: backgroundColor,
                                        textColor: textColor)
        
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
    }
    
    /**
     Remove UI blocker.
     */
    fileprivate func stopAnimating() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(nil);
    }
}

extension UIFont {
    class func xt_mainFont(_ size:CGFloat) -> UIFont {
        return UIFont(name: "Avenir-Book", size: size)!;
    }
}
