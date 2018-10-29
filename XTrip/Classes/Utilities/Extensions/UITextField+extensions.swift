//
//  UITextField+extensions.swift
//  XTrip
//
//  Created by Hoang Cap on 11/13/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation

extension UITextField {
    @IBInspectable var placeholderColor: UIColor {
        get {
            guard let currentAttributedPlaceholderColor = attributedPlaceholder?.attribute(NSForegroundColorAttributeName, at: 0, effectiveRange: nil) as? UIColor else { return UIColor.clear }
            return currentAttributedPlaceholderColor
        }
        set {
            guard let currentAttributedString = attributedPlaceholder else { return }
            let attributes = [NSForegroundColorAttributeName : newValue]
            
            attributedPlaceholder = NSAttributedString(string: currentAttributedString.string, attributes: attributes)
        }
    }
}
