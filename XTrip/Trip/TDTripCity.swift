//
//  TDTripCity.swift
//  XTrip
//
//  Created by Khoa Bui on 12/17/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation
import ObjectMapper

class TDTripCity: Mappable {
    
    private enum JSONWrapperKey: String {
        case id = "id"
        case name = "name"
        case countryCode = "country"
        case lat = "lat"
        case long = "long"
        case userId = "user_id"
        case startDate = "start_date"
        case endDate = "end_date"
        case createDate = "created_at"
        case tripId = "trip_id"
        case likeCount = "like_num"
        case commentCount = "comment_num"
        case hotelCount = "total_hotel"
        case restaurantCount = "total_restaurant"
        case museumCount = "total_museum"
        case barCount = "total_bar"
        case otherCount = "total_other"
        case poiCount = "total_poi"
        case locations = "locations"
        case comments = "comments"
        case isLiked = "is_liked"
    }
    
    var id: Int?
    var name: String?
    var countryCode: String?
    var lat: String?
    var long: String?
    var userId: Int?
    var startDate: Double?
    var endDate: Double?
    var createDate: Double?
    var tripId: Int?
    var likeCount: Int?
    var commentCount: Int?
    var hotelCount: Int?
    var restaurantCount: Int?
    var barCount: Int?
    var otherCount: Int?
    var poiCount: Int?
    var museumCount: Int?
    var isLiked: Bool = false
    var locations: [TDCityLocation]?
    var comments: [TDCityComment]?
    
    //MARK: Mappable
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id                  <- map[JSONWrapperKey.id.rawValue]
        name                <- map[JSONWrapperKey.name.rawValue]
        countryCode         <- map[JSONWrapperKey.countryCode.rawValue]
        lat                 <- map[JSONWrapperKey.lat.rawValue]
        long                <- map[JSONWrapperKey.long.rawValue]
        startDate           <- map[JSONWrapperKey.startDate.rawValue]
        endDate             <- map[JSONWrapperKey.endDate.rawValue]
        createDate          <- map[JSONWrapperKey.createDate.rawValue]
        tripId              <- map[JSONWrapperKey.tripId.rawValue]
        likeCount           <- map[JSONWrapperKey.likeCount.rawValue]
        commentCount        <- map[JSONWrapperKey.commentCount.rawValue]
        hotelCount          <- map[JSONWrapperKey.hotelCount.rawValue]
        restaurantCount     <- map[JSONWrapperKey.restaurantCount.rawValue]
        museumCount         <- map[JSONWrapperKey.museumCount.rawValue]
        barCount            <- map[JSONWrapperKey.barCount.rawValue]
        otherCount          <- map[JSONWrapperKey.otherCount.rawValue]
        poiCount            <- map[JSONWrapperKey.poiCount.rawValue]
        locations           <- map[JSONWrapperKey.locations.rawValue]
        comments            <- map[JSONWrapperKey.comments.rawValue]
        isLiked             <- map[JSONWrapperKey.isLiked.rawValue]
    }
}

class TDCityLocation: Mappable {
    
    private enum JSONWrapperKey: String {
//        case id = "id"
        case name = "name"
        case type = "type"
        case rate = "rate"
        case lat = "lat"
        case long = "long"
        case startDate = "start_date"
        case endDate = "end_date"
    }
    
//    var id: Int?
    var name: String?
    var type: PlaceType?
    var rate: Double?
    var lat: String?
    var long: String?
    var startDate: Double?
    var endDate: Double?
    
    //MARK: Mappable
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
//        id                  <- map[JSONWrapperKey.id.rawValue]
        name                <- map[JSONWrapperKey.name.rawValue]
        type                <- map[JSONWrapperKey.type.rawValue]
        rate                <- map[JSONWrapperKey.rate.rawValue]
        lat                 <- map[JSONWrapperKey.lat.rawValue]
        long                <- map[JSONWrapperKey.long.rawValue]
        startDate           <- map[JSONWrapperKey.startDate.rawValue]
        endDate             <- map[JSONWrapperKey.endDate.rawValue]
    }
}

class TDCityComment: Mappable {
    
    private enum JSONWrapperKey: String {
        case id = "id"
        case content = "content"
        case userId = "user_id"
        case user = "user"
        case createdAt = "created_at"
    }
    
    var id: Int?
    var content: String?
    var userId: Int?
    var createdAt: Double?
    var user: TDUser?
    
    
    //MARK: Mappable
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id                  <- map[JSONWrapperKey.id.rawValue]
        content             <- map[JSONWrapperKey.content.rawValue]
        userId              <- map[JSONWrapperKey.userId.rawValue]
        createdAt           <- map[JSONWrapperKey.createdAt.rawValue]
        user                <- map[JSONWrapperKey.user.rawValue]
    }
}
