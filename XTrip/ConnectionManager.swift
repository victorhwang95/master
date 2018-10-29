//
//  ConnectionManager.swift
//  Vaster
//
//  Created by Khoa Bui on 7/17/17.
//  Copyright © 2017 Elinext. All rights reserved.
//

import Foundation
import Alamofire

let CONNECTION_MANAGER = ConnectionManager.sharedInstance

class ConnectionManager {
    
    // MARK: Shared Instance
    class var sharedInstance: ConnectionManager {
        struct Singleton {
            static let instance = ConnectionManager()
        }
        return Singleton.instance
    }
    
    func isNetworkAvailable(willShowAlertView: Bool = true) -> Bool {
        if let isReachable = Alamofire.NetworkReachabilityManager()?.isReachable,
           isReachable == true {
            return isReachable
        }
        else{
            if willShowAlertView {
                if let vc = UIApplication.shared.keyWindow?.visibleViewController {
                     UIAlertController.show(in: vc, withTitle: "Reminder", message: "Please check your internet connection", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                }
            }
            return false
        }
    }
}
