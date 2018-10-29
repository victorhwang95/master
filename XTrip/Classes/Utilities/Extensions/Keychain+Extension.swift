//
//  Keychain+Extension.swift
//  travelDiary
//
//  Created by Hoang Cap on 8/13/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation
import KeychainAccess

private let KEYCHAIN_SERVICE = "comTravelDiaryToken "
private let KEYCHAIN_ACCESS_TOKEN = "Access-Token"
private let KEYCHAIN_UID = "Uid"
private let KEYCHAIN_CLIENT = "Client"


/// Struct to storing credential data in request header
struct LoginData {
    var token: String!;
    var client: String!;
    var uid: String!;
    
    init?(fromResponse response:HTTPURLResponse) {
        guard let headers = response.allHeaderFields as? [String: String], let token = headers["Access-Token"],
            let client = headers["Client"],
            let uid = headers["Uid"] else {
                log.error("Header doesn't contain login data")
                return nil;
        }
        
        self.token = token;
        self.client = client;
        self.uid = uid;
    }
    
    init(token t:String,client c:String,uid u:String) {
        self.token = t;
        self.client = c;
        self.uid = u;
    }
}

extension Keychain {
    static func save(accessToken token:String, uid:String, client:String) {
        let keychain = Keychain(service: KEYCHAIN_SERVICE);
        
        keychain[KEYCHAIN_ACCESS_TOKEN] = token;
        keychain[KEYCHAIN_CLIENT] = client;
        keychain[KEYCHAIN_UID] = uid;
    }
    
    static func clear() {
        let keychain = Keychain(service: KEYCHAIN_SERVICE);
        keychain[KEYCHAIN_ACCESS_TOKEN] = nil;
        keychain[KEYCHAIN_CLIENT] = nil;
        keychain[KEYCHAIN_UID] = nil;
    }
    
    static func getLogin() -> LoginData? {
        let keychain = Keychain(service: KEYCHAIN_SERVICE);
        if let token = keychain[KEYCHAIN_ACCESS_TOKEN], let client = keychain[KEYCHAIN_CLIENT], let uid = keychain[KEYCHAIN_UID]  {
            let loginData = LoginData.init(token: token, client: client, uid: uid);
            return loginData;
        }
        
        return nil;
        
        
    }
}
