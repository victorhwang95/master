//
//  AppContact.swift
//  XTrip
//
//  Created by Khoa Bui on 12/27/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation
import ObjectMapper

class AppContact: Mappable {
    
    private enum JSONWrapperKey: String {
        case id = "id"
        case fbId = "fb_id"
        case provider = "provider"
        case country = "country"
        case email = "email"
        case name = "name"
        case birthday = "birthday"
        case contact = "contact"
        case profilePicture = "profile_picture"
        case coverPicture = "cover_picture"
    }
    
    var id: Int?
    var fbId: String?
    var provider: String?
    var country: String?
    var email: String?
    var name: String?
    var birthday: String?
    var contact: String?
    var profilePicture: String?
    var coverPicture: String?
    
    //MARK: Mappable
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id                  <- map[JSONWrapperKey.id.rawValue]
        fbId                <- map[JSONWrapperKey.fbId.rawValue]
        provider            <- map[JSONWrapperKey.provider.rawValue]
        country             <- map[JSONWrapperKey.country.rawValue]
        email               <- map[JSONWrapperKey.email.rawValue]
        name                <- map[JSONWrapperKey.name.rawValue]
        birthday            <- map[JSONWrapperKey.birthday.rawValue]
        contact             <- map[JSONWrapperKey.contact.rawValue]
        profilePicture      <- map[JSONWrapperKey.profilePicture.rawValue]
        coverPicture        <- map[JSONWrapperKey.coverPicture.rawValue]
        
    }
}
