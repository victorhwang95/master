//
//  StringExtension.swift
//  User-iOS
//
//  Created by Tuan Nguyen on 4/25/17.
//  Copyright © 2017 com.order. All rights reserved.
//

import UIKit

extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
    func firstStringBefore(seprarator sep:String) -> String {

        let arr = self.components(separatedBy: ",")
        return arr.first!;
    }
    
    func substring(_ from: Int) -> String {
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: from))
    }
    
    var length: Int {
        return self.characters.count
    }
    
    func width(font: UIFont) -> CGFloat {
        let fontAttributes = [NSFontAttributeName: font]
        return (self as NSString).size(attributes: fontAttributes).width
    }
    
    
}
