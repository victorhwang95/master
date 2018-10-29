//
//  TDMyPicture.swift
//  XTrip
//
//  Created by Khoa Bui on 12/15/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation
import ObjectMapper

class TDMyPicture: NSObject, Mappable, NSCoding {

    private enum JSONWrapperKey: String {
        
        case imageId = "id"
        case tripId = "trip_id"
        case uploadBy = "upload_by"
        case imageUrl = "file_url"
        case uploadedAt = "uploaded_at"
        case likeCount = "like_num"
        case commentCount = "comment_num"
        case caption = "caption"
        case trip = "trip"
        case imageLocation = "location"
        case isUpload = "isUpload"
        case isLiked = "is_liked"
        case comments = "comments"
        case timeStoreLocal = "timeStoreLocal"
        
    }
    
    var imageId: Int?
    var tripId: Int?
    var uploadBy: Int?
    var imageUrl: String?
    var uploadedAt: Double?
    var likeCount: Int?
    var commentCount: Int?
    var caption: String?
    var trip: TDTrip?
    var imageLocation: LocationInfo?
    
    var isLiked: Bool?
    var comments: [TDCityComment]?
    var isUpload: Bool? = true
    var timeStoreLocal: Double = Date().timeIntervalSince1970
    
    //MARK: Mappable
    required init?(map: Map) {
        super.init()
    }
    
    func mapping(map: Map) {
        imageId              <- map[JSONWrapperKey.imageId.rawValue]
        tripId               <- map[JSONWrapperKey.tripId.rawValue]
        uploadBy             <- map[JSONWrapperKey.uploadBy.rawValue]
        imageUrl             <- map[JSONWrapperKey.imageUrl.rawValue]
        uploadedAt           <- map[JSONWrapperKey.uploadedAt.rawValue]
        likeCount            <- map[JSONWrapperKey.likeCount.rawValue]
        commentCount         <- map[JSONWrapperKey.commentCount.rawValue]
        caption              <- map[JSONWrapperKey.caption.rawValue]
        trip                 <- map[JSONWrapperKey.trip.rawValue]
        imageLocation        <- map[JSONWrapperKey.imageLocation.rawValue]
        isLiked              <- map[JSONWrapperKey.isLiked.rawValue]
        comments             <- map[JSONWrapperKey.comments.rawValue]
        
    }
    
    // NSCoding
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        self.imageId  = aDecoder.decodeInteger(forKey: JSONWrapperKey.imageId.rawValue)
        self.tripId  = aDecoder.decodeInteger(forKey: JSONWrapperKey.tripId.rawValue)
        self.uploadBy  = aDecoder.decodeInteger(forKey: JSONWrapperKey.uploadBy.rawValue)
        self.imageUrl  = aDecoder.decodeObject(forKey: JSONWrapperKey.imageUrl.rawValue) as? String
        self.uploadedAt  = aDecoder.decodeDouble(forKey: JSONWrapperKey.uploadedAt.rawValue)
        self.likeCount  = aDecoder.decodeInteger(forKey: JSONWrapperKey.likeCount.rawValue)
        self.commentCount  = aDecoder.decodeInteger(forKey: JSONWrapperKey.commentCount.rawValue)
        self.caption  = aDecoder.decodeObject(forKey: JSONWrapperKey.caption.rawValue) as? String
        self.trip  = aDecoder.decodeObject(forKey: JSONWrapperKey.trip.rawValue) as? TDTrip
        self.imageLocation  = aDecoder.decodeObject(forKey: JSONWrapperKey.imageLocation.rawValue) as? LocationInfo
        self.isUpload  = aDecoder.decodeBool(forKey: JSONWrapperKey.isUpload.rawValue)
        self.comments  = aDecoder.decodeObject(forKey: JSONWrapperKey.comments.rawValue) as? [TDCityComment]
        self.isLiked  = aDecoder.decodeBool(forKey: JSONWrapperKey.isLiked.rawValue)
        self.timeStoreLocal  = aDecoder.decodeDouble(forKey: JSONWrapperKey.timeStoreLocal.rawValue)
        
    }
    
    func encode(with aCoder: NSCoder) {
        
        if let imageId = self.imageId {
            aCoder.encode(imageId, forKey: JSONWrapperKey.imageId.rawValue)
        }
        
        if let tripId = self.tripId {
            aCoder.encode(tripId, forKey: JSONWrapperKey.tripId.rawValue)
        }
        
        if let uploadBy = self.uploadBy {
            aCoder.encode(uploadBy, forKey: JSONWrapperKey.uploadBy.rawValue)
        }
        
        if let imageUrl = self.imageUrl {
            aCoder.encode(imageUrl, forKey: JSONWrapperKey.imageUrl.rawValue)
        }
        
        if let uploadedAt = self.uploadedAt {
            aCoder.encode(uploadedAt, forKey: JSONWrapperKey.uploadedAt.rawValue)
        }
        
        if let likeCount = self.likeCount {
            aCoder.encode(likeCount, forKey: JSONWrapperKey.likeCount.rawValue)
        }
        
        if let commentCount = self.commentCount {
            aCoder.encode(commentCount, forKey: JSONWrapperKey.commentCount.rawValue)
        }
        
        if let caption = self.caption {
            aCoder.encode(caption, forKey: JSONWrapperKey.caption.rawValue)
        }
        
        if let trip = self.trip {
            aCoder.encode(trip, forKey: JSONWrapperKey.trip.rawValue)
        }
        
        if let imageLocation = self.imageLocation {
            aCoder.encode(imageLocation, forKey: JSONWrapperKey.imageLocation.rawValue)
        }
        
        if let comments = self.comments {
            aCoder.encode(comments, forKey: JSONWrapperKey.comments.rawValue)
        }
        
        if let isLiked = self.isLiked {
            aCoder.encode(isLiked, forKey: JSONWrapperKey.isLiked.rawValue)
        }
        
        if let isUpload = self.isUpload {
            aCoder.encode(isUpload, forKey: JSONWrapperKey.isUpload.rawValue)
        }
        
        aCoder.encode(timeStoreLocal, forKey: JSONWrapperKey.timeStoreLocal.rawValue)
        
    }
    
    // MARK: -
    // MARK: - Utility methods
    
    fileprivate static func storeMyPictureList(_ contacts: NSArray!) {
        
        let result = NSMutableArray(capacity: contacts.count)
        for contact in contacts {
            let data = NSKeyedArchiver.archivedData(withRootObject: contact)
            result.add(data)
        }
        UserDefaults.standard.set(result, forKey: "currentMyPictureList")
    }
    
    static func clear() {
        UserDefaults.standard.removeObject(forKey: "currentMyPictureList")
    }
    
    static func saveTripList(_ tripArray: [TDMyPicture]) {
        self.storeMyPictureList(tripArray as NSArray!)
    }
    
    static func addMyPicture(_ trip: TDMyPicture){
        let triplist = getCurrentMyPictureList()
        let bookmarkList : NSMutableArray?
        if triplist != nil {
            bookmarkList = NSMutableArray(array: triplist!)
        }
        else{
            bookmarkList = NSMutableArray(capacity: 1)
        }
        
        bookmarkList!.add(trip)
        storeMyPictureList(bookmarkList)
    }
    
    static func getCurrentMyPictureList() -> NSArray? {
        let tripsEncoded = UserDefaults.standard.value(forKey: "currentMyPictureList") as? NSArray
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
    
    static func removeLocalPicture(atPict: TDMyPicture){
        let contacts = getCurrentMyPictureList()
        let bookmarkList : NSMutableArray?
        if contacts != nil {
            bookmarkList = NSMutableArray(array: contacts!)
        }
        else{
            bookmarkList = NSMutableArray(capacity: 1)
        }
        if bookmarkList != nil {
            if let picArray = bookmarkList! as NSArray as? [TDMyPicture] {
                for (index, item) in picArray.enumerated() {
                    if item.tripId == atPict.tripId && item.timeStoreLocal == atPict.timeStoreLocal {
                        bookmarkList?.removeObject(at: index)
                        break
                    }
                }
            }
        }
        storeMyPictureList(bookmarkList)
    }
}

class LocationInfo: NSObject, Mappable, NSCoding {
    
    private enum JSONWrapperKey: String {
        
        case locationId = "id"
        case placeId = "item_id"
        case name = "name"
        case type = "type"
        case rate = "rate"
        case lat = "lat"
        case long = "long"
        case startDate = "start_date"
        case endDate = "end_date"
    }
    
    var locationId: Int?
    var placeId: String?
    var name: String?
    
    var typeString: String?
    var type: PlaceType? {
        return PlaceType(rawValue: typeString ?? "other")
    }
    
    var rate: Double?
    var lat: String?
    var long: String?
    var startDate: Double?
    var endDate: Double? 
    
    //MARK: Mappable
    required init?(map: Map) {
        super.init()
    }
    
    func mapping(map: Map) {
        locationId          <- map[JSONWrapperKey.locationId.rawValue]
        placeId             <- map[JSONWrapperKey.placeId.rawValue]
        name                <- map[JSONWrapperKey.name.rawValue]
        typeString          <- map[JSONWrapperKey.type.rawValue]
        rate                <- map[JSONWrapperKey.rate.rawValue]
        long                <- map[JSONWrapperKey.long.rawValue]
        lat                 <- map[JSONWrapperKey.lat.rawValue]
        startDate           <- map[JSONWrapperKey.startDate.rawValue]
        endDate             <- map[JSONWrapperKey.endDate.rawValue]
    }
    
    // NSCoding
    override init() {
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        self.locationId  = aDecoder.decodeInteger(forKey: JSONWrapperKey.locationId.rawValue)
        self.placeId  = aDecoder.decodeObject(forKey: JSONWrapperKey.placeId.rawValue) as? String
        self.name  = aDecoder.decodeObject(forKey: JSONWrapperKey.name.rawValue) as? String
        self.typeString  = aDecoder.decodeObject(forKey: JSONWrapperKey.type.rawValue) as? String
        self.rate  = aDecoder.decodeDouble(forKey: JSONWrapperKey.rate.rawValue)
        self.long  = aDecoder.decodeObject(forKey: JSONWrapperKey.long.rawValue) as? String
        self.lat  = aDecoder.decodeObject(forKey: JSONWrapperKey.lat.rawValue) as? String
        self.startDate  = aDecoder.decodeDouble(forKey: JSONWrapperKey.startDate.rawValue)
        self.endDate  = aDecoder.decodeDouble(forKey: JSONWrapperKey.endDate.rawValue)
        
    }
    
    func encode(with aCoder: NSCoder) {
        
        if let locationId = self.locationId {
            aCoder.encode(locationId, forKey: JSONWrapperKey.locationId.rawValue)
        }
        
        if let placeId = self.placeId {
            aCoder.encode(placeId, forKey: JSONWrapperKey.placeId.rawValue)
        }
        
        if let name = self.name {
            aCoder.encode(name, forKey: JSONWrapperKey.name.rawValue)
        }
        
        if let typeString = self.typeString {
            
            aCoder.encode(typeString, forKey: JSONWrapperKey.type.rawValue)
        }
        
        if let rate = self.rate {
            aCoder.encode(rate, forKey: JSONWrapperKey.rate.rawValue)
        }
        
        if let long = self.long {
            aCoder.encode(long, forKey: JSONWrapperKey.long.rawValue)
        }
        
        if let lat = self.lat {
            aCoder.encode(lat, forKey: JSONWrapperKey.lat.rawValue)
        }
        
        if let startDate = self.startDate {
            aCoder.encode(startDate, forKey: JSONWrapperKey.startDate.rawValue)
        }
        
        if let endDate = self.endDate {
            aCoder.encode(endDate, forKey: JSONWrapperKey.endDate.rawValue)
        }
    }
}
