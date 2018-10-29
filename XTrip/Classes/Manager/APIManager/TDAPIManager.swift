//
//  File.swift
//  User-iOS
//
//  Created by Hoang Cap on 4/24/17.
//  Copyright © 2017 com.order. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import KeychainAccess
import SideMenu
import SwiftDate
import CoreLocation
import PhoneNumberKit

let API_SERVER_URL = CONFIGURATION_CURRENT.endPointURL;
let API_TRADEMARK = "/api/v1"

private enum APIPath:String {
    case login = "/auth/sign_in"
    case logout = "/auth/sign_out"
    case register = "/auth"
    case verify = "/users/verify_register"
    case syncContacts = "/users/get_user_by_contact"
    case syncContacts2 = "/contacts/syn_user_by_contact"
    case friendList = "/users/friend_list"
    case friendRequest = "/users/friends_request";
    case acceptFriendRequest = "/users/accept_friend";
    case ignoreFriendRequest = "/users/ignore_friend";
    
    
    case deleteFriend = "/users/delete_friend"
    case updateDeviceToken = "/users/update_device_token"
    case updateBadge = "/users/update_badge"
    case loginWithFacebook = "/auth/facebook/callback"
    case updateProfile = "/users/update_profile"
    case trips = "/trips"
    case cities = "/cities"
    case tripImages = "/trip_images"
    case friendTrip = "/trips/list_trip_of_friend"
    case notification = "/notifications"
    case clearNotification = "/notifications/clear_notification"
    case updateReadAll = "/notifications/update_read_all"
    case updateFriendReadAll = "/notifications/update_read_all_friend_noti"
    case countNotification = "/notifications/count_notification"
    case countFriendNotification = "/notifications/count_friend_noti"
    case countriesOfMyTrip = "/countries/list_by_my_trip"
    case countriesOfFriendTrip = "/countries/list_by_trip_friend"
    case listByTripOfUser = "/countries/list_by_trip_of_user"
    case listCountryOfUser = "/countries/list_country_of_user"
    case activities = "/activities"
    case invites = "/invites"
    case syncFacebookFriends = "/users/get_user_by_fb"
    case stamps = "/stamps"
    case users = "/users"
    case pass = "/auth/password"
    case checkCode = "/passwords/check_code"
    
    var fullUrl: String {
        return "\(API_SERVER_URL)\(self.fullPath())";
    }
    
    private func fullPath() -> String {
        return "\(API_TRADEMARK)\(self.rawValue)";
    }
}

let API_MANAGER = TDAPIManager.sharedInstance;

typealias SuccessHandler = ((_ responseObject: Any?) -> Void)?
typealias FailureHandler = ((_ error: TDError) -> Void)?

let errorStatus: Int = 0
let successStatus: Int = 1

class TDAPIManager {
    static let sharedInstance = TDAPIManager(); //Swift standard Singleton
    
    //    fileprivate let authorizationAPIPath:[APIPath] = [.login, .register, .loginWithFacebook];//List of APIs that are used for authentication, for those APIs, credential (token, client, uid) must be saved to keychain
    
    private init() {
    }
    
    // MARK: - Login
    func requestLogin(email:String, password:String, success: ((TDUser) -> ())?,andFailure failure: FailureHandler) {
        let params = ["email":email,
                      "password":password];
        
        self.requestPOST(APIPath.login.fullUrl, authenticated: false, parameters: params, success: { (dict, response) in
            
            guard let data = dict["data"] as? [String:Any],
                let user = TDUser.init(JSON: data),
                self.saveLoginData(fromResponse: response) else {
                    failure?(TDError.init("The data received from server is not valid"));
                    return;
            }
            success?(user);
        }) { (error) in
            failure?(error);
        }
    }
    
    // MARK: - Logout
    func requestLogout(success: (() -> Void)?,
                       andFailure failure: FailureHandler) {
        var params:[String: Any] = [:]
        if let deviceToken = USER_DEFAULT_GET(key: .deviceToken) as? String {
            params["device_token"] = deviceToken
        }
        self.requestDELETE(APIPath.logout.fullUrl, authenticated: true, parameters: params, success: { (dict, response) in
            Keychain.clear()
            success?()
        }) { (error) in
            failure?(error);
        }
    }
    
    // MARK: - Register
    func requestRegister(email: String, name: String, password: String, passwordComfirmation: String, country: String, success:((TDUser) -> Void)?,failure: FailureHandler) {
        
        var params = ["email":email,
                      "name":name,
                      "password":password,
                      "password_confirmation":passwordComfirmation,
                      "country":country,
                      "platform":"ios",
                      ]
        
        if let token = USER_DEFAULT_GET(key: .userToken) as? String {
            params["device_token"] = token;
        }
        
        //Include referral's id if avaialbles
        if let referralId = USER_DEFAULT_GET(key: .referralUserId) as? String {
            params["user_id"] = referralId;
        }
        
        self.requestPOST(APIPath.register.fullUrl, authenticated: false, parameters: params, success: { (responseDict, response) in
            
            if self.saveLoginData(fromResponse: response) {
                if let user = TDUser(JSON: responseDict) {
                    USER_DEFAULT_SET(value: nil, key: .referralUserId);//After registering succesfully, remove the referral id.
                    success?(user);
                } else {
                    failure?(TDError.init("The data received from server is corrupted - User data are missing"));
                }
            } else {
                failure?(TDError.init("The data received from server is corrupted - Header values are missing"));
            }
            
        }) { (error) in
            
            failure?(error);
        }
    }
    
    // MARK: - Update profile
    func requestUpdateProfile(email: String?,
                              name: String?,
                              password: String?,
                              passwordComfirmation: String?,
                              contact: String?,
                              country: String?,
                              fbId: String?,
                              allowNotification: Bool?,
                              allowTagMe: Bool?,
                              receiveMessage: Bool?,
                              profilePicture: UIImage?,
                              coverPicture: UIImage?,
                              success:((TDUser) -> Void)?,
                              failure: FailureHandler) {
        
        var params = [String:Any]();
        
        if let email = email {
            params["email"] = email;
        }
        
        if let name = name {
            params["name"] = name;
        }
        
        if let password = password {
            params["password"] = password;
        }
        
        if let passwordComfirmation = passwordComfirmation {
            params["password_confirmation"] = passwordComfirmation;
        }
        
        if let contact = contact {
            params["contact"] = contact;
        }
        
        if let country = country {
            params["country"] = country;
        }
        
        if let fbId = fbId {
            params["fb_Id"] = fbId;
        }
        
        if let allowNotification = allowNotification {
            params["allow_notification"] = allowNotification;
        }
        
        if let allowTagMe = allowTagMe {
            params["allow_tag_me"] = allowTagMe;
        }
        
        if let receiveMessage = receiveMessage {
            params["receive_message"] = receiveMessage;
        }
        
        if let profilePicture = profilePicture {
            params["profile_picture"] = profilePicture;
        }
        
        if let coverPicture = coverPicture {
            params["cover_picture"] = coverPicture;
        }
        
        self.requestPATCH(APIPath.updateProfile.fullUrl, selectedCoverImage: coverPicture, selectedProfileImage: profilePicture, parameters: params, success: { (responseDict, response) in
            log.info("Response dict: \(responseDict)");
            
            if let userDict = responseDict["user"] as? [String: Any],
                let user = TDUser(JSON: userDict) {
                success?(user)
            } else {
                log.error(TDError("Server response is corrupted"));
            }
            
            
        }) { (error) in
            failure?(error);
        }
    }
    
    
    /// login with Facebook
    ///
    /// - Parameters:
    ///   - accessToken: fb Access token
    ///   - expireIn: expire date of token (in unix time)
    ///   - countryCode: country code of the user
    ///   - success: success handler
    ///   - failure: failure handler
    func requestLoginWithFacebook(accessToken:String, expireIn:TimeInterval, countryCode: String? = nil, success:((TDUser) -> Void)? ,failure: FailureHandler) {
        var params = ["access_token":accessToken,
                      "expires_in":expireIn,
                      "platform":"ios"
            ] as [String : Any];
        
        if let countryCode = countryCode {
            params["country"] = countryCode;
        }
        
        if let token = USER_DEFAULT_GET(key: .deviceToken) {
            params["device_token"] = token;
        }
        
        //Include referral's id if avaialbles
        if let referralId = USER_DEFAULT_GET(key: .referralUserId) as? String {
            params["user_id"] = referralId;
        }
        
        //Call API loginWithFacebook, ignoring authentication header
        self.requestGET(APIPath.loginWithFacebook.fullUrl, authenticated: false, parameters: params, success: { (responseDict, response) in
            
            log.debug("Logged with facebook: \(responseDict)");
            
            
            if self.saveLoginData(fromResponse: response),
                let userDict = responseDict["user"] as? [String: Any],
                let user = TDUser(JSON: userDict) {
                USER_DEFAULT_SET(value: nil, key: .referralUserId);//Remove referral id after login successfully.
                success?(user);
            } else {
                log.error(TDError("Server response is corrupted"));
                failure?(TDError.init("The data received from server is corrupted - Header values are missing"));
            }
            
        }) { (error) in
            failure?(error);
        }
    }
    
    func requestAccountVerification(verificationCode:String, success:(() -> Void)? ,failure: FailureHandler) {
        let params = ["verification_code":verificationCode]
        
        self.requestPOST(APIPath.verify.fullUrl, authenticated: true, parameters: params, success: { (dict, response) in
            success?();
        }) { (error) in
            print("Error \(error.message)");
            failure?(error);
        }
    }
    
    func requestCreateTrip(tripName: String,
                           description: String,
                           startDate: Date,
                           endDate: Date,
                           countryCodes: [String],
                           friendId: [String],
                           success: ((_ tripData: TDTrip) -> Void)?,
                           failure: FailureHandler) {
        
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd";
        
        //let startDateInterval = Int(startDate.startOfDay.timeIntervalSince1970);
        //let endDateInterval = Int(endDate.startOfDay.timeIntervalSince1970);
        
        
        let countryCodesString: String = {
            var result = ""
            countryCodes.forEach({ (code) in
                result.append(code);
                if (code != countryCodes.last!) {
                    result.append(",");
                }
            })
            return result;
        }()
        
        let friendIdString: String = {
            var result = ""
            friendId.forEach({ (id) in
                result.append(id);
                if (id != countryCodes.last!) {
                    result.append(",");
                }
            })
            return result;
        }()
        
        let params: [String: Any] = ["name": tripName,
                                     "description": description,
                                     "start_date":Date(),
                                     "end_date":Date(),
                                     "trip_schedule": countryCodesString,
                                     "user_in_strip_ids" : friendIdString
        ]
        //print(params)
        
        self.requestPOST(APIPath.trips.fullUrl, authenticated: true, parameters: params, success: { (dict, response) in
            if let result = dict["data"] as? [String:Any] {
                if let trip = Mapper<TDTrip>().map(JSON: result) {
                    success?(trip)
                    return
                }
            }
            let error = TDError("Could not load data from server")
            failure?(error)
        }) { (error) in
            failure?(error);
        }
    }
    
    // MARK: - Get Trip list
    /**
     Default isfriendTrip = false
     @param userId
     - success: callback success BasicEntity
     - failure: callback when something error
     - returns: Void
     */
    
    func requestGetTripList(isfriendTrip: Bool = false ,
                            page: Int?,
                            perPage: Int?,
                            showImage: Int?,
                            country: String?,
                            time: String?,
                            friendId: String?,
                            userId: String?,
                            success: ((_ baseData: BasicEntity) -> Void)?,
                            failure: FailureHandler) {
        
        var friendTripURL = APIPath.friendTrip.fullUrl
        var myTripURL = APIPath.trips.fullUrl
        
        if let page = page,
            let perPage = perPage,
            let showImage = showImage {
            if isfriendTrip {
                friendTripURL += "?page=\(page)&per_page=\(perPage)&show_image=\(showImage)"
            } else {
                myTripURL += "?page=\(page)&per_page=\(perPage)&show_image=\(showImage)"
            }
        }
        
        if let country = country {
            if isfriendTrip {
                friendTripURL += "&country=\(country)"
            } else {
                myTripURL += "&country=\(country)"
            }
        }
        
        if let time = time {
            myTripURL += "&time=\(time)"
        }
        
        if let friendId = friendId {
            friendTripURL += "&friend_id=\(friendId)"
        }
        
        if let userId = userId {
            friendTripURL += "&user_id=\(userId)"
        }
        
        let fullURL = isfriendTrip ? friendTripURL : myTripURL
        
        self.requestGET(fullURL, authenticated: true, parameters: nil, success: { (dict, response) in
            if let result = dict["data"] as? [String:Any] {
                if let baseData = Mapper<BasicEntity>().map(JSON: result) {
                    success?(baseData)
                    return
                }
            }
            let error = TDError("Could not load data from server")
            failure?(error)
        }) { (error) in
            failure?(error);
        }
    }
    
    // MARK: - Get Trip by trip id
    /**
     @param userId
     - success: callback success TDTrip
     - failure: callback when something error
     - returns: Void
     */
    
    func requestGetTripById(tripId: Int,
                            success: ((_ baseData: TDTrip) -> Void)?,
                            failure: FailureHandler) {
        
        let fullURL = APIPath.trips.fullUrl + "/\(tripId).json"
        
        self.requestGET(fullURL, authenticated: true, parameters: nil, success: { (dict, response) in
            //            log.info("Response dict: \(dict)");
            if let result = dict["data"] as? [String:Any] {
                if let trip = Mapper<TDTrip>().map(JSON: result) {
                    success?(trip)
                    return
                }
            }
            let error = TDError("Could not load data from server")
            failure?(error)
        }) { (error) in
            failure?(error);
        }
    }
    
    // MARK: - Patch Trip
    /**
     @param tripId
     @param countryCodes
     - success: callback success BasicEntity
     - failure: callback when something error
     - returns: Void
     */
    
    func requestUpdateTrip(tripId: Int,
                           tripName: String,
                           description: String,
                           startDate: Date,
                           endDate: Date,
                           countryCodes: [String],
                           friendId: [String],
                           success: ((_ baseData: TDTrip) -> Void)?,
                           failure: FailureHandler) {
        
        let fullURL = APIPath.trips.fullUrl + "/\(tripId).json"
        //        log.debug(fullURL)
        
        let friendIdString: String = {
            var result = ""
            friendId.forEach({ (id) in
                result.append(id);
                if (id != countryCodes.last!) {
                    result.append(",");
                }
            })
            return result;
        }()
        
        let params = ["id" : tripId,
                      "trip_schedule": countryCodes,
                      "user_in_strip_ids" : friendIdString,
                      "name": tripName,
                      "description": description,
                      "start_date":startDate.timeIntervalSince1970,
                      "end_date":endDate.timeIntervalSince1970
            ] as [String : Any]
        
        self.requestPATCH(fullURL, authenticated: true, parameters: params, success: { (dict, response) in
            if let result = dict["data"] as? [String:Any] {
                if let trip = Mapper<TDTrip>().map(JSON: result) {
                    success?(trip)
                    return
                }
            }
            let error = TDError("Could not load data from server")
            failure?(error)
        }) { (error) in
            failure?(error);
        }
    }
    
    // MARK: - search Place Infomation
    /**
     Default radius = 5000
     @param longitude, latitude, radius, type
     - success: callback success TDPlace array, PlaceType
     - failure: callback when something error
     - returns: Void
     */
    
    func requestSearchPlaceInfoByName(longitude: Double,
                                      latitude: Double,
                                      radius: Double = 5000,
                                      type: PlaceType,
                                      keyword: String,
                                      success: ((_ channelInfo: [TDPlace], _ placeType: PlaceType) -> Void)?,
                                      failure: FailureHandler) {
        let keywordEscaped = keyword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let fullURL = CONFIGURATION_CURRENT.googlePlacesAPISearchLocationByName + "&location=\(latitude),\(longitude)" + "&radius=\(radius)" + "&type=\(type)&query=\(keywordEscaped)"
        log.debug("fullURL \(fullURL)")
        
        self.requestGET(fullURL, authenticated: false, parameters: nil, success: { (dict, response) in
            log.debug("got the data")
            var tdPlaces: [TDPlace] = []
            if let results = dict["results"] as? [[String:Any]] {
                for result in results {
                    if let tdPlace = Mapper<TDPlace>().map(JSON: result) {
                        tdPlace.type = type
                        tdPlaces.append(tdPlace)
                    }
                }
            }
            tdPlaces.sort(by: { (p1, p2) -> Bool in
                let location = CLLocation(latitude: latitude, longitude: longitude)
                let distance1 = location.distance(from: p1.location)
                let distance2 = location.distance(from: p2.location)
                return distance1 < distance2
            })
            success?(tdPlaces, type)
        }) { (error) in
            failure?(error)
        }
    }
    // MARK: - Get Get Place Infomation By Location
    /**
     Default radius = 5000
     @param longitude, latitude, radius, type
     - success: callback success TDPlace array, PlaceType
     - failure: callback when something error
     - returns: Void
     */
    
    func requestGetPlaceInfolistNearMeByLocation(longitude: Double,
                                                 latitude: Double,
                                                 radius: Double = 5000,
                                                 type: PlaceType,
                                                 success: ((_ channelInfo: [TDPlace], _ placeType: PlaceType) -> Void)?,
                                                 failure: FailureHandler) {
        var fullURL = ""
        if type == .POI {
            fullURL = CONFIGURATION_CURRENT.googlePlacesAPISearchNearLocationUrl + "&location=\(latitude),\(longitude)" + "&radius=\(radius)" + "&type=point_of_interest"
        } else if type == .other {
            fullURL = CONFIGURATION_CURRENT.googlePlacesAPISearchNearLocationUrl + "&location=\(latitude),\(longitude)" + "&radius=\(radius)"
        } else {
            fullURL = CONFIGURATION_CURRENT.googlePlacesAPISearchNearLocationUrl + "&location=\(latitude),\(longitude)" + "&radius=\(radius)" + "&type=\(type)"
        }
        log.debug(fullURL)
        
        self.requestGET(fullURL, authenticated: false, parameters: nil, success: { (dict, response) in
            var tdPlaces: [TDPlace] = []
            if let results = dict["results"] as? [[String:Any]] {
                for result in results {
                    if let tdPlace = Mapper<TDPlace>().map(JSON: result) {
                        tdPlace.type = type
                        tdPlaces.append(tdPlace)
                    }
                }
            }
            tdPlaces.sort(by: { (p1, p2) -> Bool in
                let location = CLLocation(latitude: latitude, longitude: longitude)
                let distance1 = location.distance(from: p1.location)
                let distance2 = location.distance(from: p2.location)
                return distance1 < distance2
            })
            success?(tdPlaces, type)
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - Get Post Upload Trip Images
    /**
     Default
     @param tripId, country, longitude, latitude, createdDate, caption, itemType, itemName, selectedImages
     - success: callback success TDPlace array
     - failure: callback when something error
     - returns: Void
     */
    
    func requestUploadTripImages(tripId: Int,
                                 country: String,
                                 city: String,
                                 longitude: Double,
                                 latitude: Double,
                                 createdDate: Date,
                                 caption: String?,
                                 itemType: String,
                                 itemId: String,
                                 itemName: String,
                                 selectedImage: UIImage,
                                 countryName: String?,
                                 success: (() -> Void)?,
                                 failure: FailureHandler) {
        let createdDatetring = Int(createdDate.timeIntervalSince1970)
        
        let fullURL = API_SERVER_URL+API_TRADEMARK+"/trips/\(tripId)/trip_images"
        
        var params = ["city": city,
                      "lat": latitude,
                      "long": longitude,
                      "uploaded_at":createdDatetring,
                      "caption": caption ?? "",
                      "item_type": itemType,
                      "item_id" : itemId,
                      "item_name": itemName] as [String : Any]
        
        if let countryName = countryName {
            params["country_name"] = countryName
        } else {
            params["country"] = country
        }
        
        self.requestPOST(fullURL, selectedImage: selectedImage, authenticated: true, parameters: params, success: { (dict, response) in
            success?()
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - Get Trip List Image
    /**
     Default
     @param tripId
     - success: callback success BasicEntity
     - failure: callback when something error
     - returns: Void
     */
    
    func requestGetTripListImage(tripId: Int,
                                 page: Int?,
                                 perPage: Int?,
                                 success: ((_ baseData: BasicEntity) -> Void)?,
                                 failure: FailureHandler) {
        var fullURL = APIPath.trips.fullUrl+"/\(tripId)/list_image"
        
        if let page = page,
            let perPage = perPage {
            fullURL += "?page=\(page)&per_page=\(perPage)"
        }
        
        self.requestGET(fullURL, authenticated: true, parameters: nil, success: { (dict, response) in
            if let result = dict["data"] as? [String:Any] {
                if let baseData = Mapper<BasicEntity>().map(JSON: result) {
                    success?(baseData)
                    return
                }
            }
            let error = TDError("Could not load data from server")
            failure?(error)
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - Get picture detail
    /**
     Default
     @param pictureId
     - success: callback success BasicEntity
     - failure: callback when something error
     - returns: Void
     */
    
    func requestGetPictureDetail(pictureId: Int,
                                 success: ((_ pictureData: TDMyPicture) -> Void)?,
                                 failure: FailureHandler) {
        
        let fullURL = APIPath.tripImages.fullUrl+"/\(pictureId)"
        
        self.requestGET(fullURL, authenticated: true, parameters: nil, success: { (dict, response) in
            if let result = dict["data"] as? [String:Any] {
                if let pictureData = Mapper<TDMyPicture>().map(JSON: result) {
                    success?(pictureData)
                    return
                }
            }
            let error = TDError("Could not load data from server")
            failure?(error)
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - Get Trip list detail by country code
    /**
     Default
     @param tripId, countryCode
     - success: callback success TDTripCity array
     - failure: callback when something error
     - returns: Void
     */
    
    func requestGetTripListByCountry(tripId: Int,
                                     countryCode: String,
                                     success: ((_ tdTripCityArray: [TDTripCity]) -> Void)?,
                                     failure: FailureHandler) {
        
        let fullURL = APIPath.trips.fullUrl+"/\(tripId)/list_detail_by_country"
        
        let params = ["country": countryCode]
        
        self.requestGET(fullURL, authenticated: true, parameters: params, success: { (dict, response) in
            var tdTripCities: [TDTripCity] = []
            if let results = dict["data"] as? [[String:Any]] {
                let tdTripCityArray = Mapper<TDTripCity>().mapArray(JSONArray: results)
                if tdTripCityArray.count>0 {
                    tdTripCities = tdTripCityArray
                }
            }
            success?(tdTripCities)
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - Get Trip list detail by city id
    /**
     Default
     @param cityId
     - success: callback success TDTripCity
     - failure: callback when something error
     - returns: Void
     */
    
    func requestGetTripListByCity(cityId: Int,
                                  success: ((_ tdTripCity: TDTripCity?) -> Void)?,
                                  failure: FailureHandler) {
        
        let fullURL = APIPath.cities.fullUrl+"/\(cityId)/"
        
        self.requestGET(fullURL, authenticated: true, parameters: nil, success: { (dict, response) in
            if let result = dict["data"] as? [String:Any] {
                if let tdTripCity = Mapper<TDTripCity>().map(JSON: result) {
                    success?(tdTripCity)
                    return
                }
            }
            let error = TDError("Could not load data from server")
            failure?(error)
        }) { (error) in
            failure?(error)
        }
    }
    
    
    // MARK: - delete trip
    /**
     Default
     @param tripId
     - success: callback success
     - failure: callback when something error
     - returns: Void
     */
    
    func requesDeleteTrip(tripId: Int,
                          success: (() -> Void)?,
                          failure: FailureHandler) {
        
        let fullURL = APIPath.trips.fullUrl+"/\(tripId)"
        
        self.requestDELETE(fullURL, authenticated: true, parameters: nil, success: { (dict, response) in
            success?()
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - delete city trip
    /**
     Default
     @param cityId
     - success: callback success
     - failure: callback when something error
     - returns: Void
     */
    
    func requesDeleteCityTrip(cityId: Int,
                              success: (() -> Void)?,
                              failure: FailureHandler) {
        
        let fullURL = APIPath.cities.fullUrl+"/\(cityId)"
        
        self.requestDELETE(fullURL, authenticated: true, parameters: nil, success: { (dict, response) in
            success?()
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - Post Comment On City Trip
    /**
     Default
     @param cityId, userId, content
     - success: callback success
     - failure: callback when something error
     - returns: Void
     */
    
    func requestPostCommentOnCityTrip(cityId: Int,
                                      userId: Int,
                                      content: String,
                                      success: (() -> Void)?,
                                      failure: FailureHandler) {
        
        let fullURL = APIPath.cities.fullUrl+"/\(cityId)/add_comment"
        
        let params = ["user_id": userId,
                      "content": content] as [String : Any]
        
        self.requestPOST(fullURL, authenticated: true, parameters: params, success: { (dict, response) in
            success?()
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - Post Comment On Trip Picture
    /**
     Default
     @param pictureId, userId, content
     - success: callback success
     - failure: callback when something error
     - returns: Void
     */
    
    func requestPostCommentOnTripPicture(pictureId: Int,
                                         userId: Int,
                                         content: String,
                                         success: (() -> Void)?,
                                         failure: FailureHandler) {
        
        let fullURL = APIPath.tripImages.fullUrl+"/\(pictureId)/add_comment"
        
        let params = ["user_id": userId,
                      "content": content] as [String : Any]
        
        self.requestPOST(fullURL, authenticated: true, parameters: params, success: { (dict, response) in
            success?()
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - Like trip On City
    /**
     Default
     @param cityId, userId
     - success: callback success
     - failure: callback when something error
     - returns: Void
     */
    
    func requestLikeCityTrip(cityId: Int,
                             behavior: String = "like",
                             success: ((_ cityData: TDTripCity) -> Void)?,
                             failure: FailureHandler) {
        
        let fullURL = APIPath.cities.fullUrl+"/\(cityId)/user_like"
        let parameters = ["behavior" : behavior]
        self.requestPOST(fullURL, authenticated: true, parameters: parameters, success: { (dict, response) in
            if let result = dict["data"] as? [String:Any] {
                if let cityData = Mapper<TDTripCity>().map(JSON: result) {
                    success?(cityData)
                    return
                }
            }
            let error = TDError("Could not load data from server")
            failure?(error)
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - Like picture on trip
    /**
     Default
     @param pictureId, userId
     - success: callback success
     - failure: callback when something error
     - returns: Void
     */
    
    func requestLikeTripPicture(pictureId: Int,
                                behavior: String = "like",
                                success: ((_ pictureData: TDMyPicture) -> Void)?,
                                failure: FailureHandler) {
        
        let fullURL = APIPath.tripImages.fullUrl+"/\(pictureId)/user_like"
        let parameters = ["behavior" : behavior]
        self.requestPOST(fullURL, authenticated: true, parameters: parameters, success: { (dict, response) in
            if let result = dict["data"] as? [String:Any] {
                if let pictureData = Mapper<TDMyPicture>().map(JSON: result) {
                    success?(pictureData)
                    return
                }
            }
            let error = TDError("Could not load data from server")
            failure?(error)
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - delete trip picture
    /**
     Default
     @param imageId
     - success: callback success
     - failure: callback when something error
     - returns: Void
     */
    
    func requesDeleteTripPicture(pictureId: Int,
                                 success: (() -> Void)?,
                                 failure: FailureHandler) {
        
        let fullURL = APIPath.tripImages.fullUrl+"/\(pictureId)"
        
        self.requestDELETE(fullURL, authenticated: true, parameters: nil, success: { (dict, response) in
            success?()
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - Get Update Trip Images
    /**
     Default
     @param imageId, country, longitude, latitude, createdDate, caption, itemType, itemName
     - success: callback success MyPicture
     - failure: callback when something error
     - returns: Void
     */
    
    func requestEditTripImages(imageId: Int,
                               tripId: Int,
                               country: String,
                               city: String,
                               longitude: Double,
                               latitude: Double,
                               uploadedAt: Date,
                               caption: String?,
                               itemType: String,
                               itemId: String,
                               itemName: String,
                               countryName: String?,
                               success: ((_ pictureData: TDMyPicture) -> Void)?,
                               failure: FailureHandler) {
        
        let uploadedAtInt = Int(uploadedAt.timeIntervalSince1970)
        
        let fullURL = APIPath.tripImages.fullUrl+"/\(imageId)"
        
        var params = ["trip_id" : tripId,
                      "city": city,
                      "lat": latitude,
                      "long": longitude,
                      "uploaded_at":uploadedAtInt,
                      "caption": caption ?? "",
                      "item_type": itemType,
                      "item_id" : itemId,
                      "item_name": itemName] as [String : Any]
        
        if let countryName = countryName {
            params["country_name"] = countryName
        } else {
            params["country"] = country
        }
        
        self.requestPATCH(fullURL, selectedImage: nil, authenticated: true, parameters: params, success: { (dict, response) in
            if let result = dict["data"] as? [String:Any] {
                if let pictureData = Mapper<TDMyPicture>().map(JSON: result) {
                    success?(pictureData)
                    return
                }
            }
            let error = TDError("Could not load data from server")
            failure?(error)
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - Sync contacts
    /**
     Default
     @param contact PhoneContact array
     - success: callback success
     - failure: callback when something error
     - returns: Void
     */
    
    func requestSyncContacts( contacts : [PhoneContact],
                              success: (([AppContact]?) -> Void)?,
                              failure: FailureHandler) {
        
        //        let tempContactsArray = NSMutableArray()
        var contactArray = [String]()
        for contact in contacts {
            contactArray = contactArray + contact.contactPhoneNum;
        }
        
        let params = ["contacts": contactArray] as [String : Any]
        
        self.requestPOST(APIPath.syncContacts.fullUrl, selectedImage: nil, authenticated: true, parameters: params, success: { (dict, response) in
            
            guard let data = dict["data"] as? [[String:Any]] else {
                failure?(TDError.init("The data received from server is not valid"));
                return;
            }
            
            let users = Mapper<AppContact>().mapArray(JSONArray: data)
            
            print(dict);
            success?(users)
        }) { (error) in
            failure?(error)
        }
    }
    
    func requestSyncContacts2(contacts : [PhoneContact],
                              success: (([AppContact], [AppContact]) -> Void)?,
                              failure: FailureHandler) {
        
        //        let tempContactsArray = NSMutableArray()
        var contactArray = [String]()
        for contact in contacts {
            contactArray = contactArray + contact.contactPhoneNum;
        }
        
        var emailArray = [String]()
        for contact in contacts {
            if let emails = contact.contactEmail {
                emailArray = emailArray + emails;
                
            }
        }
        
        let params = ["contacts": contactArray, "emails":emailArray] as [String : Any]
        
        self.requestPOST(APIPath.syncContacts2.fullUrl, selectedImage: nil, authenticated: true, parameters: params, success: { (dict, response) in
            
            guard let data = dict["data"] as? [String:Any],
                let newFriendsDict = data["new_friends"] as? [[String: Any]],
                let requestedFriendsDict = data["request_friends"] as? [[String: Any]]
                else {
                    failure?(TDError.init("The data received from server is not valid"));
                    return;
            }
            let newFriends:[AppContact] = {
                let contacts = Mapper<AppContact>().mapArray(JSONArray: newFriendsDict)
                if contacts.count>0 {
                    return contacts;
                }
                return [];
            }()
            
            let requestedFriends:[AppContact] = {
                let contacts = Mapper<AppContact>().mapArray(JSONArray: requestedFriendsDict)
                if contacts.count>0 {
                    return contacts;
                }
                return [];
            }()
            
            print(dict);
            success?(newFriends, requestedFriends);
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - Get friends from Facebook
    /**
     Default
     @param ids List of friends' facebook IDs
     - success: callback success
     - failure: callback when something error
     - returns: Void
     */
    
    func requestAddFacebookFriends(ids : [String],
                                   success: (([AppContact]) -> Void)?,
                                   failure: FailureHandler) {
        
        //
        //        let idsString: String = {
        //            var result = ""
        //            ids.forEach({ (id) in
        //                result.append(id);
        //                if (id != ids.last!) {
        //                    result.append(",");
        //                }
        //            })
        //            return result;
        //        }()
        
        let params = ["fb_ids": ids];
        
        self.requestPOST(APIPath.syncFacebookFriends.fullUrl, selectedImage: nil, authenticated: true, parameters: params, success: { (dict, response) in
            
            guard let data = dict["data"] as? [[String:Any]] else {
                failure?(TDError.init("The data received from server is not valid"));
                return;
            }
            let users = Mapper<AppContact>().mapArray(JSONArray: data)
            if (users.count>0) {
                success?(users)
            } else {
                success?([]);
            }
            
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - get Friend List
    /**
     Default
     @param contact number array
     - success: callback success AppContact list
     - failure: callback when something error
     - returns: Void
     */
    
    func requestGetFriendList(success: ((_ tdTripCity: [AppContact]) -> Void)?,
                              failure: FailureHandler) {
        self.requestGET(APIPath.friendList.fullUrl, selectedImage: nil, authenticated: true, parameters: nil, success: { (dict, response) in
            var appContactList: [AppContact] = []
            if let results = dict["data"] as? [[String:Any]] {
                let appContactArray = Mapper<AppContact>().mapArray(JSONArray: results)
                if appContactArray.count > 0 {
                    appContactList = appContactArray
                }
            }
            success?(appContactList)
        }) { (error) in
            failure?(error)
        }
    }
    
    func requestGetFriendRequests(success: ((_ requesterId: [AppContact]) -> Void)?,
                                  failure: FailureHandler) {
        self.requestGET(APIPath.friendRequest.fullUrl, selectedImage: nil, authenticated: true, parameters: nil, success: { (dict, response) in
            
            var appContactList: [AppContact] = []
            if let results = dict["data"] as? [[String:Any]] {
                let appContactArray = Mapper<AppContact>().mapArray(JSONArray: results)
                if appContactArray.count > 0 {
                    appContactList = appContactArray
                }
            }
            success?(appContactList);
        }) { (error) in
            failure?(error)
        }
    }
    
    func requestAcceptFriendRequest(friendId: Int,
                                    success: (() -> Void)?,
                                    failure: FailureHandler) {
        
        let params = ["user_id": friendId]
        let fullURL = APIPath.acceptFriendRequest.fullUrl;
        
        self.requestPOST(fullURL, selectedImage: nil, authenticated: true, parameters: params, success: { (dict, response) in
            success?()
        }) { (error) in
            failure?(error)
        }
    }
    
    func requestIgnoreFriendRequest(friendId: Int,
                                    success: (() -> Void)?,
                                    failure: FailureHandler) {
        
        let params = ["user_id": friendId]
        let fullURL = APIPath.ignoreFriendRequest.fullUrl;
        
        self.requestDELETE(fullURL, selectedImage: nil, authenticated: true, parameters: params, success: { (dict, response) in
            success?()
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - delete Friend
    /**
     Default
     @param friendId
     - success: callback success AppContact list
     - failure: callback when something error
     - returns: Void
     */
    
    func requestDeleteFriend(friendId: Int,
                             success: (() -> Void)?,
                             failure: FailureHandler) {
        
        let params = ["friend_id": "\(friendId)"]
        self.requestPUT(APIPath.deleteFriend.fullUrl, selectedImage: nil, authenticated: true, parameters: params, success: { (dict, response) in
            success?()
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - update device token
    /**
     Default
     @param deviceToken
     - success: callback success
     - failure: callback when something error
     - returns: Void
     */
    
    func requestUpdateDeviceToken(deviceToken: String,
                                  success: (() -> Void)?,
                                  failure: FailureHandler) {
        
        let params = ["platform": "iOS",
                      "device_token" : deviceToken]
        
        self.requestPOST(APIPath.updateDeviceToken.fullUrl, selectedImage: nil, authenticated: true, parameters: params, success: { (dict, response) in
            success?()
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - update notification badge
    /**
     Default
     @param nil
     - success: callback success
     - failure: callback when something error
     - returns: Void
     */
    
    func requestUpdateNotificationBadge(success: (() -> Void)?,
                                        failure: FailureHandler) {
        
        self.requestPOST(APIPath.updateBadge.fullUrl, selectedImage: nil, authenticated: true, parameters: nil, success: { (dict, response) in
            success?()
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - update notification badge
    /**
     Default
     @param nil
     - success: callback success
     - failure: callback when something error
     - returns: Void
     */
    
    func requestUpdateReadAllTripPushNotification(success: (() -> Void)?,
                                                  failure: FailureHandler) {
        
        self.requestPUT(APIPath.updateReadAll.fullUrl, selectedImage: nil, authenticated: true, parameters: nil, success: { (dict, response) in
            success?()
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - update friend notification badge
    /**
     Default
     @param nil
     - success: callback success
     - failure: callback when something error
     - returns: Void
     */
    
    func requestUpdateReadAllFriendPushNotification(success: (() -> Void)?,
                                                    failure: FailureHandler) {
        
        self.requestPUT(APIPath.updateFriendReadAll.fullUrl, selectedImage: nil, authenticated: true, parameters: nil, success: { (dict, response) in
            success?()
        }) { (error) in
            failure?(error)
        }
    }
    
    
    // MARK: - count notification
    /**
     Default
     @param nil
     - success: callback notification count
     - failure: callback when something error
     - returns: Void
     */
    
    func requestGetNotificationCount(success: ((_ count: Int) -> Void)?,
                                     failure: FailureHandler) {
        
        self.requestGET(APIPath.countNotification.fullUrl, selectedImage: nil, authenticated: true, parameters: nil, success: { (dict, response) in
            var count = 0
            if let results = dict["data"] as? [String:Any] {
                if let countInt = results["total"] as? Int {
                    count = countInt
                }
            }
            success?(count)
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - count friend notification
    /**
     Default
     @param nil
     - success: callback notification count
     - failure: callback when something error
     - returns: Void
     */
    
    func requestGetFriendNotificationCount(success: ((_ count: Int) -> Void)?,
                                           failure: FailureHandler) {
        
        self.requestGET(APIPath.countFriendNotification.fullUrl, selectedImage: nil, authenticated: true, parameters: nil, success: { (dict, response) in
            var count = 0
            if let results = dict["data"] as? [String:Any] {
                if let countInt = results["total"] as? Int {
                    count = countInt
                }
            }
            success?(count)
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - Get Notification List
    /**
     Default
     @param
     - success: callback success TDTripNotification list
     - failure: callback when something error
     - returns: Void
     */
    
    func requestGetTripInviteNotificationList(
        success: ((_ tripNotificationList: [TDTripNotification]) -> Void)?,
        failure: FailureHandler) {
        
        self.requestGET(APIPath.notification.fullUrl, selectedImage: nil, authenticated: true, parameters: nil, success: { (dict, response) in
            var tripNotificationList: [TDTripNotification] = []
            if let results = dict["data"] as? [[String:Any]] {
                let tripNotificationArray = Mapper<TDTripNotification>().mapArray(JSONArray: results)
                if tripNotificationArray.count > 0 {
                    tripNotificationList = tripNotificationArray
                }
            }
            success?(tripNotificationList)
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - Update Read All Notification
    /**
     Default
     @param nil
     - success: callback success
     - failure: callback when something error
     - returns: Void
     */
    
    func requestUpdateReadAllNotification(success: (() -> Void)?,
                                          failure: FailureHandler) {
        
        self.requestPOST(APIPath.updateReadAll.fullUrl, selectedImage: nil, authenticated: true, parameters: nil, success: { (dict, response) in
            success?()
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - Invite trip
    /**
     Default
     @param tripId, notificationId
     - success: callback success
     - failure: callback when something error
     - returns: Void
     */
    
    func requestInviteTrip(tripId: Int,
                           ownerId: String,
                           success: (() -> Void)?,
                           failure: FailureHandler) {
        
        let params = ["user_id": ownerId]
        let fullURL = APIPath.trips.fullUrl+"/\(tripId)/invite_trip"
        
        self.requestPUT(fullURL, selectedImage: nil, authenticated: true, parameters: params, success: { (dict, response) in
            success?()
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - Accepted trip
    /**
     Default
     @param tripId, notificationId
     - success: callback success
     - failure: callback when something error
     - returns: Void
     */
    
    func requestAcceptedTrip(tripId: Int,
                             notificationId: String,
                             success: (() -> Void)?,
                             failure: FailureHandler) {
        
        let params = ["notification_id": notificationId]
        let fullURL = APIPath.trips.fullUrl+"/\(tripId)/accepted_trip"
        
        self.requestPUT(fullURL, selectedImage: nil, authenticated: true, parameters: params, success: { (dict, response) in
            success?()
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - Ignored trip
    /**
     Default
     @param tripId, notificationId
     - success: callback success
     - failure: callback when something error
     - returns: Void
     */
    
    func requestIgnoredTrip(tripId: Int,
                            notificationId: String,
                            success: (() -> Void)?,
                            failure: FailureHandler) {
        
        let params = ["notification_id": notificationId]
        let fullURL = APIPath.trips.fullUrl+"/\(tripId)/ignored_trip"
        
        self.requestPUT(fullURL, selectedImage: nil, authenticated: true, parameters: params, success: { (dict, response) in
            success?()
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - clear trip notification
    /**
     Default
     @param notificationId
     - success: callback success
     - failure: callback when something error
     - returns: Void
     */
    
    func requestClearTripNotification(
        notificationId: String,
        success: (() -> Void)?,
        failure: FailureHandler) {
        
        let fullURL = APIPath.notification.fullUrl+"/\(notificationId)"
        
        self.requestDELETE(fullURL, selectedImage: nil, authenticated: true, parameters: nil, success: { (dict, response) in
            success?()
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - requestGetCountriesList
    /**
     Default
     @param isFriend
     - success: callback Country Array
     - failure: callback when something error
     - returns: Void
     */
    
    func requestGetCountriesList(isFriend: Bool = false,
                                 success: ((_ countryList: [Country]) -> Void)?,
                                 failure: FailureHandler) {
        var fullURL = ""
        if isFriend {
            fullURL += APIPath.countriesOfFriendTrip.fullUrl
        } else {
            fullURL += APIPath.countriesOfMyTrip.fullUrl
        }
        self.requestGET(fullURL, selectedImage: nil, authenticated: true, parameters: nil, success: { (dict, response) in
            var countryList: [Country] = []
            if let results = dict["data"] as? [[String:Any]] {
                let countryArray = Mapper<Country>().mapArray(JSONArray: results)
                if countryArray.count > 0 {
                    countryList = countryArray
                }
            }
            success?(countryList)
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - requestGETListByTripOfUser
    /**
     Default
     @param userId
     - success: callback Country Array
     - failure: callback when something error
     - returns: Void
     */
    
    func requestGETListByTripOfUser(userId: Int,
                                 success: ((_ countryList: [Country]) -> Void)?,
                                 failure: FailureHandler) {
        
        let fullURL = APIPath.listByTripOfUser.fullUrl + "?user_id=\(userId)"

        self.requestGET(fullURL, selectedImage: nil, authenticated: true, parameters: nil, success: { (dict, response) in
            var countryList: [Country] = []
            if let results = dict["data"] as? [[String:Any]] {
                let countryArray = Mapper<Country>().mapArray(JSONArray: results)
                if countryArray.count > 0 {
                    countryList = countryArray
                }
            }
            success?(countryList)
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - list_country_of_user
    /**
     Default
     @param userId
     - success: callback Country Array
     - failure: callback when something error
     - returns: Void
     */
    
    func requestGETListCountryOfUser(userId: Int,
                                    success: ((_ countryList: [Country]) -> Void)?,
                                    failure: FailureHandler) {
        
        let fullURL = APIPath.listCountryOfUser.fullUrl + "?user_id=\(userId)"
        
        self.requestGET(fullURL, selectedImage: nil, authenticated: true, parameters: nil, success: { (dict, response) in
            var countryList: [Country] = []
            if let results = dict["data"] as? [[String:Any]] {
                let countryArray = Mapper<Country>().mapArray(JSONArray: results)
                if countryArray.count > 0 {
                    countryList = countryArray
                }
            }
            success?(countryList)
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - share trip
    /**
     Default
     @param activityId, activityType
     - success: callback success
     - failure: callback when something error
     - returns: Void
     */
    
    func requestShareActivityWithType(activityId: Int,
                                      activityType: String,
                                      stampIdArray: [Int]?,
                                      success: ((_ message: String) -> Void)?,
                                      failure: FailureHandler) {
        
        let fullURL = APIPath.activities.fullUrl
        
        var params = ["activity_type": activityType] as [String : Any]
        
        if let stampIdArray = stampIdArray {
            params["stamp_ids"] = stampIdArray
        } else {
            params["activity_id"] = activityId
        }
        
        self.requestPOST(fullURL, selectedImage: nil, authenticated: true, parameters: params, success: { (dict, response) in
            if let message = dict["message"] as? String {
                success?(message)
                return
            }
            let error = TDError("Could not load data from server")
            failure?(error)
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - get Activity List
    /**
     Default
     @param
     - success: callback AbstractActivity array
     - failure: callback when something error
     - returns: Void
     */
    
    func requestGetActivityList(page: Int?,
                                perPage: Int?,
                                success: ((_ activityList: [AbstractActivity]) -> Void)?,
                                failure: FailureHandler) {
        
        var fullURL = APIPath.activities.fullUrl
        if let page = page,
            let perPage = perPage {
            fullURL += "?page=\(page)&per_page=\(perPage)"
        }
        self.requestGET(fullURL, selectedImage: nil, authenticated: true, parameters: nil, success: { (dict, response) in
            var activityList: [AbstractActivity] = []
            if let data = dict["data"] as? [String:Any],
                let results = data["result"] as? [[String:Any]]{
                for result in results {
                    let activity = AbstractActivity.load(fromJSON: result)
                    activityList.append(activity)
                }
            }
            success?(activityList)
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - invite
    /**
     Default
     @param
     - success: callback AbstractActivity array
     - failure: callback when something error
     - returns: Void
     */
    
    func inviteFriend(contact: String, dynamicLink: String,
                      success: (() -> Void)?,
                      failure: FailureHandler) {
        
        let fullURL = APIPath.invites.fullUrl
        
        let param = ["contact" : contact,
                     "dynamic_link": dynamicLink];
        
        self.requestPOST(fullURL, selectedImage: nil, authenticated: true, parameters: param, success: { (dict, response) in
            if let isSuccess = dict["success"] as? Bool, isSuccess == true {
                success?()
                return
            }
            let error = TDError("Could not load data from server")
            failure?(error)
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - fetchStampByCountryCode
    /**
     Default
     @param countryCode
     - success: callback AbstractActivity array
     - failure: callback when something error
     - returns: Void
     */
    
    func fetchStampByCountryCode(countryCode: String?,
                                 userId: String?,
                                 success: ((_ stampList: [TDStamp]) -> Void)?,
                                 failure: FailureHandler) {
        
        var fullURL = APIPath.stamps.fullUrl
        
        if let countryCode = countryCode {
            fullURL += "?country=\(countryCode)"
        }
        
        if let userId = userId {
            fullURL += "?user_id=\(userId)"
        }
        
        self.requestGET(fullURL, selectedImage: nil, authenticated: true, parameters: nil, success: { (dict, response) in
            var stampList: [TDStamp] = []
            if let results = dict["data"] as? [[String:Any]] {
                let stampArray = Mapper<TDStamp>().mapArray(JSONArray: results)
                if stampArray.count > 0 {
                    stampList = stampArray
                }
            }
            success?(stampList)
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - postStampByCountryCode
    /**
     Default
     @param countryCode
     - success: callback AbstractActivity array
     - failure: callback when something error
     - returns: Void
     */
    
    func postStampByCountryCode(countryCode: String,
                                uploadedAt: Double,
                                success: (() -> Void)?,
                                failure: FailureHandler) {
        
        let fullURL = APIPath.stamps.fullUrl
        
        let param = ["country" : countryCode,
                     "uploaded_at" : uploadedAt] as [String : Any];
        
        self.requestPOST(fullURL, selectedImage: nil, authenticated: true, parameters: param, success: { (dict, response) in
            if let isSuccess = dict["success"] as? Bool, isSuccess == true {
                success?()
                return
            }
            let error = TDError("Could not load data from server")
            failure?(error)
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - getUserInfo
    /**
     Default
     @param userId
     - success: callback AbstractActivity array
     - failure: callback when something error
     - returns: Void
     */
    
    func getUserInfo(userId: String,
                     success: ((_ pictureData: TDFriend) -> Void)?,
                     failure: FailureHandler) {
        
        let fullURL = APIPath.users.fullUrl + "/\(userId)"
        
        self.requestGET(fullURL, selectedImage: nil, authenticated: true, parameters: nil, success: { (dict, response) in
            if let result = dict["data"] as? [String:Any] {
                if let friendData = Mapper<TDFriend>().map(JSON: result) {
                    success?(friendData)
                    return
                }
            }
            let error = TDError("Could not load data from server")
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - forgot pass
    /**
     Default
     @param email
     - success: callback AbstractActivity array
     - failure: callback when something error
     - returns: Void
     */
    
    func forgotPass(email: String,
                    success: (() -> Void)?,
                    failure: FailureHandler) {
        
        let fullURL = APIPath.pass.fullUrl
        
        let param = ["email": email]
        
        self.requestPOST(fullURL, selectedImage: nil, authenticated: false, parameters: param, success: { (dict, response) in
            if let isSuccess = dict["success"] as? Int {
                if isSuccess == 1 {
                    success?()
                    return
                }
            }
            let error = TDError("Could not load data from server")
            failure?(error)
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - forgot pass
    /**
     Default
     @param email
     - success: callback AbstractActivity array
     - failure: callback when something error
     - returns: Void
     */
    
    func checkCodePass(email: String,
                       code: String,
                       success: ((_ authToken: String) -> Void)?,
                       failure: FailureHandler) {
        
        let fullURL = APIPath.checkCode.fullUrl
        
        let param = ["email" : email, "code" : code]
        
        self.requestPOST(fullURL, selectedImage: nil, authenticated: false, parameters: param, success: { (dict, response) in
            if let data = dict["data"] as? [String: Any] {
                if let token = data["auth_token"] as? String {
                    success?(token)
                }
                return
            }
            let error = TDError("Could not load data from server")
            failure?(error)
        }) { (error) in
            failure?(error)
        }
    }
    
    // MARK: - change pass
    /**
     Default
     @param email
     - success: callback AbstractActivity array
     - failure: callback when something error
     - returns: Void
     */
    
    func changeNewPass(email: String,
                       token: String,
                       pass: String,
                       rePass: String,
                       success: (() -> Void)?,
                       failure: FailureHandler) {
        
        let fullURL = APIPath.pass.fullUrl
        
        let param = ["email" : email,
                     "auth_token" : token,
                     "password" : pass,
                     "password_confirmation" : rePass]
        
        self.requestPATCH(fullURL, selectedImage: nil, authenticated: false, parameters: param, success: { (dict, response) in
            if let isSuccess = dict["success"] as? Int {
                if isSuccess == 1 {
                    success?()
                    return
                }
            }
            let error = TDError("Could not load data from server")
            failure?(error)
        }) { (error) in
            failure?(error)
        }
    }
}

fileprivate extension TDAPIManager {
    
    /// Generic get method for
    ///
    /// - Parameters:
    ///   - url: request url
    ///   - parameters: parameters
    ///   - success: callback with a dictionary when request succeeds.
    ///   - failure: callback with an error when request fails. Check the error code for handling
    
    func requestGET(_ url:String, selectedImage: UIImage? = nil, selectedCoverImage: UIImage? = nil, selectedProfileImage: UIImage? = nil, authenticated auth: Bool = true, parameters:Parameters? = nil,
                    success: @escaping ([String:Any], HTTPURLResponse) -> Void ,
                    failure: ((_ error: TDError) -> Void)?) {
        
        self.request(url, selectedImage: selectedImage, selectedCoverImage: selectedCoverImage, selectedProfileImage: selectedProfileImage, authenticated: auth, parameters: parameters, success: success, failure: failure)
    }
    
    func requestPOST(_ url:String, selectedImage: UIImage? = nil, selectedCoverImage: UIImage? = nil, selectedProfileImage: UIImage? = nil, authenticated auth: Bool = true, parameters:Parameters? = nil,
                     success: @escaping ([String:Any], HTTPURLResponse) -> Void ,
                     failure: ((_ error: TDError) -> Void)?) {
        
        self.request(url, selectedImage: selectedImage, selectedCoverImage: selectedCoverImage, selectedProfileImage: selectedProfileImage, authenticated: auth, method: .post, parameters: parameters, success: success, failure: failure)
    }
    
    func requestPATCH(_ url:String, selectedImage: UIImage? = nil, selectedCoverImage: UIImage? = nil, selectedProfileImage: UIImage? = nil, authenticated auth: Bool = true, parameters:Parameters? = nil,
                      success: @escaping ([String:Any], HTTPURLResponse) -> Void ,
                      failure: ((_ error: TDError) -> Void)?) {
        
        self.request(url, selectedImage: selectedImage, selectedCoverImage: selectedCoverImage, selectedProfileImage: selectedProfileImage, authenticated: auth, method: .patch, parameters: parameters, success: success, failure: failure)
    }
    
    func requestPUT(_ url:String, selectedImage: UIImage? = nil, selectedCoverImage: UIImage? = nil, selectedProfileImage: UIImage? = nil, authenticated auth: Bool = true, parameters:Parameters? = nil,
                    success: @escaping ([String:Any], HTTPURLResponse) -> Void ,
                    failure: ((_ error: TDError) -> Void)?) {
        
        self.request(url, selectedImage: selectedImage, selectedCoverImage: selectedCoverImage, selectedProfileImage: selectedProfileImage, authenticated: auth, method: .put, parameters: parameters, success: success, failure: failure)
    }
    
    func requestDELETE(_ url:String, selectedImage: UIImage? = nil, selectedCoverImage: UIImage? = nil, selectedProfileImage: UIImage? = nil, authenticated auth: Bool = true, parameters:Parameters? = nil,
                       success: @escaping ([String:Any], HTTPURLResponse) -> Void ,
                       failure: ((_ error: TDError) -> Void)?) {
        
        self.request(url, selectedImage: selectedImage, selectedCoverImage: selectedCoverImage, selectedProfileImage: selectedProfileImage, authenticated: auth, method: .delete, parameters: parameters, success: success, failure: failure)
    }
    
    
    func request(_ url:String, selectedImage: UIImage?, selectedCoverImage: UIImage?, selectedProfileImage: UIImage?, authenticated auth:Bool = true, method: HTTPMethod = .get, parameters:Parameters? = nil,
                 success: @escaping ([String:Any], HTTPURLResponse) -> Void ,
                 failure: ((_ error: TDError) -> Void)?) {
        
        //TODO: Add login token here
        var headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        if auth, let login = Keychain.getLogin() {
            headers["Access-Token"] = login.token;
            headers["Client"] = login.client;
            headers["Uid"] = login.uid;
        }
        var isUpdateImage = false
        if let _ = selectedImage {
            isUpdateImage = true
        }
        if let _ = selectedCoverImage {
            isUpdateImage = true
        }
        if let _ = selectedProfileImage {
            isUpdateImage = true
        }
        if isUpdateImage {
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                
                if let parameters = parameters {
                    for (key, value) in parameters {
                        multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                    }
                }
                if let selectedImage = selectedImage {
                    if let imageData = UIImageJPEGRepresentation(selectedImage, 1) {
                        multipartFormData.append(imageData, withName: "file", fileName: "file.png", mimeType: "image/jpeg")
                    }
                }
                
                if let selectedCoverImage = selectedCoverImage {
                    if let imageData = UIImageJPEGRepresentation(selectedCoverImage, 1) {
                        multipartFormData.append(imageData, withName: "cover_picture", fileName: "file.png", mimeType: "image/jpeg")
                    }
                }
                
                if let selectedProfileImage = selectedProfileImage {
                    if let imageData = UIImageJPEGRepresentation(selectedProfileImage, 1) {
                        multipartFormData.append(imageData, withName: "profile_picture", fileName: "file.png", mimeType: "image/jpeg")
                    }
                }
                
            }, usingThreshold: UInt64.init(), to: url, method: method, headers: headers) { (encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        self.handleResponse(response: response, success: success, failure: failure)
                    }
                case .failure(let encodingError):
                    failure?(self.errorWithMessage(message: encodingError.localizedDescription))
                }
            }
        } else {
            Alamofire.request(url, method: method, parameters:parameters, headers:headers).responseJSON { (response) in
                self.handleResponse(response: response, success: success, failure: failure)
            }
        }
    }
    
    func handleResponse(response: DataResponse<Any>,
                        success: @escaping ([String:Any], HTTPURLResponse) -> Void ,
                        failure: ((_ error: TDError) -> Void)?) {
        //Successful
        if (response.result.isSuccess) {
            if let statusCode = response.response?.statusCode, let dict = response.result.value as? [String:Any]{
                log.debug("Request code: \(statusCode)")
                
                //Successfull HTTP code
                if (statusCode < 400) {
                    success(dict, response.response!);//The unwrapping is safe because response always exists when request succeeds
                } else {
                    
                    var message: String? = nil;
                    if let error = dict["errors"] as? String {
                        message = error;
                    }
                    failure?(self.errorWithMessage(message: message));
                }
            } else {
                failure?(self.errorWithMessage());
            }
        } else {
            let error = response.error as NSError?;
            
            if let data = response.data {
                let _ = String.init(data: data, encoding: .utf8);
            } else {
            }
            failure?(self.errorWithMessage());
        }
    }
    
    func errorWithMessage(message:String? = nil) -> TDError{
        
        var error: TDError!
        
        if let message = message {
            error = TDError(message);
        } else {
            error = TDError("Cannot connect to server");
        }
        return error;
    }
    
    func saveLoginData(fromResponse response: HTTPURLResponse) -> Bool {
        
        guard let headers = response.allHeaderFields as? [String: String], let token = headers["Access-Token"],
            let client = headers["Client"],
            let uid = headers["Uid"] else {
                log.error("Header doesn't contain login data")
                return false;
        }
        
        Keychain.save(accessToken: token, uid: uid, client: client);
        log.info("======== Authorization saved =========");
        return true;
    }
}

class TDError {
    var message = "";
    init(_ message:String) {
        self.message = message;
    }
}

