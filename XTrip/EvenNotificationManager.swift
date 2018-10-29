//
//  EvenNotificationManager.swift
//  XTrip
//
//  Created by Khoa Bui on 12/30/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation

protocol EvenNotificationManagerDelegate: class {
    func didGetNewTripPushNotification(count: Int)
    func redirectTripPushToDetailPage()
}

let EVENT_NOTIFICATION_MANAGER = EvenNotificationManager.sharedInstance

class EvenNotificationManager {
    
    weak var delegateMain: EvenNotificationManagerDelegate?
    weak var delegateFriend: EvenNotificationManagerDelegate?
    weak var delegateDash: EvenNotificationManagerDelegate?
    
    var currentTripPushCount: Int = 0
    var currentFriendPushCount: Int = 0
    var isLaunchAppFromTripPushNoti: Bool = false
    
    let group = DispatchGroup()
    
    // MARK: Shared Instance
    class var sharedInstance: EvenNotificationManager {
        struct Singleton {
            static let instance = EvenNotificationManager()
        }
        return Singleton.instance
    }
    
    func updateDeviceToken() {
        // Update device token to Xtrip server
        if let deviceToken = USER_DEFAULT_GET(key: .deviceToken) as? String {
            API_MANAGER.requestUpdateDeviceToken(deviceToken: deviceToken, success: nil, failure: nil)
            USER_DEFAULT_SET(value: true, key: .isUpdatedeviceToken)
        }
    }
    
    func checkTripPushNotificationCount() {
        if self.isLaunchAppFromTripPushNoti {
            self.redirectTripPushToDetailPage()
        } else {
            self.group.enter()
            API_MANAGER.requestGetNotificationCount(success: { (notiCount) in
                self.group.leave()
                self.currentTripPushCount = notiCount
            }) { (errro) in }
            
            self.group.enter()
            API_MANAGER.requestGetFriendNotificationCount(success: { (notiCount) in
                self.group.leave()
                self.currentFriendPushCount = notiCount
            }) { (errro) in }
            
            self.group.notify(queue: DispatchQueue.main) {
                self.delegateMain?.didGetNewTripPushNotification(count: self.currentFriendPushCount + self.currentTripPushCount)
                self.delegateDash?.didGetNewTripPushNotification(count: self.currentFriendPushCount + self.currentTripPushCount)
                self.delegateFriend?.didGetNewTripPushNotification(count: self.currentTripPushCount)
            }
        }
    }
    
    func updateNewPushNotificationCount(notiCount: Int) {
        self.delegateMain?.didGetNewTripPushNotification(count: notiCount)
        self.delegateDash?.didGetNewTripPushNotification(count: notiCount)
        self.delegateFriend?.didGetNewTripPushNotification(count: notiCount)
    }
    
    func redirectTripPushToDetailPage() {
        self.delegateMain?.redirectTripPushToDetailPage()
        self.delegateDash?.redirectTripPushToDetailPage()
        self.delegateFriend?.redirectTripPushToDetailPage()
    }
    
}

