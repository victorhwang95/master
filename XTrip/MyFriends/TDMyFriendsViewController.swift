//
//  TDMyFriendsViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 12/23/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import MJRefresh
import Kingfisher

extension AppContact: Hashable {
    static func ==(lhs: AppContact, rhs: AppContact) -> Bool {
        return lhs.id == rhs.id;
    }
    
    var hashValue: Int {
        if let id = self.id {
            return id.hashValue;
        }
        
        return 0;
    }
}
class TDMyFriendsViewController: TDBaseViewController {

    // MARK:- Properties
//    var totalPushCount: Int = 0
    var appContactList: [AppContact] = [AppContact]()
    var requestingContactList: [AppContact] = [AppContact]()
    fileprivate var requestStatusCache:[AppContact: TDMyFriendRequestTableCell.RequestStatus] = [:];//List of cached status of the friend requests (to handle the cells after accepting/ignoring).
    
    let header = MJRefreshNormalHeader()
    
    var displayFriends: [AppContact] {
        
        var friendList = appContactList;
        
        //First, filter by search text
        if let text = searchTextField.text, text.length > 0 {
            friendList = friendList.filter({ (contact) -> Bool in
                if let name = contact.name {
                    return name.uppercased().contains(text.uppercased());
                } else {
                    return false;
                }
            })
        }
        
        //Second, filter by selected country
        if let filterCountryCode = self.countryFilterKey {
            friendList = friendList.filter({ (contact) -> Bool in
                contact.country == filterCountryCode;
            })
        }
        
        return friendList;
    }
    
    var displayRequests: [AppContact] {
        if let text = searchTextField.text, text.length > 0 {
            let requestList = requestingContactList.filter({ (contact) -> Bool in
                if let name = contact.name {
                    return name.uppercased().contains(text.uppercased());
                } else {
                    return false;
                }
            })
            
            return requestList;
        }
        
        return requestingContactList;
    }
    
    var displayContacts: [AppContact] {
        return self.displayRequests + self.displayFriends;
    }
    
    fileprivate var hasFriendLoaded = false
    fileprivate var countryFilterKey: String?
    
    // MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var countryFilterNameLabel: UILabel!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    // MARK:- Public method
    static func newInstance() -> TDMyFriendsViewController {
        return UIStoryboard.init(name: "MyFriends", bundle: nil).instantiateViewController(withIdentifier: "TDMyFriendsViewController") as! TDMyFriendsViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "My Friends"
        setupRightButtons(buttonType: .setting)
        setupNavigationButton()
        EVENT_NOTIFICATION_MANAGER.checkTripPushNotificationCount()
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.setupView();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Private method
    fileprivate func setupView() {
        self.tableView.tableFooterView = UIView()
        let myFriendsTableViewCell = UINib(nibName: "MyFriendsTableViewCell", bundle: nil)
        self.tableView.register(myFriendsTableViewCell, forCellReuseIdentifier: "MyFriendsTableViewCell")
        
        // Set refreshing with target
        self.header.setRefreshingTarget(self, refreshingAction: #selector(self.refreshData))
        // add header to table view
        self.tableView.mj_header = self.header
        EVENT_NOTIFICATION_MANAGER.delegateFriend = self
        self.tableView.reloadData()
        xt_startNetworkIndicatorView(withMessage: "Loading...")
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.refreshData()
                }
        }
    }
    
    @objc fileprivate func refreshData() {
        // Firebase analytics
        FIR_MANAGER.sendAppEvent(withEvent: FIREvent.LOAD_FRIEND_FUNCTION.rawValue, userId: nil)
        
        API_MANAGER.requestGetFriendList(success: { (appContactArray) in
            API_MANAGER.requestGetFriendRequests(success: { (requestingContacts) in
                
                self.tableView.mj_header.endRefreshing()
                self.xt_stopNetworkIndicatorView()
                
                //Sort the contact by name
                self.requestingContactList = requestingContacts.sorted(by: { (c1, c2) -> Bool in
                    //Both contacts have names -> Compare them
                    if let name1 = c1.name, let name2 = c2.name {
                        return name1.caseInsensitiveCompare(name2) == ComparisonResult.orderedDescending;
                    } else if (c1.name != nil){
                        return true;
                    } else {
                        return false;
                    }
                });
                
                //Initially set all the friend requests' status to .pending
                self.requestingContactList.forEach({ (contact) in
                    self.requestStatusCache[contact] = .pending;
                })
                
                self.appContactList = appContactArray
                self.hasFriendLoaded = true
                self.tableView.reloadData()
                
                // set new value notification count
                API_MANAGER.requestUpdateReadAllFriendPushNotification(success: {
                    EVENT_NOTIFICATION_MANAGER.checkTripPushNotificationCount()
                }) { (error) in }

            }, failure: { (error) in
                self.hasFriendLoaded = true
                self.tableView.mj_header.endRefreshing()
                self.xt_stopNetworkIndicatorView()
                UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            })
        }) { (error) in
            self.hasFriendLoaded = true
            self.tableView.mj_header.endRefreshing()
            self.xt_stopNetworkIndicatorView()
            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        }
    }
    
    //MARK:- Action
    
    @IBAction func searchPhoneTextFieldChanged(_ textField: UITextField) {
        self.tableView.reloadData();
    }
    
    @IBAction func tripButtonTapped(_ sender: UIButton) {
        let filterCountryVC = TDFilterCountryListViewController.newInstance()
        filterCountryVC.delegate = self
        let countryList = self.appContactList.flatMap { (contact) -> String in
            contact.country!
        }
        
        let uniqueCountryCodes = Array(Set(countryList))
        filterCountryVC.predefinedCountryCodes = uniqueCountryCodes;
        self.present(filterCountryVC, animated: true, completion: nil)
    }
    
    @IBAction func addFriendButtonTapped(_ sender: UIButton) {
        let inviteFriendsVC = TDInviteFriendsViewController.newInstance()
        inviteFriendsVC.delegate = self;
        inviteFriendsVC.currentFriends = self.appContactList;
        self.navigationController?.pushViewController(inviteFriendsVC, animated: true)
    }
}

extension TDMyFriendsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayContacts.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let contact = self.displayContacts[indexPath.row];
        
        //If the current indexPath belongs to the request list -> Treat it as friend request
        if (indexPath.row < self.displayRequests.count) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TDMyFriendRequestTableCell", for: indexPath) as! TDMyFriendRequestTableCell
            cell.delegate = self;
            //Retrieve the request status from cache,
            if let status = self.requestStatusCache[contact] {
                cell.setData(fromAppContact: contact, withStatus: status);
            } else {//If status is somehow not found -> dispay with .pending status
                cell.setData(fromAppContact: contact, withStatus: .pending);
            }

            return cell;
        }
        
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyFriendsTableViewCell", for: indexPath) as! MyFriendsTableViewCell
            
            cell.setData(contactData: contact, inviteArray: [], joinedFriendIdArray: [])
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row < self.displayRequests.count) {
            return 100;
        } else {
            return 90
        }
    }
}

extension TDMyFriendsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Opps!", attributes: nil)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No friends to show", attributes: nil)
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
        return #imageLiteral(resourceName: "refesh")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        button.rotateButton(animationDuration: 1, inSecond: 10)
        self.refreshData()
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return self.hasFriendLoaded
    }
}

extension TDMyFriendsViewController: MyFriendsTableViewCellDelegate {
    func didTapButtonWithType(friendViewCell: MyFriendsTableViewCell, withAction type: FriendActionType, atFriend friend: AppContact) {
        if type == .delete {
            _ = self.showAlertWithTitle(nil, message: "Are you sure you want to delete?", okButton: "YES", alertViewType:.alert, okHandler: { (actionSheet) in
                self.xt_startNetworkIndicatorView(withMessage: "Deleting...")
                API_MANAGER.requestDeleteFriend(friendId: friend.id ?? 0, success: {
                    var indexToDelete = 0;
                    for i in 0 ... self.appContactList.count {
                        let c = self.appContactList[i];
                        if (c.id == friend.id) {
                            indexToDelete = i;
                            break;
                        }
                    }
                    self.appContactList.remove(at: indexToDelete);
                    self.xt_stopNetworkIndicatorView()
                    self.tableView.reloadData();
                }, failure: { (error) in
                    self.xt_stopNetworkIndicatorView()
                    UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                })
            }, closeButton: "NO THANKS", closeHandler: { (actionSheet) in }, completionHanlder: nil)
        } else if type == .viewProfile {
            guard let userId = friend.id else {return}
            let friendInfoVC = TDFriendProfileViewController.newInstance()
            friendInfoVC.userId = "\(userId)"
            self.navigationController?.pushViewController(friendInfoVC, animated: true)
        }
    }
}

extension TDMyFriendsViewController: TDMyFriendRequestTableCellDelegate {
    
    func friendRequestCellDidTapToEnterProfile(cell: TDMyFriendRequestTableCell, withAppContact contact: AppContact) {
        guard let userId = contact.id else {return}
        let friendInfoVC = TDFriendProfileViewController.newInstance()
        friendInfoVC.userId = "\(userId)"
        self.navigationController?.pushViewController(friendInfoVC, animated: true)
        
    }
    
    func friendRequestCellDidTapOnAccept(cell: TDMyFriendRequestTableCell, withAppContact contact: AppContact) {
        print("Accepted")
        self.requestAcceptFriendRequest(forContact: contact);
    }
    
    func friendRequestCellDidTapOnIgnore(cell: TDMyFriendRequestTableCell, withAppContact contact: AppContact) {
        print("Ignored")
        self.requestIgnoreFriendRequest(forContact: contact);
    }
    
    private func requestAcceptFriendRequest(forContact: AppContact) {
        self.xt_startNetworkIndicatorView(withMessage: "Accepting friend request");
        API_MANAGER.requestAcceptFriendRequest(friendId: forContact.id!, success: {
            self.xt_stopNetworkIndicatorView()
            self.requestStatusCache[forContact] = .accepted;//Set new status for the cell
            self.tableView.reloadData();
        }) { (error) in
            self.xt_stopNetworkIndicatorView()
            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        }
    }
    
    private func requestIgnoreFriendRequest(forContact: AppContact) {
        self.xt_startNetworkIndicatorView(withMessage: "Ignoring friend request");
        API_MANAGER.requestIgnoreFriendRequest(friendId: forContact.id!, success: {
            self.xt_stopNetworkIndicatorView();
            self.requestStatusCache[forContact] = .ignored;//Set new status for the cell
            self.tableView.reloadData();
        }) { (error) in
            self.xt_stopNetworkIndicatorView()
            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil);
        }
    }
}

extension TDMyFriendsViewController: EvenNotificationManagerDelegate {
    func didGetNewTripPushNotification(count: Int) {
//        self.totalPushCount = count
        self.notificationBarView?.setData(count: count)
    }
    
    func redirectTripPushToDetailPage() {
        self.notificationButtonTapped()
    }
}

extension TDMyFriendsViewController: FilterCountryListViewControllerDelegate {
    func didSelectFilterCountry(viewController: TDFilterCountryListViewController, filterCountryKey: (key: String?, title: String), resignFilterMode resign: Bool) {
        if resign {
            self.countryFilterKey = nil
            self.countryFilterNameLabel.text = "All Countries"
        } else {
            self.countryFilterKey = filterCountryKey.key
            self.countryFilterNameLabel.text = filterCountryKey.title
        }
        self.refreshData()
    }
}

extension TDMyFriendsViewController: TDInviteFriendsViewDelegate {
    func inviteFriendssViewControllerDidLoadFriends() {
        self.reloadFriendsInBackground(maximumRetries: 5);
    }
    
    /// Silently request friends in background with retries
    ///
    /// - Parameters:
    ///   - tries: maximum number of retries
    private func reloadFriendsInBackground(maximumRetries tries: Int) {
        print("Friends reloading...")
        if (tries == 0) {//Reached maximum retries -> Stop
            return;
        }
        API_MANAGER.requestGetFriendList(success: { (appContactArray) in
            self.searchTextField.text = nil;
            self.appContactList = appContactArray
            self.tableView.reloadData()
        }) { (error) in
            self.reloadFriendsInBackground(maximumRetries: tries - 1);
        }
    }
}

protocol TDMyFriendRequestTableCellDelegate: class {
    func friendRequestCellDidTapOnAccept(cell: TDMyFriendRequestTableCell, withAppContact contact: AppContact);
    func friendRequestCellDidTapOnIgnore(cell: TDMyFriendRequestTableCell, withAppContact contact: AppContact);
    func friendRequestCellDidTapToEnterProfile(cell: TDMyFriendRequestTableCell, withAppContact contact: AppContact);
}

class TDMyFriendRequestTableCell: UITableViewCell {
    
    weak var delegate:TDMyFriendRequestTableCellDelegate?;
    
    fileprivate enum RequestStatus {//Enum for determining a status of a friend request
        case pending;
        case accepted;
        case ignored;
    }
    
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendImageView: UIImageView!

    @IBOutlet weak var clearView: RoundedView!
    @IBOutlet weak var statusResultLabel: UILabel!
    
    @IBOutlet weak var buttonView: UIStackView!
    weak var appContact: AppContact!
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        self.delegate?.friendRequestCellDidTapOnAccept(cell: self, withAppContact: self.appContact)
    }
    
    @IBAction func ignoreButtonTapped(_ sender: Any) {
        self.delegate?.friendRequestCellDidTapOnIgnore(cell: self, withAppContact: self.appContact)
    }
    
    @IBAction func viewProfileButtonTapped(_ sender: UIButton) {
        self.delegate?.friendRequestCellDidTapToEnterProfile(cell: self, withAppContact: self.appContact);
    }
    
    fileprivate func setData(fromAppContact contact:AppContact, withStatus: RequestStatus) {
        self.appContact = contact;
        self.friendNameLabel.text = contact.name
        if let utlStr = contact.profilePicture,
            let url = URL(string: utlStr) {
            _ = self.friendImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "avatar_placeholder"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                
            },completionHandler: { image, error, cacheType, imageURL in
                
            })
        }
        
        switch withStatus {
        case .accepted:
            self.statusResultLabel.text = "ACCEPTED"
            self.statusResultLabel.textColor = .black;
            self.clearView.backgroundColor = .white;
            self.buttonView.alpha = 0;
            self.clearView.alpha = 1;
            break;
        case .ignored:
            self.statusResultLabel.text = "IGNORED"
            self.statusResultLabel.textColor = .red;
            self.clearView.backgroundColor = .white;
            self.buttonView.alpha = 0;
            self.clearView.alpha = 1;
            break;
        case .pending:
            self.buttonView.alpha = 1;
            self.clearView.alpha = 0;
            break;
        }
    }
}

