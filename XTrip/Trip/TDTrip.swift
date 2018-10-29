//
//  TDTrip.swift
//  XTrip
//
//  Created by Khoa Bui on 12/11/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation
import ObjectMapper

class TDTrip: NSObject, Mappable, NSCoding {
    
    private enum JSONWrapperKey: String {
        
        case tripId = "id"
        case name = "name"
        case createdDate = "created_at"
        case startDate = "start_date"
        case endDate = "end_date"
        case ownerId = "created_by"
        case tripDescription = "description"
        case tripSchedule = "trip_schedule"
        case friend = "user"
        case tripLastPicture = "last_picture"
        case userJoinTrip = "user_join_trip"
    }
    
    var tripId: Int?
    var name: String?
    var createdDate: Double?
    var startDate: Double?
    var endDate: Double?
    var ownerId: Int?
    var tripDescription: String?
    var tripSchedule: [TDSchedule]?
    var friend: TDUser?
    var tripLastPicture: TDMyPicture?
    var userJoinTrip: [TDUser]?
    
    //MARK: Mappable
    required init?(map: Map) {
        super.init()
    }
    
    func mapping(map: Map) {
        tripId              <- map[JSONWrapperKey.tripId.rawValue]
        name                <- map[JSONWrapperKey.name.rawValue]
        createdDate         <- map[JSONWrapperKey.createdDate.rawValue]
        startDate           <- map[JSONWrapperKey.startDate.rawValue]
        endDate             <- map[JSONWrapperKey.endDate.rawValue]
        ownerId             <- map[JSONWrapperKey.ownerId.rawValue]
        tripDescription     <- map[JSONWrapperKey.tripDescription.rawValue]
        tripSchedule        <- map[JSONWrapperKey.tripSchedule.rawValue]
        friend              <- map[JSONWrapperKey.friend.rawValue]
        tripLastPicture     <- map[JSONWrapperKey.tripLastPicture.rawValue]
        userJoinTrip        <- map[JSONWrapperKey.userJoinTrip.rawValue]
        
    }

    // NSCoding
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        self.tripId  = aDecoder.decodeInteger(forKey: JSONWrapperKey.tripId.rawValue)
        self.name  = aDecoder.decodeObject(forKey: JSONWrapperKey.name.rawValue) as? String
        self.createdDate  = aDecoder.decodeDouble(forKey: JSONWrapperKey.createdDate.rawValue)
        self.startDate  = aDecoder.decodeDouble(forKey: JSONWrapperKey.startDate.rawValue)
        self.endDate  = aDecoder.decodeDouble(forKey: JSONWrapperKey.endDate.rawValue)
        self.ownerId  = aDecoder.decodeInteger(forKey: JSONWrapperKey.ownerId.rawValue)
        self.tripDescription  = aDecoder.decodeObject(forKey: JSONWrapperKey.tripDescription.rawValue) as? String
        self.tripSchedule  = aDecoder.decodeObject(forKey: JSONWrapperKey.tripSchedule.rawValue) as? [TDSchedule]
        self.friend  = aDecoder.decodeObject(forKey: JSONWrapperKey.friend.rawValue) as? TDUser
        self.tripLastPicture  = aDecoder.decodeObject(forKey: JSONWrapperKey.tripLastPicture.rawValue) as? TDMyPicture
        self.userJoinTrip  = aDecoder.decodeObject(forKey: JSONWrapperKey.userJoinTrip.rawValue) as? [TDUser]
  
    }
    
    func encode(with aCoder: NSCoder) {
        
        if let tripId = self.tripId {
            aCoder.encode(tripId, forKey: JSONWrapperKey.tripId.rawValue)
        }
        
        if let name = self.name {
            aCoder.encode(name, forKey: JSONWrapperKey.name.rawValue)
        }
        
        if let createdDate = self.createdDate {
            aCoder.encode(createdDate, forKey: JSONWrapperKey.createdDate.rawValue)
        }
        
        if let startDate = self.startDate {
            aCoder.encode(startDate, forKey: JSONWrapperKey.startDate.rawValue)
        }
        
        if let endDate = self.endDate {
            aCoder.encode(endDate, forKey: JSONWrapperKey.endDate.rawValue)
        }
        
        if let ownerId = self.ownerId {
            aCoder.encode(ownerId, forKey: JSONWrapperKey.ownerId.rawValue)
        }
        
        if let tripDescription = self.tripDescription {
            aCoder.encode(tripDescription, forKey: JSONWrapperKey.tripDescription.rawValue)
        }
        
        if let tripSchedule = self.tripSchedule {
            aCoder.encode(tripSchedule, forKey: JSONWrapperKey.tripSchedule.rawValue)
        }
        
        if let friend = self.friend {
            aCoder.encode(friend, forKey: JSONWrapperKey.friend.rawValue)
        }
        
        if let tripLastPicture = self.tripLastPicture {
            aCoder.encode(tripLastPicture, forKey: JSONWrapperKey.tripLastPicture.rawValue)
        }
        
        if let userJoinTrip = self.userJoinTrip {
            aCoder.encode(userJoinTrip, forKey: JSONWrapperKey.userJoinTrip.rawValue)
        }

    }
    // MARK: -
    // MARK: - Utility methods
    
    fileprivate static func storeTripList(_ contacts: NSArray!) {
        
        let result = NSMutableArray(capacity: contacts.count)
        for contact in contacts {
            let data = NSKeyedArchiver.archivedData(withRootObject: contact)
            result.add(data)
        }
        UserDefaults.standard.set(result, forKey: "currentTripList")
    }
    
    static func clear() {
        UserDefaults.standard.removeObject(forKey: "currentTripList")
    }
    
    static func saveTripList(_ tripArray: [TDTrip]) {
        self.storeTripList(tripArray as NSArray!)
    }
    
    static func addTrip(_ trip: TDTrip){
        let triplist = getCurrentTripList()
        let bookmarkList : NSMutableArray?
        if triplist != nil {
            bookmarkList = NSMutableArray(array: triplist!)
        }
        else{
            bookmarkList = NSMutableArray(capacity: 1)
        }
        
        bookmarkList!.add(trip)
        storeTripList(bookmarkList)
    }
    
    static func getCurrentTripList() -> NSArray? {
        let tripsEncoded = UserDefaults.standard.value(forKey: "currentTripList") as? NSArray
        if tripsEncoded == nil {
            return nil;
        }
        
        let result = NSMutableArray(capacity: tripsEncoded!.count)
        for data in tripsEncoded! {
            let trip = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
            if trip != nil {
                result.add(trip!)
            }
        }
        
        return result;
    }
}

class TDSchedule: NSObject, Mappable, NSCoding  {
    
    private enum JSONWrapperKey: String {
        case lat = "lat"
        case long = "long"
        case days = "days"
        case countryCode = "country"
        case countryName = "country_name"
        case startDate = "start_date"
        case endDate = "end_date"
    }
    
    var lat: String?
    var long: String?
    var days: Int?
    var countryName: String?
    var countryCode: String?
    var startDate: Double?
    var endDate: Double?
    
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        lat              <- map[JSONWrapperKey.lat.rawValue]
        long             <- map[JSONWrapperKey.long.rawValue]
        days             <- map[JSONWrapperKey.days.rawValue]
        countryCode      <- map[JSONWrapperKey.countryCode.rawValue]
        countryName      <- map[JSONWrapperKey.countryName.rawValue]
        startDate        <- map[JSONWrapperKey.startDate.rawValue]
        endDate          <- map[JSONWrapperKey.endDate.rawValue]
    }
    
    // NSCoding
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        self.lat  = aDecoder.decodeObject(forKey: JSONWrapperKey.lat.rawValue) as? String
        self.long  = aDecoder.decodeObject(forKey: JSONWrapperKey.long.rawValue) as? String
        self.days  = aDecoder.decodeInteger(forKey: JSONWrapperKey.days.rawValue)
        self.countryCode  = aDecoder.decodeObject(forKey: JSONWrapperKey.countryCode.rawValue) as? String
        self.startDate  = aDecoder.decodeDouble(forKey: JSONWrapperKey.startDate.rawValue)
        self.endDate  = aDecoder.decodeDouble(forKey: JSONWrapperKey.endDate.rawValue)
    }
    
    func encode(with aCoder: NSCoder) {
        if let lat = self.lat{
            aCoder.encode(lat, forKey: JSONWrapperKey.lat.rawValue)
        }
        
        if let long = self.long{
            aCoder.encode(long, forKey: JSONWrapperKey.long.rawValue)
        }
        
        if let days = self.days{
            aCoder.encode(days, forKey: JSONWrapperKey.days.rawValue)
        }
        
        if let countryCode = self.countryCode{
            aCoder.encode(countryCode, forKey: JSONWrapperKey.countryCode.rawValue)
        }
        
        if let startDate = self.startDate{
            aCoder.encode(startDate, forKey: JSONWrapperKey.startDate.rawValue)
        }
        
        if let endDate = self.endDate{
            aCoder.encode(endDate, forKey: JSONWrapperKey.endDate.rawValue)
        }
    }
}
