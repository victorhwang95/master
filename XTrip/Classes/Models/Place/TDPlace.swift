//
//  TDPlace.swift
//  XTrip
//
//  Created by Khoa Bui on 12/11/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreLocation

enum PlaceType: String, CustomStringConvertible {
    
    case hotel
    case restaurant
    case bar
    case museum
    case other
    case POI
    case unknown
    
    public var description : String {
        switch self {
            case .hotel: return "hotel"
            case .restaurant: return "restaurant"
            case .bar: return "bar"
            case .museum: return "museum"
            case .other: return "other"
            case .POI: return "POI"
            case .unknown: return "unknown"
        }
    }
}

class TDPlace: Mappable {
    
    private enum JSONWrapperKey: String {
        case name = "name"
        case type = "placeType"
        case placeId = "place_id"
    }
    
    var placeId: String!
    var name:String!
    var type: PlaceType! = .other
    var location: CLLocation!
    
    //MARK: Mappable
    required init?(map: Map) {
       
    }
    
    init(name: String, type: PlaceType, placeId: String, lat: Double, lng: Double) {
        self.placeId = placeId
        self.type = type
        self.name = name
        self.location = CLLocation(latitude: lat, longitude: lng)
    }
    
    func mapping(map: Map) {
        placeId     <- map[JSONWrapperKey.placeId.rawValue]
        name        <- map[JSONWrapperKey.name.rawValue]
        
        if let geometry = map.JSON["geometry"] as? [String:Any],
            let location = geometry["location"] as? [String:Any],
            let lat = location["lat"] as? Double,
            let lng = location["lng"] as? Double {
            self.location = CLLocation(latitude: lat, longitude: lng)
        }
    }
}
