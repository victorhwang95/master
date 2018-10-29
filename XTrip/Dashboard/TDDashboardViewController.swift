//
//  TDDashboardViewController.swift
//  XTrip
//
//  Created by Hoang Cap on 11/29/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation
import CoreLocation

protocol DashboardViewControllerDelegate: class {
    func didTapToUpdatePhoneNumber()
}

class TDDashboardViewController: TDBaseViewController {
    
    weak var delegate: DashboardViewControllerDelegate?
    
    // MARK:- Public method
    static func newInstance() -> TDDashboardViewController {
        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TDDashboardViewController") as! TDDashboardViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LOCATION_MANAGER.startLocationService()
        
        EVENT_NOTIFICATION_MANAGER.delegateDash = self
        
        let contact = TDUser.currentUser()?.contact ?? ""
        if contact.isBlank {
            let phoneNumberReminderVC = PhoneNumberReminderViewController.newInstance()
            phoneNumberReminderVC.delegate = self
            self.present(phoneNumberReminderVC, animated: true, completion: nil)
        }
        
        //        LocationManager.shared.requestLocationServiceIfNeeded()
        APP_PERMISSIONS_MANAGER.checkPhotoPermissions(viewController: self, completionHandler: nil, onTapped: nil)
        //        APP_PERMISSIONS_MANAGER.checkContactsPermissions(viewController: self, completionHandler: nil)
        //        print(USER_DEFAULT_GET(key: .deviceToken))
        
        // Load all my trip
        API_MANAGER.requestGetTripList(isfriendTrip: false, page: nil, perPage: nil, showImage: nil, country: nil, time: nil, friendId: nil, userId: nil, success: { (baseData) in
            if let tripList = baseData.tripList {
                TDTrip.saveTripList(tripList)
            }
        }, failure: { (error) in })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Dashboard"
        changeNavigationBarToDefaultStyle()
        setupRightButtons(buttonType: .setting)
        setupNavigationButton()
        EVENT_NOTIFICATION_MANAGER.checkTripPushNotificationCount()
    }
    
    @IBAction func createTripTapped(_ sender: Any) {
        let createTripVC = TDCreateTripViewController.newInstance()
        self.navigationController?.pushViewController(createTripVC, animated: true)
    }
    
    @IBAction func takeAPictureTapped(_ sender: Any) {
        let cameraVC = TDCameraViewController.newInstance()
        cameraVC.delegate = self
        self.present(cameraVC, animated: true, completion: nil)
    }
    
    @IBAction func uploadPictureTapped(_ sender: Any) {
        let galleryVC = TDGalleryViewController.newInstance()
        self.navigationController?.pushViewController(galleryVC, animated: true)
    }
    
    @IBAction func addFriendsTapped(_ sender: Any) {
        let vc = TDInviteFriendsViewController.newInstance();
        self.navigationController?.pushViewController(vc, animated: true);
    }
}

extension TDDashboardViewController: TDCameraViewControllerDelegate {
    
    func didShotNewPicture(withPictureData: (UIImage, CLLocationCoordinate2D?)) {
        let pictureData: (UIImage, CLLocationCoordinate2D?, Date?) = (withPictureData.0, withPictureData.1, Date());//Date data is always the current time
        let vc = MYPICTURES_STORYBOARD.instantiateViewController(withIdentifier: "TDUpdatePhotoInfoViewController") as! TDUpdatePhotoInfoViewController
        vc.choosePhotoDataArray.append(pictureData)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension TDDashboardViewController: PhoneNumberReminderViewControllerDelegate {
    func didTapToUpdatePhoneNumber() {
        self.delegate?.didTapToUpdatePhoneNumber()
    }
}

extension TDDashboardViewController: EvenNotificationManagerDelegate {
    func didGetNewTripPushNotification(count: Int) {
        self.notificationBarView?.setData(count: count)
    }
    
    func redirectTripPushToDetailPage() {
        self.notificationButtonTapped()
    }
}

