//
//  TDStamp.swift
//  XTrip
//
//  Created by Khoa Bui on 1/30/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import Foundation
import ObjectMapper

class TDStamp: Mappable {
    
    private enum JSONWrapperKey: String {
        case id = "id"
        case uploadedAt = "uploaded_at"
        case country = "country"
    }
    
    var id: Int?
    var countryCode: String?
    var uploadedAt: Double?
    
    //MARK: Mappable
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id                  <- map[JSONWrapperKey.id.rawValue]
        countryCode         <- map[JSONWrapperKey.country.rawValue]
        uploadedAt            <- map[JSONWrapperKey.uploadedAt.rawValue]
    }
}
