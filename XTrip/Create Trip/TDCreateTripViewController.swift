//
//  TDCreateTripViewController.swift
//  XTrip
//
//  Created by Hoang Cap on 11/29/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation
import SnapKit

protocol CreateTripViewControllerDelegate: class {
    func didCreateTripSuccess(viewController: TDCreateTripViewController, tripData trip: TDTrip)
}

class TDCreateTripViewController: TDBaseViewController, TDDatePickerShowable {
    
    // MARK:- Public method
    static func newInstance() -> TDCreateTripViewController {
        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TDCreateTripViewController") as! TDCreateTripViewController
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tripNameTextField: UITextField!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var countryFilterNameLabel: UILabel!
    
    weak var delegate: CreateTripViewControllerDelegate?
    
    var i = 0;
    
    var selectedCountryCodes = [String]();
    
    fileprivate var countryFilterKey: String?
    
    var startDate = Date() {
        didSet {
            if (self.endDate <= self.startDate) {
                self.endDate = self.startDate;
                self.reloadSelectedDate();
            }
        }
    }
    var endDate = Date();
    
    var appContactList: [AppContact] = [AppContact]()
    
    var displayedContactList: [AppContact] {
        var contacts = self.appContactList;
        if let countryCode = self.countryFilterKey {
            contacts = contacts.filter({ (contact) -> Bool in
                contact.country == countryCode;
            })
        }
        return contacts
    }
    
    
    var inviteFriendIdArray: [Int] = []
    var joinedFriendIdArray: [Int] = []
    var chooseFriend: [String] = []
    var enterFromDashBoard: Bool = true
    
    var editTrip:TDTrip!
    
    weak var selectingDateLabel: UILabel?//Determine whether the date being selected is for startDate or endDate
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        let myFriendsTableViewCell = UINib(nibName: "MyFriendsTableViewCell", bundle: nil)
        
        self.tableView.register(myFriendsTableViewCell, forCellReuseIdentifier: "MyFriendsTableViewCell")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Save", style: .done, target: self, action: #selector(saveTapped))
        
        self.startDateLabel.text = self.startDate.format(with: "dd-MM-yyyy");
        
        self.endDateLabel.text = self.endDate.format(with: "dd-MM-yyyy");
        
        self.refreshData()
    }
    
    @IBAction func countryButtonTapped(_ sender: Any) {
        let vc = TDCountrySelectionViewController.loadFromStoryboard();
        vc.allowsMultipleSelection = true;
        vc.delegate = self;
        vc.selectedCountryCodes = self.selectedCountryCodes;
        let nav = UINavigationController.init(rootViewController: vc);
        self.navigationController?.present(nav, animated: true, completion: nil);
    }
    
    @IBAction func startDateButtonTapped(_ sender: UIButton) {
        
        self.selectingDateLabel = self.startDateLabel;
        
        
        
        TDDatePickerViewController.sharedController.minimumDate = Date.init(timeIntervalSince1970: 0);//Reset minimum date to the past while picking startDate
        
        TDDatePickerViewController.sharedController.dateToShow = self.startDate;
        
        TDDatePickerViewController.sharedController.delegate = self;
        
        self.showDatePicker();
    }
    
    @IBAction func endDateButtonTapped(_ sender: UIButton) {
        
        self.selectingDateLabel = self.endDateLabel;
        
        TDDatePickerViewController.sharedController.minimumDate = self.startDate;//force endDate to be at least equal to startDate
        
        TDDatePickerViewController.sharedController.dateToShow = self.endDate;
        
        TDDatePickerViewController.sharedController.delegate = self;
        self.showDatePicker();
    }
    
    @IBAction func filterTripButtonTapped(_ sender: UIButton) {
        let filterCountryVC = TDFilterCountryListViewController.newInstance()
        filterCountryVC.delegate = self
        let countryList = self.appContactList.flatMap { (contact) -> String in
            contact.country!
        }
        
        let uniqueCountryCodes = Array(Set(countryList))
        filterCountryVC.predefinedCountryCodes = uniqueCountryCodes;
        
        self.present(filterCountryVC, animated: true, completion: nil)
    }
    
    @IBAction func addFriendTapped(_ sender: UIButton) {
        let vc = TDInviteFriendsViewController.newInstance();
        vc.currentFriends = self.appContactList;
        vc.delegate = self;
        self.navigationController?.pushViewController(vc, animated: true);
    }
    
    func saveTapped() {
        guard let name = self.tripNameTextField.text, !name.isBlank else {
            UIAlertController.show(in: self, withTitle: "Reminder", message: "Please enter trip's name", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            return
        }
        
        if self.selectedCountryCodes.count == 0 {
            UIAlertController.show(in: self, withTitle: "Reminder", message: "Please choose countries", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            return
        }
        
        
        for inviteFriendId in inviteFriendIdArray {
            self.chooseFriend.append(String(inviteFriendId))
        }
        
        // Firebase analytics
        FIR_MANAGER.sendAppEvent(withEvent: FIREvent.CREATE_TRIP_FUNCTION.rawValue, userId: nil)
        if self.editTrip != nil {
            self.xt_startNetworkIndicatorView(withMessage: "Updating trip")
            API_MANAGER.requestUpdateTrip(tripId: self.editTrip.tripId!, tripName: name, description: "", startDate: self.startDate, endDate: self.endDate, countryCodes: self.selectedCountryCodes, friendId: self.chooseFriend , success: { (trip) in
                self.xt_stopNetworkIndicatorView()
                if self.enterFromDashBoard {
                    self.navigationController?.popToRootViewController(animated: false)
                    // Push notification center to enter my trip page
                    NotificationCenter.default.post(name: NotificationName.didCreateTripSuccess, object: nil, userInfo: nil)
                } else {
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.didCreateTripSuccess(viewController: self, tripData: trip)
                }
            }) { (error) in
                self.xt_stopNetworkIndicatorView();
                UIAlertController.show(in: self, withTitle: "Could not edit trip", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil);
            }
        } else {
            self.xt_startNetworkIndicatorView(withMessage: "Adding new trip")
            API_MANAGER.requestCreateTrip(tripName: name, description: "", startDate: self.startDate, endDate: self.endDate, countryCodes: self.selectedCountryCodes, friendId: self.chooseFriend , success: { (trip) in
                self.xt_stopNetworkIndicatorView()
                if self.enterFromDashBoard {
                    self.navigationController?.popToRootViewController(animated: false)
                    // Push notification center to enter my trip page
                    NotificationCenter.default.post(name: NotificationName.didCreateTripSuccess, object: nil, userInfo: nil)
                } else {
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.didCreateTripSuccess(viewController: self, tripData: trip)
                }
            }) { (error) in
                self.xt_stopNetworkIndicatorView();
                UIAlertController.show(in: self, withTitle: "Could not create trip", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil);
            }
        }
    }
    
    fileprivate func refreshData() {
        xt_startNetworkIndicatorView(withMessage: "Loading...")
        API_MANAGER.requestGetFriendList(success: { (appContactArray) in
            self.appContactList = appContactArray
            self.tableView.reloadData()
        
            // Load  data in case edit trip
            if self.editTrip != nil {
                self.loadCurrentData()
            } else {
                self.xt_stopNetworkIndicatorView()
            }
        }) { (error) in
            self.xt_stopNetworkIndicatorView()
            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        }
    }
    
    fileprivate func loadCurrentData() {
       
        if editTrip.tripId == nil {
            log.debug("no data !!!!")
            self.navigationController?.popViewController(animated: true)
            return
        }
        API_MANAGER.requestGetTripById(tripId: self.editTrip.tripId!, success: { (tripData) in
            self.xt_stopNetworkIndicatorView()
            self.editTrip = tripData
            self.updateView()
        }) { (error) in
            self.xt_stopNetworkIndicatorView()
//            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: { (alerController, index) in
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    fileprivate func updateView() {
        if editTrip.tripId == nil {
            self.navigationController?.popViewController(animated: true)
            return
        }
        self.tripNameTextField.text = self.editTrip.name
        self.startDate = NSDate.init(timeIntervalSince1970: self.editTrip.startDate!) as Date
        self.endDate = NSDate.init(timeIntervalSince1970: self.editTrip.endDate!) as Date
        self.startDateLabel.text = self.startDate.toFormat("dd-MM-yyyy");
        self.endDateLabel.text = self.endDate.toFormat("dd-MM-yyyy");
        // update country list
        if let tripSchedules = self.editTrip.tripSchedule {
            for tripSchedule in tripSchedules {
                self.selectedCountryCodes.append(tripSchedule.countryCode!)
            }
            self.displaySelectedCountries(countryCodes: self.selectedCountryCodes)
        }
        // joinedFriendIdArray
        self.joinedFriendIdArray.removeAll()
        if let userJoinTripArray = editTrip.userJoinTrip {
            
            for displayedOneContact in self.displayedContactList {
                var allowAdd = false
                for user in userJoinTripArray {
                    if Int(user.id) == displayedOneContact.id {
                        allowAdd = true
                        break
                    }
                }
                
                if allowAdd {
                    self.joinedFriendIdArray.append(displayedOneContact.id ?? 0)
                }
            }
            self.tableView.reloadData()
        }
        
        
    }
    
}

private extension TDCreateTripViewController {
    
    
    /// Check for input data validation
    ///
    /// - Returns: true if all inputs are valid
    func validateData() -> Bool {
        //TODO: Implement here
        return true;
    }
    
    
    /// Display the list of country in stack view based on selected country codes
    ///
    /// - Parameter countryCodes: selected country codess
    func displaySelectedCountries(countryCodes: [String]) {
        //First, remove all current views
        self.stackView.subviews.forEach { (view) in
            view.removeFromSuperview();
        }
        
        //Then add new views
        countryCodes.forEach { (code) in
            let countryView = TDCountryRoundedView.viewFromNib() as! TDCountryRoundedView;
            countryView.countryLabel.text = code.countryName!;
            
            countryView.countryLabel.sizeToFit();
            countryView.snp.makeConstraints({ (maker) in
                maker.width.equalTo(countryView.countryLabel.width + 10);// + 10pt for trailing and leading spaces
            })
            self.stackView.addArrangedSubview(countryView);
        }
    }
    
    func reloadSelectedDate() {
        self.startDateLabel.text = self.startDate.format(with: "dd-MM-yyyy");
        self.endDateLabel.text = self.startDate.format(with: "dd-MM-yyyy");
    }
}

extension TDCreateTripViewController: TDDatePickerViewDelegate {
    func datePickerViewDidSelect(date: Date) {
        if (self.selectingDateLabel == self.startDateLabel) {
            self.startDate = date;
        } else {
            self.endDate = date;
        }
        self.reloadSelectedDate();
    }
}

extension TDCreateTripViewController: TDCountrySelectionViewDelegate {
    func countrySelectionViewDidPickCountryCodes(_ codes: [String]) {
        
        self.selectedCountryCodes = codes;
        
        self.displaySelectedCountries(countryCodes: codes)
    }
}

extension TDCreateTripViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayedContactList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contact = self.displayedContactList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyFriendsTableViewCell", for: indexPath) as! MyFriendsTableViewCell
        cell.setData(contactData: contact, inviteArray: self.inviteFriendIdArray, isInvite: true, joinedFriendIdArray: self.joinedFriendIdArray)
        cell.delegate = self
        return cell
    }
}

extension TDCreateTripViewController: MyFriendsTableViewCellDelegate {
    func didTapButtonWithType(friendViewCell: MyFriendsTableViewCell, withAction type: FriendActionType, atFriend friend: AppContact) {
        if (self.inviteFriendIdArray.contains(friend.id ?? 0)) {
            self.inviteFriendIdArray.remove(friend.id ?? 0)
            self.tableView.reloadData()
        } else {
            self.inviteFriendIdArray.append(friend.id ?? 0)
            self.tableView.reloadData()
        }
    }
}

extension TDCreateTripViewController: TDInviteFriendsViewDelegate {
    func inviteFriendssViewControllerDidLoadFriends() {
        self.reloadFriendsInBackground(maximumTries: 5);
    }
    
    /// Silently request friends in background with retries
    ///
    /// - Parameters:
    ///   - counter: flag to determine whether to retry or not
    ///   - tries: maximum number of retries
    private func reloadFriendsInBackground(_ counter:Int = 0, maximumTries tries: Int) {
        print("Friends reloading...")
        if (counter == tries) {//Reached maximum retries -> Stop
            return;
        }
        
        API_MANAGER.requestGetFriendList(success: { (appContactArray) in
            self.appContactList = appContactArray
            self.tableView.reloadData()
        }) { (error) in
            self.reloadFriendsInBackground(counter + 1, maximumTries: tries);//Increase counter and retry
        }
    }
}

extension TDCreateTripViewController: FilterCountryListViewControllerDelegate {
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


