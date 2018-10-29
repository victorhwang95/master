//
//  TDMainViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 12/26/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit

class TDMainViewController: TDBaseViewController {

    // MARK:- Outlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tabbarView: UIView!
    
    @IBOutlet weak var activityContainerTabbarView: UIView!
    @IBOutlet weak var activityTabbarView: UIView!
    @IBOutlet weak var activityActiveTabbarView: UIView!
    
    @IBOutlet weak var tripsContainerTabbarView: UIView!
    @IBOutlet weak var tripsTabbarView: UIView!
    @IBOutlet weak var tripsActiveTabbarView: UIView!
    
    @IBOutlet weak var picturesContainerTabbarView: UIView!
    @IBOutlet weak var picturesTabbarView: UIView!
    @IBOutlet weak var picturesActiveTabbarView: UIView!
    
    @IBOutlet weak var friendsContainerTabbarView: UIView!
    @IBOutlet weak var friendActiveTabbarView: UIView!
    @IBOutlet weak var friendTabbarView: UIView!
    
    @IBOutlet weak var dashboardButton: UIButton!
    @IBOutlet weak var notificationCountLabel: UILabel!
    
    // MARK:- Properties
    var myActivityVC: TDMyActivityViewController!
    var myTripsVC: TDMyTripsViewController!
    var myPicturesVC: TDMyPicturesViewController!
    var myFriendsVC: TDMyFriendsViewController!
    var dashboardVC: TDDashboardViewController!
    
    var myActivityNavigationController: TDBaseNavigationViewController!
    var myTripsNavigationController: TDBaseNavigationViewController!
    var myPicturesNavigationController: TDBaseNavigationViewController!
    var myFriendsNavigationController: TDBaseNavigationViewController!
    var dashboardNavigationController: TDBaseNavigationViewController!
    
    // MARK:- Public method
    static func newInstance() -> TDMainViewController {
        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TDMainViewController") as! TDMainViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        EVENT_NOTIFICATION_MANAGER.delegateMain = self
        EVENT_NOTIFICATION_MANAGER.checkTripPushNotificationCount()
        NotificationCenter.default.addObserver(self, selector: #selector(self.goToMyTripPicturePage(_:)), name: NotificationName.didUploadPictureSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.goToMyTripPage(_:)), name: NotificationName.didCreateTripSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.goToFriendTripPage(_:)), name: NotificationName.didAcceptTripSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.goToMyTripPage), name: NotificationName.viewMyTripSuccess, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:- Private method
    
    func setupView() {
        self.setupChildViewControllers()
        // Reset trip push count label
        self.notificationCountLabel.setRoundedCorner(radius: self.notificationCountLabel.width/2)
        self.notificationCountLabel.text = ""
        self.notificationCountLabel.isHidden = true
    }
    
    private func setupChildViewControllers() {
        if (self.myActivityVC == nil) {
            self.myActivityVC = TDMyActivityViewController.newInstance()
            self.myActivityNavigationController = TDBaseNavigationViewController.init(rootViewController: self.myActivityVC)
        }
        if (self.myTripsVC == nil) {
            self.myTripsVC = TDMyTripsViewController.newInstance()
            self.myTripsNavigationController = TDBaseNavigationViewController.init(rootViewController: self.myTripsVC)
        }
        if (self.myPicturesVC == nil) {
            self.myPicturesVC = TDMyPicturesViewController.newInstance()
            self.myPicturesNavigationController = TDBaseNavigationViewController.init(rootViewController: self.myPicturesVC)
        }
        if (self.myFriendsVC == nil) {
            self.myFriendsVC = TDMyFriendsViewController.newInstance()
            self.myFriendsNavigationController = TDBaseNavigationViewController.init(rootViewController: self.myFriendsVC)
        }
        if (self.dashboardVC == nil) {
            self.dashboardVC = TDDashboardViewController.newInstance()
            self.dashboardVC.delegate = self
            self.dashboardNavigationController = TDBaseNavigationViewController.init(rootViewController: self.dashboardVC)
            self.addChild(childViewController: self.dashboardNavigationController, inView: self.contentView)
            self.dashboardButton.isSelected = true
        }
    }
    
    fileprivate func resetAllLayout() {
        self.activityContainerTabbarView.bringSubview(toFront: self.activityTabbarView)
        self.tripsContainerTabbarView.bringSubview(toFront: self.tripsTabbarView)
        self.picturesContainerTabbarView.bringSubview(toFront: self.picturesTabbarView)
        self.friendsContainerTabbarView.bringSubview(toFront: self.friendTabbarView)
        self.friendsContainerTabbarView.bringSubview(toFront: self.notificationCountLabel)
        self.dashboardButton.isSelected = false
        
        if (self.myActivityNavigationController != nil) {
            self.remove(childViewController: self.myActivityNavigationController)
        }
        if (self.myTripsNavigationController != nil) {
            self.remove(childViewController: self.myTripsNavigationController)
        }
        if (self.myPicturesNavigationController != nil) {
            self.remove(childViewController: self.myPicturesNavigationController)
        }
        if (self.myFriendsNavigationController != nil) {
            self.remove(childViewController: self.myFriendsNavigationController)
        }
        if (self.dashboardNavigationController != nil) {
            self.remove(childViewController: self.dashboardNavigationController)
        }
    }
    
    //MARK:- Selector method

    func goToMyTripPicturePage(_ notification: NSNotification){
        self.picturesTapped(UITapGestureRecognizer())
    }
    
    func goToMyTripPage(_ notification: NSNotification){
        isViewFriendTripDetail = false
        self.tripsTapped(UITapGestureRecognizer())
        
    }
    
    func goToFriendTripPage(_ notification: NSNotification){
        isViewFriendTripDetail = true
        self.tripsTapped(UITapGestureRecognizer())
        
    }
    
    //MARK:- Action
    
    @IBAction func activityTapped(_ sender: UITapGestureRecognizer) {
        self.resetAllLayout()
        if (self.myActivityNavigationController != nil) {
            self.addChild(childViewController: self.myActivityNavigationController, inView: self.contentView)
            self.activityContainerTabbarView.bringSubview(toFront: self.activityActiveTabbarView)
        }
    }
    
    @IBAction func tripsTapped(_ sender: UITapGestureRecognizer) {
        self.resetAllLayout()
        if (self.myTripsNavigationController != nil) {
            self.addChild(childViewController: self.myTripsNavigationController, inView: self.contentView)
            self.tripsContainerTabbarView.bringSubview(toFront: self.tripsActiveTabbarView)
        }
    }
    
    @IBAction func picturesTapped(_ sender: UITapGestureRecognizer) {
        self.resetAllLayout()
        if (self.myPicturesNavigationController != nil) {
            self.addChild(childViewController: self.myPicturesNavigationController, inView: self.contentView)
            self.picturesContainerTabbarView.bringSubview(toFront: self.picturesActiveTabbarView)
        }
    }
    
    @IBAction func friendsTapped(_ sender: UITapGestureRecognizer) {
        self.resetAllLayout()
        if (self.myFriendsNavigationController != nil) {
            self.addChild(childViewController: self.myFriendsNavigationController, inView: self.contentView)
            self.friendsContainerTabbarView.bringSubview(toFront: self.friendActiveTabbarView)
            self.friendsContainerTabbarView.bringSubview(toFront: self.notificationCountLabel)
        }
    }
    
    @IBAction func dashboardTapped(_ sender: UITapGestureRecognizer) {
        self.resetAllLayout()
        if (self.dashboardNavigationController != nil) {
            self.addChild(childViewController: self.dashboardNavigationController, inView: self.contentView)
            self.dashboardButton.isSelected = true
        }
    }
    
}

extension TDMainViewController: EvenNotificationManagerDelegate {
    func didGetNewTripPushNotification(count: Int) {
        if count != 0 {
            self.notificationCountLabel.isHidden = false
            self.notificationCountLabel.text = "\(count)"
        } else {
            self.notificationCountLabel.isHidden = true
            self.notificationCountLabel.text = ""
        }
    }
    
    func redirectTripPushToDetailPage() {
        self.friendsTapped(UITapGestureRecognizer())
    }
}
extension TDMainViewController: DashboardViewControllerDelegate {
    func didTapToUpdatePhoneNumber() {
        let settingVC = TDSettingViewController.newInstance()
        settingVC.isForceUpdatePhoneNumber = true
        self.present(settingVC, animated: true, completion: nil)
    }
}
