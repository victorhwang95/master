//
//  TDFriend.swift
//  XTrip
//
//  Created by Khoa Bui on 2/2/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import Foundation
import ObjectMapper

class TDFriend: NSObject, Mappable, NSCoding {
    
    private enum JSONWrapperKey: String {
        case totalImage = "total_image"
        case totalTrip = "total_trip"
        case totalTemp = "total_temp"
        case user = "user"
    }
    
    var totalImage: Int?
    var totalTrip: Int?
    var totalTemp: Int?
    var user: TDUser?

    //MARK: Mappable
    required init?(map: Map) {
        super.init();
    }
    
    func mapping(map: Map) {

        totalImage          <- map[JSONWrapperKey.totalImage.rawValue]
        totalTrip           <- map[JSONWrapperKey.totalTrip.rawValue]
        totalTemp           <- map[JSONWrapperKey.totalTemp.rawValue]
        user                <- map[JSONWrapperKey.user.rawValue]
    }
    
    // NSCoding
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        self.totalImage  = aDecoder.decodeInteger(forKey: JSONWrapperKey.totalImage.rawValue)
        self.totalTrip  = aDecoder.decodeInteger(forKey: JSONWrapperKey.totalTrip.rawValue)
        self.totalTemp  = aDecoder.decodeInteger(forKey: JSONWrapperKey.totalTemp.rawValue)
        self.user  = aDecoder.decodeObject(forKey: JSONWrapperKey.user.rawValue) as? TDUser

    }
    
    func encode(with aCoder: NSCoder) {
        
        if let totalImage = self.totalImage {
            aCoder.encode(totalImage, forKey: JSONWrapperKey.totalImage.rawValue)
        }
        
        if let totalTrip = self.totalTrip {
            aCoder.encode(totalTrip, forKey: JSONWrapperKey.totalTrip.rawValue)
        }
        
        if let totalTemp = self.totalTemp {
            aCoder.encode(totalTemp, forKey: JSONWrapperKey.totalTemp.rawValue)
        }
        
        if let user = self.user {
            aCoder.encode(user, forKey: JSONWrapperKey.user.rawValue)
        }
    }
}
