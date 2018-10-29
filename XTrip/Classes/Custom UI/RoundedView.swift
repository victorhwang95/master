//
//  CircleView.swift
//  Opla-User
//
//  Created by Hoang Cap on 5/10/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation
import UIKit
class RoundedView : UIView {
    
    
    private var corners: UIRectCorner = [];
    
    @IBInspectable var topLeft: Bool = false {
        didSet {
            if (topLeft) {
                self.corners.insert(.topLeft);
            } else {
                self.corners.remove(.topLeft);
            }
        }
    }
    
    @IBInspectable var topRight: Bool = false {
        didSet {
            
            if (topRight) {
                self.corners.insert(.topRight);
            } else {
                self.corners.remove(.topRight);
            }
        }
    }
    
    @IBInspectable var bottomLeft: Bool = false {
        didSet {
            
            
            if (bottomLeft) {
                self.corners.insert(.bottomLeft);
            } else {
                self.corners.remove(.bottomLeft);
            }
        }
    }
    
    @IBInspectable var bottomRight: Bool = false {
        didSet {
            
            if (bottomRight) {
                self.corners.insert(.bottomRight);
            } else {
                self.corners.remove(.bottomRight);
            }
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear;
    
    @IBInspectable var cornerRadius: CGFloat = 0;
    
    
    @IBInspectable var borderWidth: CGFloat = 0;
    
    @IBInspectable var roundToCircle: Bool = false;
    
    var borderLayer = CAShapeLayer();
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let maskLayer = CAShapeLayer();
        
        let actualCornerRadius = self.roundToCircle ? self.width / 2 : self.cornerRadius;
        let actualCorners = self.roundToCircle ? [UIRectCorner.allCorners] : self.corners;
        
        let path = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: actualCorners, cornerRadii: CGSize(width: actualCornerRadius, height: 0));//Passing height:0 does absolutely nothing. Fuck you stupid Apple engineers
        
        maskLayer.path = path.cgPath;
        
        maskLayer.frame = self.bounds;
        self.layer.mask = maskLayer;
        
        self.borderLayer.path = maskLayer.path;
        self.borderLayer.fillColor = UIColor.clear.cgColor;
        self.borderLayer.strokeColor = self.borderColor.cgColor;
        self.borderLayer.lineWidth = self.borderWidth;
        self.borderLayer.frame = self.bounds;
        
        if (borderLayer.superlayer == nil) {
            self.layer.addSublayer(self.borderLayer);
        }
        
        borderLayer.layoutIfNeeded();
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect);
    }
}
