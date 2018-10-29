//
//  TDInviteFriendsViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 1/20/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import MJRefresh
import FacebookLogin
import FacebookCore
import ObjectMapper
import Kingfisher
import FBSDKShareKit

private enum FriendSourceEnum: Int { //Enum used to determine where we're getting the friend source from
    case contacts;
    case facebook;
    case unknown;
}

protocol TDInviteFriendsViewDelegate: class {
    func inviteFriendssViewControllerDidLoadFriends();
}

class TDInviteFriendsViewController: TDBaseViewController {
    
    weak var delegate: TDInviteFriendsViewDelegate?;
    fileprivate var sourceMode: FriendSourceEnum = .unknown;
    
    // MARK:- Outlets
    @IBOutlet weak var contactsTableView: UITableView!
    
    @IBOutlet weak var facebookTableView: UITableView!//This table view is only used for displaying the empty data set content, no cells will be populated on this table view.
    
    @IBOutlet weak var searchView: UIView!
    
    @IBOutlet weak var searchTextField: UITextField!

    // MARK:- Public method
    static func newInstance() -> TDInviteFriendsViewController {
        return UIStoryboard.init(name: "MyFriends", bundle: nil).instantiateViewController(withIdentifier: "TDInviteFriendsViewController") as! TDInviteFriendsViewController
    }
    
    // MARK: Model data used for contacts source
    var contacts: [PhoneContact]?;
    
    /// List of contacts to be displayed in the contactsTableView, filtered by the keyword in the search bar
    var displayedContacts: [PhoneContact] {
        guard let contacts = self.contacts else {
            return [];
        }
        
        //Filter the contact
        
        if let searchText = searchTextField.text, searchText.length > 0 {
            let displayedContacts = contacts.filter { (contact) -> Bool in
                
                if let name = contact.contactFullName {
                    return name.uppercased.contains(self.searchTextField.text!.uppercased());
                }
                return false;
            }
            return displayedContacts;
            
        }
        return contacts;
    }
    
    var currentFriends: [AppContact]? // List of already-had friends, to be passed from previous screen if possible
    var requestedFriends: [AppContact] = [AppContact](); // List of users that received a friend request from current user, recieved from Sync Contact api.
    
    // MARK: Model data used for facebook source
    fileprivate class FacebookFriend: Mappable {
        var name: String!;
        var id: String!;
        var picture: String!;
        //MARK: Mappable
        required init?(map: Map) {
        }
        
        func mapping(map: Map) {
            name         <- map["name"]
            id         <- map["id"]
            picture         <- map["picture.data.url"];
        }
    }
    
    /*
     A cached dictionary to determined whether a PhoneContact's phone numbers exist in self.currentFriends' phone numbers. This is used for displaying the title "ADD/ADDED" for buttons in tablecell.
     We must use this cached dictionary because conventional method is too slow, which will cause lagging while scrolling.
     The key of the dict is the index of the PhoneContact object inside self.contacts,
     */
    fileprivate var contactTableStatusCache = [Int:AddFriendTableViewCell.AddFriendTableViewCellKind]()
    
    typealias ContactInfo = (phoneNumber: String, email: String);
    
    
    /// Utility method to build the data for contactTableStatusCache, to be called after contacts are synched
    fileprivate func buildcontactTableStatusCache() {
        
        //Process the friends's phone numbers by removing all white spaces
        let addedFriendsContactInfos: [ContactInfo] = {
            var result = [ContactInfo]();
            for contact in self.currentFriends! {
                
                let number = contact.contact?.replacingOccurrences(of: " ", with: "") ?? "";
                let email = contact.email ?? "";
                
                result.append((number, email));
            }
            return result;
        }();
        
        //Get the list of requested friends
        let requestedFriendsContactInfos: [(number: String, email: String)] = {
            var result = [(String,String)]();
            for contact in self.requestedFriends {
                let number = contact.contact ?? "";
                let email = contact.email ?? "";
                
                result.append((number, email));
                
            }
            return result;
        }();
        
        //Loop through the PhoneContact's phone number and compare with friendsFormattedPhoneNumbers
        for i in 0 ..< self.contacts!.count {//Unwrapping is safe because this method is only called when self.contacts exists
            let contact = self.contacts![i];
            
            if let contactName = contact.contactFullName, contactName.uppercased.contains("test".uppercased()) {
                print("Entered");
            }
            
            if contact.contactPhoneNum.count > 0 {
                var statusWasSet = false
                //A.1: loop through the phone numbers and check if there is added/requested friends by phone number
                let contacts = contact.contactPhoneNum;
                contacts.forEach({ (num) in
                    //Get list of added friends' phone numbers
                    let addedPhoneNumbers = addedFriendsContactInfos.flatMap({ (contact) -> String in
                        contact.phoneNumber;
                    })
                    
                    if (addedPhoneNumbers.contains(num)) {//Added by phone number -> Status is .added
                        contactTableStatusCache[i] = .added;
                        statusWasSet = true;
                    }
                    
                    //Get list of requested friends' phone numbers
                    let requestedPhoneNumbers = requestedFriendsContactInfos.flatMap({ (contact) -> String in
                        contact.number;
                    })
                    
                    if (requestedPhoneNumbers.contains(num)) {
                        contactTableStatusCache[i] = .requested;
                        statusWasSet = true;
                    }
                    
                })
                
                //A:2, loop through the emails and check if there is added/requested friends by email
                
                let emails = contact.contactEmail ?? [String]();
                emails.forEach({ (email) in
                    //Get list of added friends' email
                    let addedEmails = addedFriendsContactInfos.flatMap({ (contact) -> String in
                        contact.email;
                    })
                    
                    if (addedEmails.contains(email)) {
                        contactTableStatusCache[i] = .added;
                        statusWasSet = true;
                    }
                    
                    //Get list of requested friends' email
                    let requestedEmails = requestedFriendsContactInfos.flatMap({ (contact) -> String in
                        contact.email;
                    })
                    
                    if (requestedEmails.contains(email)) {
                        contactTableStatusCache[i] = .requested;
                        statusWasSet = true;
                    }
                })
                
                //if status wasn't set in this loop index,
                if (!statusWasSet) {
                    contactTableStatusCache[i] = .invite;
                }
            } else {
                contactTableStatusCache[i] = .invite;
            }
        }
    }
    
    //Load the friend list if it's not passed from previous view controller or it has zero friends
    //This method is to be called in viewDidLoad, so that self.currentFriends must be available for use
    private func loadFriendListIfNeeded() {
        var friendCount = 0;
        if let friends = currentFriends {
            friendCount = friends.count;
        }
        
        
        //If current friends not found -> Perform request to get friends
        if (friendCount == 0){
            self.xt_startNetworkIndicatorView(withMessage: "Loading app data");
            API_MANAGER.requestGetFriendList(success: { (appContacts) in
                self.xt_stopNetworkIndicatorView()
                self.currentFriends = appContacts;
                self.delegate?.inviteFriendssViewControllerDidLoadFriends();
                //After getting the friends -> Tap on Contact button as default
                self.contactButtonTapped(UIButton());
            }, failure: { (error) in
                self.xt_stopNetworkIndicatorView()
                UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "Go back", otherButtonTitles: ["Retry"], tap: { (vc, index) in
                    if (index == vc.cancelButtonIndex) {
                        self.navigationController?.popViewController(animated: true);
                    } else {
                        self.loadFriendListIfNeeded();
                    }
                })
            })
        } else {
            //Tap on Contact button as default
            self.contactButtonTapped(UIButton());
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactsTableView.tableFooterView = UIView()
        let addFriendTableViewCell = UINib(nibName: "AddFriendTableViewCell", bundle: nil)
        self.contactsTableView.register(addFriendTableViewCell, forCellReuseIdentifier: "AddFriendTableViewCell")
        
        self.facebookTableView.tableFooterView = UIView()
        self.facebookTableView.register(addFriendTableViewCell, forCellReuseIdentifier: "AddFriendTableViewCell")
        
        self.searchView.isHidden = true;
        
        //Load the friend list for later processing
        self.loadFriendListIfNeeded();
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Add Friend"
        setupRightButtons(buttonType: .setting)
    }
    
    @IBOutlet weak var contactCheckBoxImageView: UIImageView!
    
    @IBOutlet weak var facebookCheckBoxImageView: UIImageView!
    
    @IBAction func contactButtonTapped(_ sender: UIButton) {
        self.contactCheckBoxImageView.image = #imageLiteral(resourceName: "button_check");
        self.facebookCheckBoxImageView.image = #imageLiteral(resourceName: "button_unCheck");
        self.searchView.isHidden = false;
        
        self.sourceMode = .contacts;
        self.contactsTableView.superview?.bringSubview(toFront: self.contactsTableView);
        if (self.contacts == nil) {
            self.addFriendsFromContacts();
        }
    }
    
    @IBAction func facebookButtonTapped(_ sender: UIButton) {
        self.contactCheckBoxImageView.image = #imageLiteral(resourceName: "button_unCheck");
        self.facebookCheckBoxImageView.image = #imageLiteral(resourceName: "button_check");
        self.searchView.isHidden = true;
        self.sourceMode = .facebook;
        self.facebookTableView.superview?.bringSubview(toFront: self.facebookTableView);
        
        self.xt_startNetworkIndicatorView(withMessage: "Generating invite link");
        SharingManager.shared.generateDynamicLink(userId: TDUser.currentUser()!.id) { (link) in
            self.xt_stopNetworkIndicatorView();
            guard link.length > 0 else {
                self.xt_stopNetworkIndicatorView()
                UIAlertController.show(in: self, withTitle: "Error", message: "Invite link not available, please try again later", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                return;
            }
            
            let content = FBSDKShareLinkContent()
            content.contentURL = URL.init(string:link);
            let dialog = FBSDKShareDialog();
            dialog.mode = .native
            dialog.shareContent = content;
            if (dialog.canShow()) {
                dialog.show()
            } else {
                UIAlertController.show(in: self, withTitle: "Facebook not installed", message: "Please install Facebook app to enable Facebook invitation", cancelButtonTitle: "OK", otherButtonTitles: ["To Appstore"], tap: { (controller, index) in
                    if (index != controller.cancelButtonIndex) {
                        UIApplication.shared.openURL(URL.init(string: "https://itunes.apple.com/vn/app/facebook/id284882215?mt=8")!);
                    }
                })
            }
        }
    }
    
    @IBAction func searchTextDidChange(_ sender: UITextField) {
        //Reload data according to the text field's content
        self.contactsTableView.reloadData();
        //Scroll to top when refreshing the result
        if let indexPaths = self.contactsTableView.indexPathsForVisibleRows, indexPaths.count > 0 {
            self.contactsTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: false);
        }
    }
}

extension TDInviteFriendsViewController: FBSDKSharingDelegate {
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        UIAlertController.show(in: self, withTitle: "Completed", message: "Your invitation has successfully been sent", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        UIAlertController.show(in: self, withTitle: "Error", message: error.localizedDescription, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        
    }
}

//MARK: Add friends from contacts
extension TDInviteFriendsViewController {
    
    func addFriendsFromContacts() {
        //Ask for permission first
        CONTACT_MANAGER.requestForAccess { (granted) in
            if (granted) {
                
                DispatchQueue.main.async {
                    self.xt_startNetworkIndicatorView(withMessage: "Getting friends from your contacts")
                }
                
                //Using async after here because for iPhone5, the main queue is blocked by contact access, so loader wouldn't show
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.xt_startNetworkIndicatorView(withMessage: "Getting friends from your contacts")
                    //Check for cached contacts first, use it if available
                    if let contacts = CONTACT_MANAGER.deviceContacts {
                        self.contacts = contacts;
                        self.performSyncContactRequest();
                    } else {//Cached contacts not available -> Read from Contacts
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: {
                            CONTACT_MANAGER.getContactBook(completionHandler: { (contacts) in
                                self.contacts = contacts;
                                self.performSyncContactRequest();
                            })
                        })
                    }
                })
            } else {
                let permissionScope = PermissionScope()
                permissionScope.viewControllerForAlerts = self;
                permissionScope.requestContacts();
            }
        }
    }
    
    private func performSyncContactRequest() {
        API_MANAGER.requestSyncContacts2(contacts: self.contacts!, success: { newFriends, requestedFriends in
            self.currentFriends = self.currentFriends! + newFriends;//Added the list of new friends to current friend list
            self.requestedFriends = requestedFriends;
            
            self.buildcontactTableStatusCache();// Build the cache dictionary after contact is sync'ed;
            self.contactsTableView.reloadData(); // Then reload the data
            
            var addedFriends = 0;
            
            //Calculate the correct number of friends from contact, because many contacts can have the same phone number
            for friend in self.currentFriends! {
                if let friendPhoneNum = friend.contact {
                    var friendIsInContacts = false;
                    for contact in self.contacts! {
                        for contactNum in contact.contactPhoneNum {
                            if friendPhoneNum == contactNum {
                                friendIsInContacts = true;
                                break;
                            }
                        }
                        if (friendIsInContacts) {
                            addedFriends += 1;
                            break;
                        }
                    }
                }
            }
            self.delegate?.inviteFriendssViewControllerDidLoadFriends();
            
            UIAlertController.show(in: self, withTitle: "Completed", message: "You have \(addedFriends) XTrip friend(s) from your contacts", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            self.xt_stopNetworkIndicatorView();
        }, failure: { (error) in
            self.contactsTableView.reloadData();
            self.xt_stopNetworkIndicatorView();
            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        })
    }
}


import PhoneNumberKit;

extension TDInviteFriendsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    
}

extension TDInviteFriendsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.sourceMode == .contacts) {
            return self.displayedContacts.count;
        } else {
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == self.contactsTableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendTableViewCell", for: indexPath) as! AddFriendTableViewCell
            let contact = self.displayedContacts[indexPath.row]
            cell.delegate = self
            
            //Get the index of contact from the original contacts list. then use it to retrive the coresponding status cache.
            let index = self.contacts!.index(of: contact)!;//Unwrapping is safe because self.contacts must be available already
            
            //Nil check here to prevent unknown crash
            var cellKind = self.contactTableStatusCache[index];
            if (cellKind == nil) {
                cellKind = .invite;
            }
            
            cell.setData(contactData: contact, cellKind: cellKind!);
            return cell
        }
        return UITableViewCell();
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension TDInviteFriendsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "", attributes: nil)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        if (scrollView == self.contactsTableView) {
            return NSAttributedString(string: "You can add new friends from your contacts", attributes: nil)
        }
        return NSAttributedString(string:"Invite your Facebook friends to join XTrip");
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        button.rotateButton(animationDuration: 1, inSecond: 10)
        self.contactsTableView.reloadData()
    }
}

extension TDInviteFriendsViewController: AddFriendTableViewCellDelegate{
    func didTapButtonWithType(friendViewCell: AddFriendTableViewCell, withAction type: FriendActionType, atFriend friend: PhoneContact) {
        
        self.xt_startNetworkIndicatorView(withMessage: "Generating invite link");
        SharingManager.shared.generateDynamicLink(userId: TDUser.currentUser()!.id) { (link) in
            self.xt_stopNetworkIndicatorView();
            guard link.length > 0 else {
                self.xt_stopNetworkIndicatorView()
                UIAlertController.show(in: self, withTitle: "Error", message: "Invite link not available, please try again later", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                return;
            }
            
            //First, check if whatsapp is available
            var canOpenWhatsapp = false;
            let whatsappURLString = "whatsapp://send?phone=\(friend.contactPhoneNum.first ?? "")&text=Check out this awesome app: \(link)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!;//Not sure if unwrapping is safe. Need to consider later
            
            let whatsappURL = URL(string: whatsappURLString);
            if let whatsappURL = whatsappURL {
                if UIApplication.shared.canOpenURL(whatsappURL) {
                    canOpenWhatsapp = true;
                }
            }
            
            if (canOpenWhatsapp) {
                UIAlertController.showActionSheet(in: self, withTitle: "Invite \(friend.contactFullName ?? "")", message: "Please choose your invite method", cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: ["via Whatsapp", "via free SMS"], popoverPresentationControllerBlock: nil, tap: { (controller, index) in
                    
                    if (index == controller.cancelButtonIndex) {
                        return;
                    }
                    print("button index: \(index)")
                    
                    if (index == 2) {//whatsapp
                        UIApplication.shared.openURL(whatsappURL!)//Unwrapping is safe because whatsappURL must be non-nil before entering this line of code
                    } else {
                        self.sendInviteRequest(forFriend: friend, link: link);
                    }
                })
            } else {
                self.sendInviteRequest(forFriend: friend, link: link);
            }
        }
    }
    
    private func sendInviteRequest(forFriend friend: PhoneContact, link: String) {
        API_MANAGER.inviteFriend(contact: friend.contactPhoneNum.first ?? "", dynamicLink: link, success: {
            let index = self.contacts!.index(of: friend)!;//unwrapping is safe because self.contacts must exists at this moment
            self.contactTableStatusCache[index] = .invited;
            self.contactsTableView.reloadData();
            
            self.xt_stopNetworkIndicatorView()
            
            UIAlertController.show(in: self, withTitle: "Notice", message: "Invite message sent", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        }, failure: { (error) in
            self.xt_stopNetworkIndicatorView()
            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        })
    }
}
