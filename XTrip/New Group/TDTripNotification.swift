//
//  TDTripNotification.swift
//  XTrip
//
//  Created by Khoa Bui on 1/1/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import Foundation
import ObjectMapper

enum NotificationType: String, CustomStringConvertible {
    
    case trip
    case image
    case city
    case unknown
    
    public var description : String {
        switch self {
        case .trip: return "Trip"
        case .image: return "Image"
        case .city: return "City"
        case .unknown: return "unknown"
        }
    }
}

enum NotificationInviteType: String {
    
    case inviteTrip = "invite_trip"
    case rejectInviteTrip = "reject_invite_trip"
    case acceptTrip = "accept_trip"
    case tripRejected = "trip_rejected"
    case tripAccepted = "trip_accepted"
    case liked = "liked"
    case commented = "commented"
    case viewCity = "city"
}

class TDTripNotification: Mappable {
    
    private enum JSONWrapperKey: String {
        case id = "id"
        case messageId = "message_id"
        case title = "title"
        case responds = "responds"
        case status = "status"
        case modelType = "model_type"
        case notiType = "noti_type"
        case createdAt = "created_at"
        case senderId = "sender_id"
        case isUnread = "is_unread"
        case receiver = "user"
        case sender = "sender"
        case obj = "obj"
    }
    
    var id: String?
    var messageId: String?
    var title: String?
    var modelType: NotificationType?
    var notiType: NotificationInviteType?
    var createdAt: Double?
    var senderId: Int?
    var trip: TDTrip?
    var tripCity: TDTripCity?
    var picture: TDMyPicture?
    var receiver: TDUser?
    var sender: TDUser?
    
    //MARK: Mappable
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id                  <- map[JSONWrapperKey.id.rawValue]
        title               <- map[JSONWrapperKey.title.rawValue]
        messageId           <- map[JSONWrapperKey.messageId.rawValue]
        senderId            <- map[JSONWrapperKey.senderId.rawValue]
        receiver            <- map[JSONWrapperKey.receiver.rawValue]
        sender              <- map[JSONWrapperKey.sender.rawValue]
        trip                <- map[JSONWrapperKey.obj.rawValue]
        tripCity            <- map[JSONWrapperKey.obj.rawValue]
        picture             <- map[JSONWrapperKey.obj.rawValue]
        createdAt           <- map[JSONWrapperKey.createdAt.rawValue]
        
        var notyTypeString: String?
        notyTypeString      <- map[JSONWrapperKey.notiType.rawValue]
        if let notyTypeString = notyTypeString {
            notiType = NotificationInviteType(rawValue: notyTypeString.lowercased())
        }
        
        var modelTypeString: String?
        modelTypeString      <- map[JSONWrapperKey.modelType.rawValue]
        if let modelTypeString = modelTypeString {
            modelType = NotificationType(rawValue: modelTypeString.lowercased())
        }
    }
}
