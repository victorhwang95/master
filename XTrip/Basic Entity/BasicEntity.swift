//
//  BasicEntity.swift
//  XTrip
//
//  Created by Khoa Bui on 1/6/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import Foundation
import ObjectMapper

class BasicEntity: Mappable {
    
    private enum JSONWrapperKey: String {
        case totalCount = "total_count"
        case page = "page"
        case lastPage = "last_page"
        case result = "result"
    }
    
    var totalCount: Int?
    var page: Int?
    var lastPage: Bool?
    
    var tripList: [TDTrip]?
    var pictureList: [TDMyPicture]?

    convenience required init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        totalCount      <- map["total_count"]
        page            <- map["page"]
        lastPage        <- map["last_page"]
        tripList        <- map["result"]
        pictureList     <- map["result"]
    }
}
