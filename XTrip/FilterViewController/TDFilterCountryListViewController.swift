//
//  TDFilterCountryListViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 1/9/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

protocol FilterCountryListViewControllerDelegate: class {
    func didSelectFilterCountry(viewController: TDFilterCountryListViewController, filterCountryKey: (key: String?, title: String), resignFilterMode resign: Bool)
}

enum CountryTypeFilter {
    case userId
    case myPicture
    case friendTrip
}

class TDFilterCountryListViewController: UIViewController {

    // MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK:- Properties
    weak var delegate: FilterCountryListViewControllerDelegate?
    var countryTypeFilter: CountryTypeFilter = .userId
    var friendId: Int  = 0
    var countryList: [Country] = [Country]()
    var predefinedCountryCodes: [String]?;//In case we don't want to load from countryies from server, we can provide a list of country codes for this VC to display
    var currentTripPage = 0
    
    // MARK:- Public method
    static func newInstance() -> TDFilterCountryListViewController {
        return UIStoryboard.init(name: "MyPictures", bundle: nil).instantiateViewController(withIdentifier: "TDFilterCountryListViewController") as! TDFilterCountryListViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Private method
    fileprivate func setupView() {
        self.tableView.tableFooterView = UIView()
        self.refreshData()
    }
    
    @objc fileprivate func refreshData() {
        
        if let predefinedCountryCodes = self.predefinedCountryCodes {
            
            var countryList = [Country]();
            
            for countryCode in predefinedCountryCodes {
                if let countryName = countryCode.countryName {
                    var country = Country();
                    country.code = countryCode;
                    country.name = countryName;
                    countryList.append(country);
                }
            }
            
            self.countryList = countryList;
            self.tableView.reloadData();
        } else {
            xt_startNetworkIndicatorView(withMessage: "Loading...")
            switch self.countryTypeFilter {
                case .userId:
                    API_MANAGER.requestGETListCountryOfUser(userId: Int(TDUser.currentUser()?.id ?? "0")!, success: { (countryList) in
                        self.xt_stopNetworkIndicatorView()
                        self.countryList = countryList
                        self.tableView.reloadData()
                    }) { (error) in
                        self.xt_stopNetworkIndicatorView()
                        UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                }
                
                case .myPicture:
                
                    API_MANAGER.requestGETListByTripOfUser(userId: Int(TDUser.currentUser()?.id ?? "0")!, success: { (countryList) in
                        self.xt_stopNetworkIndicatorView()
                        self.countryList = countryList
                        self.tableView.reloadData()
                    }) { (error) in
                        self.xt_stopNetworkIndicatorView()
                        UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                    }
                case .friendTrip:
                    API_MANAGER.requestGETListByTripOfUser(userId: self.friendId, success: { (countryList) in
                        self.xt_stopNetworkIndicatorView()
                        self.countryList = countryList
                        self.tableView.reloadData()
                    }) { (error) in
                        self.xt_stopNetworkIndicatorView()
                        UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                    }
            }
            
        }
    }
    
    //MAK:- Action method
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapGestureTapped(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension TDFilterCountryListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            self.delegate?.didSelectFilterCountry(viewController: self, filterCountryKey: ("", ""), resignFilterMode: true)
            self.dismiss(animated: true, completion: nil)
        } else {
            let country = self.countryList[indexPath.row]
            guard let countryName = country.name else {return}
            guard let countryCode = country.code else {return}
            self.delegate?.didSelectFilterCountry(viewController: self, filterCountryKey: (countryCode, countryName), resignFilterMode: false)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension TDFilterCountryListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return self.countryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCountryCell", for: indexPath) as! FilterCountryTableViewCell
        if indexPath.section == 0 {
            cell.widthImageView.constant = 0
            cell.countryNameLabel.text = "All Countries"
            return cell
        } else {
            cell.widthImageView.constant = 30
            let country = self.countryList[indexPath.row]
            cell.countryNameLabel.text = country.name ?? ""
            if let countryCode = country.code,
               let countryImage = UIImage.init(named: countryCode) {
                cell.flagImageView.image = countryImage
            }
            return cell
        }
    }
}

