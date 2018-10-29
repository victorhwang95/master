//
//  CountryAnnotation.swift
//  XTrip
//
//  Created by Khoa Bui on 12/16/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import MapKit

class CountryAnnotation: NSObject, MKAnnotation {
    
    var tripId: Int
    var coordinate: CLLocationCoordinate2D
    var countryCode: String?
    var countryName: String?
    var cityId: Int?
    var cityName: String?
    
    
    init(tripId: Int, coordinate: CLLocationCoordinate2D, countryCode: String?, countryName: String?, cityId: Int?, cityName: String?) {
        
        self.tripId = tripId
        self.coordinate = coordinate
        self.countryCode = countryCode
        self.countryName = countryName
        self.cityId = cityId
        self.cityName = cityName
    }
}
