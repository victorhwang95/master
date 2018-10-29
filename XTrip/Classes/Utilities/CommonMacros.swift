//
//  File.swift
//  User-iOS
//
//  Created by Hoang Cap on 4/21/17.
//  Copyright © 2017 com.order. All rights reserved.
//

import Foundation
import UIKit

enum VONotificationName: String {
    case pushNotification = "pushNotification"//Currently unused
}

enum VOUserDefaultKeys: String {
    case firstLaunched = "firstLaunched_1.0";//Value = nil means the first app launch
    case deviceToken = "deviceToken_1.0";//Device token for push notification
    case userId = "userId_1.0";
    case userToken = "userToken_1.0";
    case currentUser = "currentUser_1.0";
    case isUpdatedeviceToken = "isUpdatedeviceToken_1.0"
    case referralUserId = "refererUserId_1.0"
}

enum NotificationName {
    static let didCreateTripSuccess = Notification.Name("didCreateTripSuccess")
    static let didUploadPictureSuccess = Notification.Name("didUploadPictureSuccess")
    static let didEditPictureSuccess = Notification.Name("didEditPictureSuccess")
    static let didAcceptTripSuccess = Notification.Name("didAcceptTripSuccess")
    static let viewMyTripSuccess = Notification.Name("viewMyTripSuccess")
}

func LOCALIZE(key: String) -> String {
    return NSLocalizedString(key, comment: "");
}

func USER_DEFAULT_SET(value:Any?,key:VOUserDefaultKeys) {
    UserDefaults.standard.set(value, forKey: key.rawValue);
}

func USER_DEFAULT_SYNC() {
    UserDefaults.standard.synchronize();
}

func USER_DEFAULT_GET(key:VOUserDefaultKeys) -> Any? {
    return UserDefaults.standard.object(forKey: key.rawValue);
}

var SCREEN_SIZE : CGSize {
    get {
        return UIScreen.main.bounds.size
    }
}

/// Get the Main storyboard
///
/// - Returns: Main storyboard

var MAIN_STORYBOARD : UIStoryboard {
    return UIStoryboard(name: "Main", bundle: nil)
}

var MYTRIPS_STORYBOARD : UIStoryboard {
    return UIStoryboard(name: "MyTrips", bundle: nil)
}

var MYPICTURES_STORYBOARD : UIStoryboard {
    return UIStoryboard(name: "MyPictures", bundle: nil)
}


// MARK: - 
func UIImageNamed(_ imageName: String) -> UIImage?{
    return UIImage(named: imageName)
}

//
var PATH_OF_DOCUMENT : String {
    get {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
}

var PATH_OF_TEMP : String {
    return NSTemporaryDirectory()
}

var versionNumber: String {
    get {
        return "Version: \(Bundle.main.buildVersionNumber ?? "")"
    }
}

