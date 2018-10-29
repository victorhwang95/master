//
//  TDNotificationViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 1/1/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import MJRefresh

class TDNotificationViewController: TDBaseViewController {

    // MARK:- Properties
    let header = MJRefreshNormalHeader()
    var tripNotificationArray: [TDTripNotification] = [TDTripNotification]()
    
    // MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK:- Public method
    static func newInstance() -> TDNotificationViewController {
        return UIStoryboard.init(name: "MyFriends", bundle: nil).instantiateViewController(withIdentifier: "TDNotificationViewController") as! TDNotificationViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Notification"
        setupRightButtons(buttonType: .setting)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Private method
    fileprivate func setupView() {
        self.tableView.tableFooterView = UIView()
        
        // Set refreshing with target
        self.header.setRefreshingTarget(self, refreshingAction: #selector(self.refreshData))
        // add header to table view
        self.tableView.mj_header = self.header
        
        self.refreshData()
    }

    @objc fileprivate func refreshData(isShowIndicator: Bool = true) {
        if isShowIndicator {
            self.xt_startNetworkIndicatorView(withMessage: "Loading...")
        }
        xt_startNetworkIndicatorView(withMessage: "Loading...")
        API_MANAGER.requestGetTripInviteNotificationList(success: { (tripNotificationArray) in
            self.tableView.mj_header.endRefreshing()
            self.xt_stopNetworkIndicatorView()
            self.tripNotificationArray = tripNotificationArray
            self.tableView.reloadData()
        }) { (error) in
            self.tableView.mj_header.endRefreshing()
            self.xt_stopNetworkIndicatorView()
//            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: { (alerController, index) in
                self.navigationController?.popViewController(animated: true)
            })
        }
        
        API_MANAGER.requestUpdateReadAllTripPushNotification(success: {
            EVENT_NOTIFICATION_MANAGER.checkTripPushNotificationCount()
        }) { (error) in }
    }
}
extension TDNotificationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tripNotificationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tripNotification = self.tripNotificationArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationTableViewCell
        cell.setData(notificationData: tripNotification)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tripNotiData = self.tripNotificationArray[indexPath.row]
        if let notiType = tripNotiData.notiType, notiType == .tripAccepted || notiType == .acceptTrip || notiType == .liked || notiType == .commented{
            return 70
        }
        return 110
    }
}

extension TDNotificationViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Opps!", attributes: nil)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No notifications to show", attributes: nil)
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
        return #imageLiteral(resourceName: "refesh")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        button.rotateButton(animationDuration: 1, inSecond: 10)
        self.refreshData()
    }
}

extension TDNotificationViewController: NotificationTableViewCellDelegate {
    func didTapButtonWithType(tripNotificationViewCell: NotificationTableViewCell, withAction type: TripNotificationActionType, atNotification noti: TDTripNotification) {
        switch type {
            case .accept:
                if let notiId = noti.id,
                   let tripId = noti.trip?.tripId {
                    self.xt_startNetworkIndicatorView(withMessage: "Loading...")
                    API_MANAGER.requestAcceptedTrip(tripId: tripId, notificationId: notiId, success: {
                        self.refreshData(isShowIndicator: false)
                    }, failure: { (error) in
                        UIAlertController.show(in: self, withTitle: "Reminder", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                        self.refreshData(isShowIndicator: false)
                    })
                }
            case .ignore:
                if let notiId = noti.id,
                    let tripId = noti.trip?.tripId {
                    self.xt_startNetworkIndicatorView(withMessage: "Loading...")
                    API_MANAGER.requestIgnoredTrip(tripId: tripId, notificationId: notiId, success: {
                        self.refreshData(isShowIndicator: false)
                    }, failure: { (error) in
                        UIAlertController.show(in: self, withTitle: "Reminder", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                        self.refreshData(isShowIndicator: false)
                    })
            }
            case .clear:
                if let notiId = noti.id {
                    self.xt_startNetworkIndicatorView(withMessage: "Loading...")
                    API_MANAGER.requestClearTripNotification(notificationId: notiId, success: {
                        self.refreshData(isShowIndicator: false)
                    }, failure: { (error) in
                        UIAlertController.show(in: self, withTitle: "Reminder", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                        self.refreshData(isShowIndicator: false)
                    })
            }
        case .invite:
            if let ownerId = noti.sender?.id,
                let tripId = noti.trip?.tripId {
                self.xt_startNetworkIndicatorView(withMessage: "Loading...")
                API_MANAGER.requestInviteTrip(tripId: tripId, ownerId: ownerId, success: {
                    self.refreshData(isShowIndicator: false)
                }, failure: { (error) in
                    UIAlertController.show(in: self, withTitle: "Reminder", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                    self.refreshData(isShowIndicator: false)
                })
            }
        case .visitTrip:
            NotificationCenter.default.post(name: NotificationName.didCreateTripSuccess, object: nil, userInfo: nil)
        case .viewMyTrip:
            NotificationCenter.default.post(name: NotificationName.viewMyTripSuccess, object: nil, userInfo: nil)
        case .viewPicture:
            let pictureDetailVC = TDPictureDetailViewController.newInstance()
            pictureDetailVC.pictureId = noti.picture?.imageId ?? 0
            pictureDetailVC.pictureCaption = noti.picture?.caption ?? ""
            self.navigationController?.pushViewController(pictureDetailVC, animated: true)
        case .viewCity:
            let detailCityTripListVC = TDTripDetailViewController.newInstance()
            detailCityTripListVC.cityId = noti.tripCity?.id ?? 0
            detailCityTripListVC.cityName = noti.tripCity?.name ?? ""
            self.navigationController?.pushViewController(detailCityTripListVC, animated: true)
        }
    }
}
