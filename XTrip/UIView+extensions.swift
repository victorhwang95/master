//
//  UIView+extensions.swift
//  XTrip
//
//  Created by Khoa Bui on 12/2/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

extension UIView {
    
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }
    
    @IBInspectable var cornerRadiusValue: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            
            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }
    
    
    func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
                   shadowOpacity: Float = 0.3,
                   shadowRadius: CGFloat = 1.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    
    func getCountryListFromJsonFile() -> [TDLocalCountry] {
        let file = Bundle.main.url(forResource: "Countries", withExtension: "json")!;
        let data = try! Data(contentsOf: file);
        let json = try! JSONSerialization.jsonObject(with: data, options: []);
        let object = json as! [[String: Any]]
        var localCountryArray: [TDLocalCountry] = []
        let countryArray = Mapper<TDLocalCountry>().mapArray(JSONArray: object)
        if countryArray.count > 0 {
            localCountryArray = countryArray
        }
        return localCountryArray
    }
}
