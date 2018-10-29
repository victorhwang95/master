//
//  AbstractActivity.swift
//  XTrip
//
//  Created by Khoa Bui on 1/14/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import Foundation
import ObjectMapper

class AbstractActivity: Mappable {
    
    private enum JSONWrapperKey: String {
        case id = "id"
        case postType = "post_type"
        case title = "title"
        case createdBy = "created_by"
        case createdAt = "created_at"
        case activityType = "activity_type"
        case activityId = "activity_id"
        case totalComment = "total_comment"
        case totalLike = "total_like"
        case user = "user"
    }
    
    var id: Int?
    var title: String?
    var createdBy: Int?
    var createdAt: Double?
    var activityType:  String?
    var postType:  String?
    var activityId: Int?
    var totalComment: Int?
    var totalLike: Int?
    var user: TDUser?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id              <- map[JSONWrapperKey.id.rawValue]
        title           <- map[JSONWrapperKey.title.rawValue]
        createdBy       <- map[JSONWrapperKey.createdBy.rawValue]
        createdAt       <- map[JSONWrapperKey.createdAt.rawValue]
        activityType    <- map[JSONWrapperKey.activityType.rawValue]
        postType        <- map[JSONWrapperKey.postType.rawValue]
        activityId      <- map[JSONWrapperKey.activityId.rawValue]
        totalComment    <- map[JSONWrapperKey.totalComment.rawValue]
        totalLike       <- map[JSONWrapperKey.totalLike.rawValue]
        user            <- map[JSONWrapperKey.user.rawValue]
    }
    
    enum FeedType: String {
        case album = "Album"
        case image = "Image"
        case country = "Country"
        case city = "City"
        case stamp = "Stamp"
    }
    
    class func load(fromJSON JSON: [String: Any]) -> AbstractActivity
    {
        let activityType = JSON["post_type"] as! String
        guard let type = FeedType.init(rawValue: activityType) else {
            assertionFailure("activityType not correct")
            return AbstractActivity()
        }
        
        switch type {
        case .image:
            let instance = Mapper<PictureActivity>().map(JSON: JSON)!
            return instance
        case .city:
            let instance = Mapper<CityActivity>().map(JSON: JSON)!
            return instance
        case .country:
            let instance = Mapper<TripActivity>().map(JSON: JSON)!
            return instance
        case .album:
            let instance = Mapper<AblumActivity>().map(JSON: JSON)!
            return instance
        case .stamp:
            let instance = Mapper<StampActivity>().map(JSON: JSON)!
            return instance
        }
    }
}

class PictureActivity: AbstractActivity {
    
    private enum JSONWrapperKey: String {
        case picture = "obj"
    }
    
    var picture: TDMyPicture!
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        picture      <- map[JSONWrapperKey.picture.rawValue]
    }
}

class CityActivity: AbstractActivity {
    
    private enum JSONWrapperKey: String {
        case city = "obj"
    }
    
    var city: TDTripCity!
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        city      <- map[JSONWrapperKey.city.rawValue]
    }
}

class TripActivity: AbstractActivity {
    
    private enum JSONWrapperKey: String {
        case trip = "obj"
    }
    
    var trip: TDTrip!
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        trip      <- map[JSONWrapperKey.trip.rawValue]
    }
}

class AblumActivity: AbstractActivity {
    
    private enum JSONWrapperKey: String {
        case picture = "obj"
    }
    
    var pictures: [TDMyPicture]!
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        pictures      <- map[JSONWrapperKey.picture.rawValue]
    }
}

class StampActivity: AbstractActivity {
    
    private enum JSONWrapperKey: String {
        case stamp = "obj"
    }
    
    var stamps: [TDStamp]!
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        stamps      <- map[JSONWrapperKey.stamp.rawValue]
    }
}
