//
//  RoundedImageView.swift
//  Opla-User
//
//  Created by Hoang Cap on 8/11/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation
import UIKit
class RoundedImageView : UIImageView {
    
    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0;
    
    @IBInspectable var borderWidth: Int = 1 {
        didSet {
            layer.borderWidth = CGFloat(borderWidth)
        }
    }
    
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
}
