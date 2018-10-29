//
//  SharingManager.swift
//  XTrip
//
//  Created by Than Dang on 1/26/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import Foundation
import Firebase

let domain = "http://dev.travelx-app.com"

class SharingManager {
    static let shared = SharingManager()
    
    func generateDynamicLink(userId: String, completion: @escaping (String) -> ()) {
        guard let link = URL(string: domain + "?user_id=\(userId)") else { return}
        let components = DynamicLinkComponents(link: link, domain: "tc3ad.app.goo.gl")
        let iOSParams = DynamicLinkIOSParameters(bundleID: "com.pjxtrip.iosapp")
        iOSParams.fallbackURL = link
        iOSParams.minimumAppVersion = "1.0"
        iOSParams.customScheme = "travelx"
        iOSParams.appStoreID = "1329860318"
        components.iOSParameters = iOSParams
        
        let options = DynamicLinkComponentsOptions()
        options.pathLength = .unguessable
        components.options = options
        
        components.shorten { (shortURL, warnings, error) in
            // Handle shortURL.
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let resultLink = shortURL?.absoluteString {
                completion(resultLink)
            } else {
                completion("")
            }
        }
    }
}
