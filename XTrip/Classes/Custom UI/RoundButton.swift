//
//  RoundButton.swift
//  Opla-User
//
//  Created by Hoang Cap on 6/3/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation
import UIKit

class RoundedButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0;
    
    @IBInspectable var roundBorder: Bool = false;
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (self.roundBorder) {
            layer.cornerRadius = bounds.size.height / 2;
        } else {
            layer.cornerRadius = self.cornerRadius;
        }
        
        layer.masksToBounds = true;
    }
    
        fileprivate struct Constants {
            static let selectedBackGroundColor = UIColor.white
            static let selectedTitleColor = UIColor.init(hex: "30B3FF", alpha: 1)
            
            static let defaultBackGroundColor = UIColor.clear
            static let defaultTitleColor = UIColor.white
        }
    
        @IBInspectable var selectedColor: UIColor = RoundedButton.Constants.selectedBackGroundColor
        @IBInspectable var selectedTitleColor: UIColor = RoundedButton.Constants.selectedTitleColor
    
        @IBInspectable var defaultColor: UIColor = RoundedButton.Constants.defaultBackGroundColor
        @IBInspectable var defaultTitleColor: UIColor = RoundedButton.Constants.defaultTitleColor
    
        func setSelectedColor() -> Void {
            self.backgroundColor = selectedColor
            self.setTitleColor(selectedTitleColor, for: UIControlState())
        }
    
        func setNonSelectColor() -> Void {
            self.backgroundColor = defaultColor
            self.setTitleColor(defaultTitleColor, for: UIControlState())
        }
}
