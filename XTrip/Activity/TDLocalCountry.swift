//
//  TDLocalCountry.swift
//  XTrip
//
//  Created by Khoa Bui on 2/2/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import Foundation
import ObjectMapper

class TDLocalCountry: Mappable {
    
    private enum JSONWrapperKey: String {
        case name = "name"
        case alpha2 = "alpha-2"
        case alpha3 = "alpha-3"
        case countryCode = "country-code"
        case iso3166 = "iso_3166-2"
        case region = "region"
        case subRegion = "sub-region"
        case regionCode = "region-code"
        case subRegionCode = "sub-region-code"
        case stamp = "stamp"
        case color = "color"
    }
    
    var name: String?
    var alpha2: String?
    var alpha3: String?
    var countryCode: String?
    var iso3166: String?
    var region: String?
    var subRegion: String?
    var regionCode: String?
    var subRegionCode: String?
    var stamp: String?
    var color: String?
    var date: Date?
    
    //MARK: Mappable
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        name                  <- map[JSONWrapperKey.name.rawValue]
        alpha2                <- map[JSONWrapperKey.alpha2.rawValue]
        alpha3                <- map[JSONWrapperKey.alpha3.rawValue]
        countryCode           <- map[JSONWrapperKey.countryCode.rawValue]
        iso3166               <- map[JSONWrapperKey.iso3166.rawValue]
        region                <- map[JSONWrapperKey.region.rawValue]
        subRegion             <- map[JSONWrapperKey.subRegion.rawValue]
        regionCode            <- map[JSONWrapperKey.regionCode.rawValue]
        subRegionCode         <- map[JSONWrapperKey.subRegionCode.rawValue]
        stamp                 <- map[JSONWrapperKey.stamp.rawValue]
        color                 <- map[JSONWrapperKey.color.rawValue]
    }
}
