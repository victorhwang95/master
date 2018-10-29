    //
//  LocationManager.swift
//  Vaster
//
//  Created by Khoa Bui on 5/11/17.
//  Copyright © 2017 Elinext. All rights reserved.
//

import Foundation
import CoreLocation

typealias LocationPermissionGrantedClosure = () -> Void
typealias LocationPermissionCancelledClosure = () -> Void
typealias JSONDictionary = [String:Any]

let LOCATION_MANAGER = LocationManager.shared

final class LocationManager: NSObject {
    
    // MARK: Shared Instance
    static let shared = LocationManager()
    var currentDetectLocation: CLLocation!
    var grantedClosure: LocationPermissionGrantedClosure?
    var cancelledClosure: LocationPermissionCancelledClosure?
    
    var authStatus = CLLocationManager.authorizationStatus()
    let inUse = CLAuthorizationStatus.authorizedWhenInUse
    let always = CLAuthorizationStatus.authorizedAlways
    
    // Can't init is singleton
    private override init() {
        lastKnownCoordinate = kCLLocationCoordinate2DInvalid
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    private var locationManager:CLLocationManager!
    var lastKnownCoordinate:CLLocationCoordinate2D?
    
    func isLocationServiceAvailable() -> Bool {
        
        if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways) {
            return true
        }
        return false
    }
    
    /// Request authorization when service not available
    func requestLocationServiceIfNeeded() {
        if !isLocationServiceAvailable() {
            self.locationManager.requestWhenInUseAuthorization()
            
        }
    }
    
    func startLocationService() {
        self.authStatus = CLLocationManager.authorizationStatus()
        self.locationManager.startUpdatingLocation()
    }
    
    func stopLocationService() {
        self.locationManager.stopUpdatingLocation()
    }
    
    func getCurrentUserLocation() -> CLLocationManager{
        return self.locationManager
    }
    
    var currentLocation : CLLocationCoordinate2D? {
        get {
            return self.lastKnownCoordinate
        }
    }
    
    func requestLocationPermission(granted: LocationPermissionGrantedClosure?, cancelled: LocationPermissionCancelledClosure? ) {
        self.grantedClosure = granted
        self.cancelledClosure = cancelled
        
        self.requestLocationServiceIfNeeded()
    }
    
    func getAdress(atLocation: CLLocation? = nil, completion: @escaping (_ address: JSONDictionary?, _ error: TDError?) -> ()) {
        
        if self.authStatus == inUse || self.authStatus == always {
            
            var currentDetectLocation: CLLocation!
            
            if let atLocation = atLocation {
                currentDetectLocation = atLocation
            } else {
                currentDetectLocation = self.locationManager.location
            }
            
            let geoCoder = CLGeocoder()
            
            //TRICK CODE: Deceive GMSGeocoder to use English response by changing value of AppleLanguages to "en_US"
            
            //1. Store the original value of AppleLanguages
            let currentLanguage = UserDefaults.standard.stringArray(forKey: "AppleLanguages")
            
            //2. Set "AppleLanguages" to "en_US" before performing geocoder
            UserDefaults.standard.set(["en_US"], forKey: "AppleLanguages")
            geoCoder.reverseGeocodeLocation(currentDetectLocation) { placemarks, error in
                UserDefaults.standard.set(currentLanguage, forKey: "AppleLanguages")
                
                if let e = error {
                    let error = TDError(e.localizedDescription)
                    print("reverseGeocodeLocation error \(e.localizedDescription)")
                    completion(nil, error)
                    
                } else {
                    let placeArray = placemarks as? [CLPlacemark]
                    
                    var placeMark: CLPlacemark!
                    
                    placeMark = placeArray?[0]
                    print(placeMark)
                    
                    guard let address = placeMark.addressDictionary as? JSONDictionary else {
                        let error = TDError("Please allow Trip to access your location")
                        completion(nil, error)
                        return
                    }
                    
                    completion(address, nil)
                }
            }
        } else {
            let error = TDError("Please allow Trip to access your location")
            completion(nil, error)
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        if let safelocation = location {
            self.lastKnownCoordinate = safelocation.coordinate
            self.grantedClosure?()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways || status == .authorizedWhenInUse) {
            self.startLocationService();
            
        } else if (status == .notDetermined) {//In case of notDetermined -> Just start normally
            self.startLocationService()
            //self.grantedClosure?()
        } else { // Location service disabled -> Display alert
            self.cancelledClosure?()
        }
    }
}

