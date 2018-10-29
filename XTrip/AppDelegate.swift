    //
//  AppDelegate.swift
//  travelDiary
//
//  Created by Hoang Cap on 7/9/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import GooglePlaces
import Firebase
import FirebaseMessaging
import UserNotifications
import FacebookCore
import KeychainAccess
import IQKeyboardManagerSwift
import FBSDKCoreKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    let locationManager = CLLocationManager();
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //Config for deeplink
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = "travelx"
        
        log.debug("Base url: \(CONFIGURATION_CURRENT.endPointURL)");
        
        IQKeyboardManager.shared.enable = true;
        IQKeyboardManager.shared.keyboardDistanceFromTextField=50;

        //Register for facebook SDK
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions);
        //Register for Google Places
        GMSPlacesClient.provideAPIKey(CONFIGURATION_CURRENT.googlePlacesAPIKey);
        
        //Firebase configuration
        
        let configuration = CONFIGURATION_CURRENT.googleServiceConfiguration;
        
        guard let options = FirebaseOptions(contentsOfFile: configuration) else {
            fatalError("Invalid firebase configuration file");
        }
        options.deepLinkURLScheme = "travelx"
        
        FirebaseApp.configure(options: options);
        
        SharingManager.shared.generateDynamicLink(userId: "123") { (lk) in
            print(lk)
        }
        
        self.registerNotification(application: application)
        
        if let launchOptions = launchOptions {
            // Opened from a push notification when the app is closed
            if let userInfo = launchOptions[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable : Any] {
                
            }
        }
        
        application.applicationIconBadgeNumber = 0
        self.showMainScreen()
        
        GMSServices.provideAPIKey(TDConfiguration.current.googleServiceAPIKey)
        
        Fabric.with([Crashlytics.self])
        
        return true
    }
    
    private func registerNotification(application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {(granted, error) in
                    if (granted)
                    {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                    else{
                        //Do stuff if unsuccessful...
                        print("grant error, try next time")
                    }
            })
            let action = UNNotificationAction(identifier: "Notification1", title: "Expiration notification", options: [.foreground])
            let category = UNNotificationCategory(identifier: "Notification1", actions: [action], intentIdentifiers: [], options: [])
            UNUserNotificationCenter.current().setNotificationCategories([category])
            
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
            UNUserNotificationCenter.current().delegate = self;
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification),
                                               name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        var isDynamicLinkHandled = false;
        
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            // Handle the deep link. For example, show the deep-linked content or
            // apply a promotional offer to the user's account.
            // ...


            if let url = dynamicLink.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                if let queryItem = components.queryItems?.first {
                    if (queryItem.name == "user_id") {
                        print("Query Item: \(queryItem.value!)")
                        USER_DEFAULT_SET(value: queryItem.value!, key: .referralUserId);
                    }
                }
            }
            isDynamicLinkHandled = true;
        }
        
        var isFacebookHandled = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation);

        if isDynamicLinkHandled {
            return isDynamicLinkHandled;
        } else {
            return isFacebookHandled;
        }
    }
    
    func tokenRefreshNotification(notification: NSNotification) {
        print("TokenRefresh")
        if let refreshedToken = InstanceID.instanceID().token() {
            refreshToken(newToken: refreshedToken)
        }
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    
    // [START connect_to_fcm]
    func connectToFcm() {
        
        Messaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        if let refreshedToken = InstanceID.instanceID().token() {
            USER_DEFAULT_SET(value: refreshedToken, key: .deviceToken);
            USER_DEFAULT_SYNC();
        }
        #if DEBUG
            Messaging.messaging()
                .setAPNSToken(deviceToken, type: MessagingAPNSTokenType.sandbox)
        #else
            Messaging.messaging()
                .setAPNSToken(deviceToken, type: MessagingAPNSTokenType.prod)
        #endif
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        // Get new trip push notification
        if let _ = TDUser.currentUser() {
            EVENT_NOTIFICATION_MANAGER.checkTripPushNotificationCount()
        }
        
        if let isUpdateToken = USER_DEFAULT_GET(key: .isUpdatedeviceToken) as? Bool, isUpdateToken == false{
            //Auto update device token every open app
            EvenNotificationManager.sharedInstance.updateDeviceToken()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func refreshToken(newToken: String) {
        USER_DEFAULT_SET(value: newToken, key: .deviceToken);
        USER_DEFAULT_SYNC();
    }
    
    //MARK: DEEP LINK
//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        DeeplinkManager.sharedInstance.handleDeppLink(deepLink: url.absoluteString)
//        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
//    }
    
    open func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return application(app, open: url,
                           sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                           annotation: "");
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!, completion: { (dynamiclink, error) in
            if let url = dynamiclink?.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                if let queryItem = components.queryItems?.first {
                    if (queryItem.name == "user_id") {
                        USER_DEFAULT_SET(value: queryItem.value!, key: .referralUserId);
                    }
                }
            }
        })
        
        if handled {
            return handled
        }
//        guard let dynamicLinks = DynamicLinks.dynamicLinks() else {
//            return false
//        }
//        let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
//            if let url = dynamiclink?.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
//                if let queryItem = components.queryItems?.first {
//                    if (queryItem.name == "user_id") {
//                        USER_DEFAULT_SET(value: queryItem.value!, key: .referralUserId);
//                    }
//                }
//            }
//        }
        
        return handled
    }
    
    
}

extension AppDelegate: MessagingDelegate {
    func application(received remoteMessage: MessagingRemoteMessage) {
        //TODO: Handle receive message from Clound message
        print("===========Received message from firebase delegate when in foreground=========")
        if let aps = remoteMessage.appData["aps"] as? [String:Any] {
            print(aps);
            
        }
    }
    
    
    /// This method will be called whenever FCM receives a new, default FCM token for your
    /// Firebase project's Sender ID.
    /// You can send this token to your application server to send notifications to this device.
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        refreshToken(newToken: fcmToken)
    }
}

//MARK: Handle push notification in iOS 10
extension AppDelegate: UNUserNotificationCenterDelegate {
    @available(iOS 10.0, *)
    
    //MARK: Handle push when notification is tapped while app's in background
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let dict = response.notification.request.content.userInfo;
        
        print(dict)
        EVENT_NOTIFICATION_MANAGER.redirectTripPushToDetailPage()
        completionHandler()
    }
    
    @available(iOS 10.0, *)
    
    //MARK: Handle push in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(UNNotificationPresentationOptions.sound)
        let dict = notification.request.content.userInfo;
        print(dict)
        EVENT_NOTIFICATION_MANAGER.checkTripPushNotificationCount()
    }
}

extension AppDelegate {
    
    class var current: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate;
    }
    
    /// Set the root view controller with fading animation
    ///
    /// - Parameter vc: destination view controller
    func setRootViewController(_ vc:UIViewController) {
        self.window?.rootViewController = vc;
    }
    
    func showMainScreen() {
        if let _ = TDUser.currentUser() {
            let mainView = TDMainViewController.newInstance()
            self.setRootViewController(mainView)
        }
    }
    
    func showLoginScreen() {
        let registerVC = TDRegisterViewController.newInstance()
        let nav = UINavigationController.init(rootViewController: registerVC);
        nav.setNavigationBarHidden(true, animated: false);
        self.setRootViewController(nav)
    }
}
