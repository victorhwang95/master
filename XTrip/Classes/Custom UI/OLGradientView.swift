//
//  OLGradientView.swift
//  XTrip
//
//  Created by Hoang Cap on 2/4/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable
final class OLGradientView: UIView {
    @IBInspectable var startColor: UIColor = UIColor.clear
    @IBInspectable var endColor: UIColor = UIColor.clear
    
    lazy var gradientLayer: CAGradientLayer = {
        var layer = CAGradientLayer();
        layer.colors = [self.startColor.cgColor, self.endColor.cgColor];

        return layer;
    }()
    override func draw(_ rect: CGRect) {
        gradientLayer.frame = self.bounds;
//        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0);
//        gradientLayer.endPoint = CGPoint.init(x: 0, y: self.height);
        
        if (gradientLayer.superlayer == nil) {
            layer.addSublayer(gradientLayer)
        }
    }
}
