//
//  Country.swift
//  XTrip
//
//  Created by Khoa Bui on 1/12/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import Foundation
import ObjectMapper

class Country: Mappable {
    
    private enum JSONWrapperKey: String {
        case countryCode = "country"
        case countryName = "country_name"
    }
    
    var code: String?
    var name: String?
    
    init() {}
    
    //MARK: Mappable
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        code        <- map[JSONWrapperKey.countryCode.rawValue]
        name        <- map[JSONWrapperKey.countryName.rawValue]
    }
}
