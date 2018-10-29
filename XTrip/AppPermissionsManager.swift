//
//  AppPermissionsManager.swift
//  Vaster
//
//  Created by Khoa Bui on 4/21/17.
//  Copyright © 2017 Elinext. All rights reserved.
//

import UIKit

let APP_PERMISSIONS_MANAGER = AppPermissionsManager.sharedInstance

class AppPermissionsManager: NSObject {
    
    let permissionScope = PermissionScope()
    static let sharedInstance = AppPermissionsManager()
    
    func checkPhotoPermissions(viewController: UIViewController, completionHandler completion: ((_ isAuthorized: Bool) -> Void)?, onTapped tapped: ((Bool) -> Void)?) {
       permissionScope.viewControllerForAlerts = viewController
        switch permissionScope.statusPhotos() {
        case .unknown:
            completion?(false)
            permissionScope.requestPhotos(onTapped: {(isTapped) -> () in
                tapped?(isTapped)
            })
        case .unauthorized, .disabled:
            completion?(false)
            permissionScope.requestPhotos(onTapped: {(isTapped) -> () in
                tapped?(isTapped)
            })
        case .authorized:
            completion?(true)
            return
        }
    }
    
    func checkCameraPermissions(viewController: UIViewController, completionHandler completion: ((_ isAuthorized: Bool) -> Void)?, onTapped tapped: ((Bool) -> Void)?) {
        permissionScope.viewControllerForAlerts = viewController
        switch permissionScope.statusCamera() {
        case .unknown:
            completion?(false)
            permissionScope.requestCamera(onTapped: {(isTapped) -> () in
                tapped?(isTapped)
            })
        case .unauthorized, .disabled:
            completion?(false)
            permissionScope.requestCamera(onTapped: {(isTapped) -> () in
                tapped?(isTapped)
            })
        case .authorized:
            completion?(true)
            return
        }
    }
    
    func checkMicrophonePermissions(viewController: UIViewController, willRequestPermission: Bool = true, completionHandler completion: ((_ isAuthorized: Bool) -> Void)?, onTapped tapped: ((Bool) -> Void)?) {
        permissionScope.viewControllerForAlerts = viewController
        switch permissionScope.statusMicrophone() {
        case .unknown:
            if willRequestPermission {
                permissionScope.requestMicrophone(onTapped: {(isTapped) -> () in
                    tapped?(isTapped)
                })
            }
            completion?(false)
        case .unauthorized, .disabled:
            if willRequestPermission {
                permissionScope.requestMicrophone(onTapped: {(isTapped) -> () in
                    tapped?(isTapped)
                })
            }
            completion?(false)
        case .authorized:
            completion?(true)
            return
        }
    }
    
    
    func checkContactsPermissions(viewController: UIViewController, completionHandler completion: ((_ isAuthorized: Bool) -> Void)?) {
        permissionScope.viewControllerForAlerts = viewController
        switch permissionScope.statusContacts() {
        case .unknown:
            completion?(false)
            permissionScope.requestContacts()
        case .unauthorized, .disabled:
            completion?(false)
            permissionScope.requestContacts()
        case .authorized:
            completion?(true)
            return
        }
    }
    
    
    func checkLocationInUsePermissions(viewController: UIViewController, willRequestPermission: Bool = true, completionHandler completion: ((_ isAuthorized: Bool) -> Void)?, onTapped tapped: ((Bool) -> Void)?) {
        permissionScope.viewControllerForAlerts = viewController
        switch permissionScope.statusLocationInUse() {
        case .unknown:
            if willRequestPermission {
                permissionScope.requestLocationInUse(onTapped: {(isTapped) -> () in
                    tapped?(isTapped)
                })
            }
            completion?(false)
        case .unauthorized, .disabled:
            if willRequestPermission {
                permissionScope.requestLocationInUse(onTapped: {(isTapped) -> () in
                    tapped?(isTapped)
                })
            }
            completion?(false)
        case .authorized:
            completion?(true)
            return
        }
    }

}
