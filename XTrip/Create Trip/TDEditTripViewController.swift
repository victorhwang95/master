////
////  TDEditTripViewController.swift
////  XTrip
////
////  Created by Simon Sim on 2/2/18.
////  Copyright © 2018 Hoang Cap. All rights reserved.
////
//
//import Foundation
//
//class TDEditTripViewController: TDBaseViewController, TDDatePickerShowable {
//
//    // MARK:- Public method
//    static func newInstance() -> TDEditTripViewController {
//        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TDEditTripViewController") as! TDEditTripViewController
//    }
//
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var stackView: UIStackView!
//    @IBOutlet weak var tripNameTextField: UITextField!
//    @IBOutlet weak var endDateLabel: UILabel!
//    @IBOutlet weak var startDateLabel: UILabel!
//
//    var i = 0;
//
//    var trip:TDTrip = TDTrip()
//
//    var selectedCountryCodes = [String]();
//
//    var startDate = Date() {
//        didSet {
//            if (self.endDate <= self.startDate) {
//                self.endDate = self.startDate;
//                self.reloadSelectedDate();
//            }
//        }
//    }
//    var endDate = Date();
//
//    var appContactList: [AppContact] = [AppContact]()
//
//    weak var selectingDateLabel: UILabel?//Determine whether the date being selected is for startDate or endDate
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.tableView.tableFooterView = UIView()
//        let myFriendsTableViewCell = UINib(nibName: "MyFriendsTableViewCell", bundle: nil)
//
//        self.tableView.register(myFriendsTableViewCell, forCellReuseIdentifier: "MyFriendsTableViewCell")
//
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Save", style: .done, target: self, action: #selector(saveTapped))
//
//        self.startDateLabel.text = self.startDate.string(format: .custom("dd-MM-yyyy"), in: nil);
//
//        self.endDateLabel.text = self.endDate.string(format: .custom("dd-MM-yyyy"), in: nil);
//
//        self.refreshData()
//    }
//
//    @IBAction func countryButtonTapped(_ sender: Any) {
//        let vc = TDCountrySelectionViewController.loadFromStoryboard()
//        vc.allowsMultipleSelection = true
//        vc.showUnknownCountry = true
//        vc.selectedCountryCodes = self.selectedCountryCodes
//        vc.delegate = self
//        let nav = UINavigationController.init(rootViewController: vc)
//        self.navigationController?.present(nav, animated: true, completion: nil)
//    }
//
//    @IBAction func startDateButtonTapped(_ sender: UIButton) {
//
//        self.selectingDateLabel = self.startDateLabel;
//
//
//
//        TDDatePickerViewController.sharedController.minimumDate = Date.init(timeIntervalSince1970: 0);//Reset minimum date to the past while picking startDate
//
//        TDDatePickerViewController.sharedController.dateToShow = self.startDate;
//
//        TDDatePickerViewController.sharedController.delegate = self;
//
//        self.showDatePicker();
//    }
//
//    @IBAction func endDateButtonTapped(_ sender: UIButton) {
//
//        self.selectingDateLabel = self.endDateLabel;
//
//        TDDatePickerViewController.sharedController.minimumDate = self.startDate;//force endDate to be at least equal to startDate
//
//        TDDatePickerViewController.sharedController.dateToShow = self.endDate;
//
//        TDDatePickerViewController.sharedController.delegate = self;
//        self.showDatePicker();
//    }
//
//    func saveTapped() {
//        guard let name = self.tripNameTextField.text, !name.isBlank else {
//            UIAlertController.show(in: self, withTitle: "Reminder", message: "Please enter trip's name", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
//            return
//        }
//
//        if self.selectedCountryCodes.count == 0 {
//            UIAlertController.show(in: self, withTitle: "Reminder", message: "Please choose countries", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
//            return
//        }
//
//        self.showAlertWithTitle("Message", message: "Please notes that remove country will remove its photos as well. Confirm update trip?", okButton: "OK", alertViewType: UIAlertControllerStyle.alert, okHandler: { (alertAction) in
//            self.submitData();
//        }, closeButton: "Cancel", closeHandler: nil, completionHanlder: nil)
//
//    }
//
//    fileprivate func submitData() {
//        self.xt_startNetworkIndicatorView(withMessage: "Updating ...")
//
//        // Firebase analytics
//        FIR_MANAGER.sendAppEvent(withEvent: FIREvent.EDIT_TRIP_FUNCTION.rawValue, userId: nil)
//
//        API_MANAGER.requestUpdateTrip(tripId: self.trip.tripId!, tripName: self.tripNameTextField.text!, description: "", startDate: self.startDate, endDate: self.endDate, countryCodes: self.selectedCountryCodes, success: { (trip) in
//            self.xt_stopNetworkIndicatorView()
//            self.navigationController?.popViewController(animated: true)
//        }) { (error) in
//            log.debug("error :" + error.message)
//            self.xt_stopNetworkIndicatorView()
//            UIAlertController.show(in: self, withTitle: "Could not edit trip", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil);
//        }
//    }
//
//    fileprivate func refreshData() {
//        if trip.tripId == nil {
//            log.debug("no data !!!!")
//            self.navigationController?.popViewController(animated: true)
//            return
//        }
//        xt_startNetworkIndicatorView(withMessage: "Loading...")
//        API_MANAGER.requestGetTripById(tripId: self.trip.tripId!, success: { (tripData) in
//            self.xt_stopNetworkIndicatorView()
//            self.trip = tripData as TDTrip
//            log.debug(self.trip.debugDescription)
//            self.updateView()
//        }) { (error) in
//            self.xt_stopNetworkIndicatorView()
//            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
//        }
//    }
//
//    fileprivate func updateView() {
//        if trip.tripId == nil {
//            self.navigationController?.popViewController(animated: true)
//            return
//        }
////        log.info(self.trip)
//        self.tripNameTextField.text = self.trip.name
//        self.startDate = NSDate.init(timeIntervalSince1970: self.trip.startDate!) as Date
//        self.endDate = NSDate.init(timeIntervalSince1970: self.trip.endDate!) as Date
//        self.startDateLabel.text = self.startDate.string(format: .custom("dd-MM-yyyy"), in: nil);
//        self.endDateLabel.text = self.endDate.string(format: .custom("dd-MM-yyyy"), in: nil);
//        // update country list
//        if let tripSchedules = self.trip.tripSchedule {
//            for tripSchedule in tripSchedules {
//                self.selectedCountryCodes.append(tripSchedule.countryCode!)
//            }
//            self.displaySelectedCountries(countryCodes: self.selectedCountryCodes)
//        }
//    }
//}
//
//private extension TDEditTripViewController {
//
//
//    /// Check for input data validation
//    ///
//    /// - Returns: true if all inputs are valid
//    func validateData() -> Bool {
//        //TODO: Implement here
//        return true;
//    }
//
//
//    /// Display the list of country in stack view based on selected country codes
//    ///
//    /// - Parameter countryCodes: selected country codess
//    func displaySelectedCountries(countryCodes: [String]) {
//        //First, remove all current views
//        self.stackView.subviews.forEach { (view) in
//            view.removeFromSuperview();
//        }
//
//        //Then add new views
//        countryCodes.forEach { (code) in
//            let countryView = TDCountryRoundedView.viewFromNib() as! TDCountryRoundedView;
//            countryView.countryLabel.text = code.countryName! ;
//
//            countryView.countryLabel.sizeToFit();
//            countryView.snp.makeConstraints({ (maker) in
//                maker.width.equalTo(countryView.countryLabel.width + 10);// + 10pt for trailing and leading spaces
//            })
//            self.stackView.addArrangedSubview(countryView);
//        }
//    }
//
//    func reloadSelectedDate() {
//        self.startDateLabel.text = self.startDate.string(format: .custom("dd-MM-yyyy"), in: nil);
//        self.endDateLabel.text = self.endDate.string(format: .custom("dd-MM-yyyy"), in: nil);
//    }
//
//}
//
//extension TDEditTripViewController: TDDatePickerViewDelegate {
//    func datePickerViewDidSelect(date: Date) {
//        if (self.selectingDateLabel == self.startDateLabel) {
//            self.startDate = date;
//        } else {
//            self.endDate = date;
//        }
//        self.reloadSelectedDate();
//    }
//}
//
//extension TDEditTripViewController: TDCountrySelectionViewDelegate {
//    func countrySelectionViewDidPickCountryCodes(_ codes: [String]) {
//
//        self.selectedCountryCodes = codes;
//
//        self.displaySelectedCountries(countryCodes: codes)
//    }
//}

