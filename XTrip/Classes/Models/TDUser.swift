//
//  TDUser.swift
//  travelDiary
//
//  Created by Hoang Cap on 7/11/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation
import ObjectMapper

class TDUser:NSObject, Mappable, NSCoding {
    
    private enum JSONWrapperKey: String {
        case id = "id"
        case email = "email"
        case name = "name"
        case country = "country"
        case contact = "contact"
        case fbId = "fb_id"
        case profilePicture = "profilePicture"
        case coverPicture = "cover_picture"
        case imageUrl = "image_url"
        case allowNotification = "allow_notification"
        case allowTagMe = "allow_tag_me"
        case receiveMessage = "receive_message"
    }
    
    var id:String!
    var email:String?
    var name:String?
    var country: String?
    var contact: String?
    var fbId: String?
    var profilePicture: String?
    var coverPicture: String?
    var imageUrl: String?
    var allowNotification: Bool?
    var allowTagMe: Bool?
    var receiveMessage: Bool?
    
    //MARK: Mappable
    required init?(map: Map) {
        super.init();
    }
    
    func mapping(map: Map) {
        var idTemp: Int64 = 0
        idTemp         <- map["id"]
        id = "\(idTemp)"
        email       <- map["email"]
        name          <- map["name"]
        country       <- map["country"]
        contact       <- map["contact"]
        fbId            <- map["fb_id"]
        profilePicture <- map["profile_picture"]
        coverPicture    <- map["cover_picture"]
        imageUrl       <- map["image_url"]
        allowNotification   <- map["allow_notification"]
        allowTagMe   <- map["allow_tag_me"]
        receiveMessage   <- map["receive_message"]
    }
    
    // NSCoding
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        self.id  = aDecoder.decodeObject(forKey: JSONWrapperKey.id.rawValue) as? String
        self.email  = aDecoder.decodeObject(forKey: JSONWrapperKey.email.rawValue) as? String
        self.name  = aDecoder.decodeObject(forKey: JSONWrapperKey.name.rawValue) as? String
        self.country  = aDecoder.decodeObject(forKey: JSONWrapperKey.country.rawValue) as? String
        self.contact  = aDecoder.decodeObject(forKey: JSONWrapperKey.contact.rawValue) as? String
        self.fbId  = aDecoder.decodeObject(forKey: JSONWrapperKey.fbId.rawValue) as? String
        
        self.profilePicture  = aDecoder.decodeObject(forKey: JSONWrapperKey.profilePicture.rawValue) as? String
        self.coverPicture  = aDecoder.decodeObject(forKey: JSONWrapperKey.coverPicture.rawValue) as? String
        
        self.imageUrl  = aDecoder.decodeObject(forKey: JSONWrapperKey.imageUrl.rawValue) as? String
        
        self.allowNotification  = aDecoder.decodeBool(forKey: JSONWrapperKey.allowNotification.rawValue)
        self.allowTagMe  = aDecoder.decodeBool(forKey: JSONWrapperKey.allowTagMe.rawValue)
        self.receiveMessage  = aDecoder.decodeBool(forKey: JSONWrapperKey.receiveMessage.rawValue)
    }
    
    func encode(with aCoder: NSCoder) {
        if let userId = self.id {
            aCoder.encode(userId, forKey: JSONWrapperKey.id.rawValue)
        }
        
        if let email = self.email {
            aCoder.encode(email, forKey: JSONWrapperKey.email.rawValue)
        }
        
        if let name = self.name {
            aCoder.encode(name, forKey: JSONWrapperKey.name.rawValue)
        }
        
        if let country = self.country {
            aCoder.encode(country, forKey: JSONWrapperKey.country.rawValue)
        }
        
        if let contact = self.contact {
            aCoder.encode(contact, forKey: JSONWrapperKey.contact.rawValue)
        }
        
        if let fbId = self.fbId {
            aCoder.encode(fbId, forKey: JSONWrapperKey.fbId.rawValue)
        }
        
        if let profilePicture = self.profilePicture {
            aCoder.encode(profilePicture, forKey: JSONWrapperKey.profilePicture.rawValue)
        }
        
        if let coverPicture = self.coverPicture {
            aCoder.encode(coverPicture, forKey: JSONWrapperKey.coverPicture.rawValue)
        }
        
        if let imageUrl = self.imageUrl {
            aCoder.encode(imageUrl, forKey: JSONWrapperKey.imageUrl.rawValue)
        }
        
        if let allowNotification = self.allowNotification {
            aCoder.encode(allowNotification, forKey: JSONWrapperKey.allowNotification.rawValue)
        }
        
        if let allowTagMe = self.allowTagMe {
            aCoder.encode(allowTagMe, forKey: JSONWrapperKey.allowTagMe.rawValue)
        }
        
        if let receiveMessage = self.receiveMessage {
            aCoder.encode(receiveMessage, forKey: JSONWrapperKey.receiveMessage.rawValue)
        }
    }
    
    // MARK: -
    // MARK: current user
    static func currentUser() -> TDUser?{
        var user : TDUser? = nil
        let data = USER_DEFAULT_GET(key: .currentUser) as! Data?
        if(data != nil){
            user = NSKeyedUnarchiver.unarchiveObject(with: data!) as! TDUser?
        }
        return user
    }
    
    // MARK: -
    // MARK: - Utility methods
    static func save(_ user:TDUser) {
        let data = NSKeyedArchiver.archivedData(withRootObject: user)
        USER_DEFAULT_SET(value: data, key: .currentUser)
        USER_DEFAULT_SYNC();
    }
    
    static func clear() {
        USER_DEFAULT_SET(value: nil, key: .currentUser);
        USER_DEFAULT_SYNC();
    }
}
