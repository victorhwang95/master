//
//  TDPageDot.swift
//  XTrip
//
//  Created by Hoang Cap on 1/26/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import Foundation

class TDPageDot: UIView {
    
    @IBOutlet weak var dotSize: NSLayoutConstraint!
    
    func setBigSize(_ bigSize: Bool) {
        if (bigSize) {
            self.dotSize.constant = 15;
        } else {
            self.dotSize.constant = 10;
        }
    }
    
}
