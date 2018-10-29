//
//  FIRManager.swift
//  XTrip
//
//  Created by Khoa Bui on 10/27/17.
//  Copyright © 2017 Elinext. All rights reserved.
//

import Foundation
import Firebase

let googleService = "GoogleService-Info"

let FIR_MANAGER = FIRManager.sharedInstance

enum FIREvent : String {

    // Events name
    case SIGN_UP_FUNCTION = "sign_up_function"
    case SIGN_IN_FUNCTION = "sign_in_function"
    case SIGN_IN_FB_FUNCTION = "sign_in_fb_function"
    case FORGOT_PASS_FUNCTION = "forgot_pass_function"
    case CREATE_TRIP_FUNCTION = "create_trip_function"
    case EDIT_TRIP_FUNCTION = "edit_trip_function"
    case UPLOAD_PIC_FUNCTION = "upload_pic_function"
    case EDIT_PIC_FUNCTION = "edit_pic_function"
    case LOAD_MY_TRIP_FUNCTION = "load_my_trip_function"
    case LOAD_MY_CITY_TRIP_FUNCTION = "load_my_city_trip_function"
    case LOAD_MY_DETAIL_CITY_TRIP_FUNCTION = "load_my_detail_city_trip_function"
    case LOAD_FRIEND_TRIP_FUNCTION = "load_friend_trip_function"
    case LOAD_FRIEND_CITY_TRIP_FUNCTION = "load_friend_city_trip_function"
    case LOAD_FRIEND_DETAIL_CITY_TRIP_FUNCTION = "load_friend_detail_city_trip_function"
    case LOAD_MY_PIC_FUNCTION = "load_my_pic_function"
    case LOAD_MY_DETAIL_PIC_FUNCTION = "load_my_detail_pic_function"
    case LOAD_FRIEND_PIC_FUNCTION = "load_friend_pic_function"
    case LOAD_FRIEND_DETAIL_PIC_FUNCTION = "load_friend_detail_pic_function"
    case LOAD_NEW_FEED_FUNCTION = "load_new_feed_function"
    case LOAD_MY_PASSPORT_FUNCTION = "load_my_passport_function"
    case POST_MY_PASSPORT_FUNCTION = "post_my_passport_function"
    case LOAD_FRIEND_FUNCTION = "load_friend_function"
    case SYNC_CONTACT_FUNCTION = "sync_contact_function"
    case INVITE_FRIEND_FUNCTION = "invite_friend_function"
    case DELETE_FRIEND_FUNCTION = "delete_friend_function"
    case UPDATE_PROFILE_INFO_FUNCTION = "update_profile_info_function"
    case LIKE_TRIP_FUNCTION = "like_city_trip_function"
    case CMT_TRIP_FUNCTION = "cmt_city_trip_function"
    case LIKE_PIC_FUNCTION = "like_picture_function"
    case CMT_PIC_FUNCTION = "cmt_picture_function"
    case SHARE_TRIP_FUNCTION = "share_trip_function"
    case SHARE_ALBUM_FUNCTION = "share_album_function"
    case SHARE_PIC_FUNCTION = "share_pic_function"
    case SHARE_CITY_TRIP_FUNCTION = "share_city_trip_function"
    case SHARE_STAMP_FUNCTION = "share_stamp_function"
}

class FIRManager {

    // MARK: Shared Instance
    class var sharedInstance: FIRManager {
        struct Singleton {
            static let instance = FIRManager()
        }
        return Singleton.instance
    }
    
    let EventSignUp = AnalyticsEventSignUp
    
    func setupConfig() {
        
        // Use Firebase library to configure APIs
        if let firebaseConfig = Bundle.main.path(forResource: googleService, ofType: "plist") {
            guard let options = FirebaseOptions(contentsOfFile: firebaseConfig) else {
                return
            }
            FirebaseApp.configure(options: options)
        } else {
            
        }
    }
    
    func sendAppEvent(withEvent event: String,
                      userId: String?) {
        
        var analyticsDict = [String : AnyObject]()
        
        if let userId = userId {
            analyticsDict["USER_ID"] = userId as AnyObject?
        }
        
        Analytics.logEvent(event, parameters: analyticsDict)
    }
    
    func setUserProperty(value: String, forName: String) {
        Analytics.setUserProperty(value, forName: forName)
    }
}



