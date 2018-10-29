//
//  Configuration.swift
//  travelDiary
//
//  Created by Hoang Cap on 7/9/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit

private let DEV = "Development";
private let STAG = "Staging";
private let RLS = "Release";

// Current Config, please edit when we have production server

//private let API_ENDPOINTS = [DEV:"https://travel-dev.herokuapp.com",
//                             STAG:"Staging endpoint",
//                             RLS:"Production endpoint"];
//
//private let API_KEY_GGPLACES = [DEV:"AIzaSyC27zAsAlc6YO5kLXf1Nn0PbTReAa9gVjc",
//                             STAG:"##INSERT KEY HERE##",
//                             RLS:"##INSERT KEY HERE##"];
//
//private let GOOGLE_SERVICE_CONFIG_FILE = [DEV:"GoogleService-Info-dev",
//                                STAG:"GoogleService-Info",
//                                RLS:"GoogleService-Info"];

let DEVK = "https://travel-dev.herokuapp.com"

private let API_ENDPOINTS = [DEV:"https://dev.travelx-app.com",
                             STAG:"https://dev.travelx-app.com",
                             RLS:"https://dev.travelx-app.com"];

private let API_KEY_GGPLACES = [DEV:"AIzaSyCyPHW078QRewMjKxgSBPgCf-CooAgOhqA",
                                STAG:"AIzaSyCT-ss1TfNJ0Ua1Unv6Cv-4BRtgIuRa6Jk",
                                RLS:"AIzaSyCT-ss1TfNJ0Ua1Unv6Cv-4BRtgIuRa6Jk"];

private let API_KEY_GMSServices = [DEV:"AIzaSyB7AJt71S7gYtVd3UTY7YutYFUGVE0DQf0",
                                STAG:"AIzaSyB7AJt71S7gYtVd3UTY7YutYFUGVE0DQf0",
                                RLS:"AIzaSyB7AJt71S7gYtVd3UTY7YutYFUGVE0DQf0"];


private let GOOGLE_SERVICE_CONFIG_FILE = [DEV:"GoogleService-Info",
                                          STAG:"GoogleService-Info",
                                          RLS:"GoogleService-Info"];

let CONFIGURATION_CURRENT = TDConfiguration.current;

class TDConfiguration {
    static let current = TDConfiguration();
    
    private let currentEnvironment = Bundle.main.object(forInfoDictionaryKey: "Config") as? String;
    
    var endPointURL: String {
        if let currentEnv = currentEnvironment {
            return API_ENDPOINTS[currentEnv]!;
        }
        
        return API_ENDPOINTS[RLS]!;
    }
    
    var googlePlacesAPIKey: String {
        if let currentEnv = currentEnvironment {
            return API_KEY_GGPLACES[currentEnv]!;
        }
        return API_KEY_GGPLACES[RLS]!;
    }
    
    var googleServiceAPIKey: String {
        if let currentEnv = currentEnvironment {
            return API_KEY_GMSServices[currentEnv]!;
        }
        return API_KEY_GMSServices[RLS]!;
    }
    
    var googlePlacesAPISearchNearLocationUrl: String {
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key="
        if let currentEnv = currentEnvironment {
            return url+API_KEY_GGPLACES[currentEnv]!
        }
        return url+API_KEY_GGPLACES[RLS]!;
    }
    
    var googlePlacesAPISearchLocationByName: String {
        let url = "https://maps.googleapis.com/maps/api/place/textsearch/json?key="
        if let currentEnv = currentEnvironment {
            return url+API_KEY_GGPLACES[currentEnv]!
        }
        return url+API_KEY_GGPLACES[RLS]!;
    }
    
    var googlePlacesAPIGetInfoLocationUrl: String {
        let url = "https://maps.googleapis.com/maps/api/geocode/json?key="
        if let currentEnv = currentEnvironment {
            return url+API_KEY_GGPLACES[currentEnv]!
        }
        return url+API_KEY_GGPLACES[RLS]!;
    }
    
    /// get the corresponding GoogleService configuration file.
    /// The file should be added to project, otherwise app will crash
    var googleServiceConfiguration:String {
        if let curentEnv = currentEnvironment {
            
            if let fileName = GOOGLE_SERVICE_CONFIG_FILE[curentEnv] {
                return Bundle.main.path(forResource: fileName, ofType: "plist")!
            }
        }
        return Bundle.main.path(forResource: API_KEY_GGPLACES[RLS]!, ofType: "plist")!
    }
    
    
    private init() {
        
    }
}

