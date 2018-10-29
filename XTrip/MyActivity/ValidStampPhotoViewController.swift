//
//  ValidStampPhotoViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 2/11/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import CoreLocation

protocol ValidStampPhotoViewControllerDelegate: class {
    func didSelectValidStamp(viewController: ValidStampPhotoViewController, validStamp: ValidStamp?)
}

extension Array {
    func unique<T:Hashable>(map: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }
        
        return arrayOrdered
    }
}

class ValidStampPhotoViewController: UIViewController {
    
    // MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK:- Properties
    weak var delegate:ValidStampPhotoViewControllerDelegate?
    var validStampArray: [ValidStamp] = [ValidStamp]()
    var validStampFilterArray: [ValidStamp] = [ValidStamp]()
    var validStampDuplicateArray: [ValidStamp] = [ValidStamp]()
    var currentStampCountryInfo: TDLocalCountry?
    let stampSerialQueue = DispatchQueue(label: "com.XTrip.stampQueue")
    var indexStamp: Int = 0
    var removeIndexFilterArray: [Int] = []
    
    // MARK:- Public method
    static func newInstance() -> ValidStampPhotoViewController {
        return UIStoryboard.init(name: "MyActivity", bundle: nil).instantiateViewController(withIdentifier: "ValidStampPhotoViewController") as! ValidStampPhotoViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        
        // Do any additional setup after loading the view.
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
        xt_startNetworkIndicatorView(withMessage: "Loading...")
        STAMP_MANAGER.setTripStatusDelegate(self)
        STAMP_MANAGER.getValidStampBaseOnDevicePhoto()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapGestureTapped(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func updateCountryCodeForValidStamp() {
        
        if self.indexStamp < self.validStampArray.count {
            let location = CLLocation(latitude: self.validStampArray[indexStamp].location.latitude, longitude: self.validStampArray[indexStamp].location.longitude)
            LOCATION_MANAGER.getAdress(atLocation: location) { [weak self](address, error) in

                if  let weakSelf = self {
                    if let address = address,
                        let countryCode = address["CountryCode"] as? String,
                        let countryName = address["Country"] as? String{
                        weakSelf.validStampArray[weakSelf.indexStamp].countryCode = countryCode
                        weakSelf.validStampArray[weakSelf.indexStamp].name = countryName
                        weakSelf.indexStamp += 1
                        // De quy
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            weakSelf.updateCountryCodeForValidStamp()
                        })
                    } else {
                        weakSelf.indexStamp = 0
                        weakSelf.filterValidStamp()
                    }
                }
            }
        } else{
            self.indexStamp = 0
            self.filterValidStamp()
        }
    }
    
    fileprivate func filterValidStamp() {
        
        if let myCountry = TDUser.currentUser()?.country {
            for validStamp in self.validStampArray {
                if validStamp.countryCode != myCountry {
                    self.validStampFilterArray.append(validStamp)
                }
            }
        }

        //Fetch already-had stamps from server
        API_MANAGER.fetchStampByCountryCode(countryCode: nil, userId: nil, success: {(stampArray) in

            //Compare the stamps from Gallery and the fetched stamps, remove the ones that existed from server out of validStampFilterArray
            var unaddedStampArray = [ValidStamp]();
            for localStamp in self.validStampFilterArray {
                var isDuplicated = false;
                for remoteStamp in stampArray {
                    if (remoteStamp.countryCode == localStamp.countryCode) {
                        if let remoteCreateIntervals = remoteStamp.uploadedAt, abs(remoteCreateIntervals - localStamp.createDate.timeIntervalSince1970) < 24 * 3600 {
                            isDuplicated = true;
                        }
                    }
                }
                
                if (!isDuplicated) {
                    unaddedStampArray.append(localStamp);
                }
            }
            
            var removedDuplicatedStamps = [ValidStamp]();
            
            for unprocessedStamp in unaddedStampArray {
                var stampAdded = false;
                for stamp in removedDuplicatedStamps {
                    
                    let withinSameDay = abs(unprocessedStamp.createDate.timeIntervalSince1970 - stamp.createDate.timeIntervalSince1970) < 24 * 3600;
                    
                    if (stamp.countryCode == unprocessedStamp.countryCode && withinSameDay) {
                        stampAdded = true;
                    }
                }
                if (!stampAdded) {
                    removedDuplicatedStamps.append(unprocessedStamp);
                }
            }
            
            //Remove duplicated stamps (same country code, same day)
            self.validStampDuplicateArray = removedDuplicatedStamps;
            
            //Finally, filter out the stamps that have the same country code and date with currentStampCountryInfo
            var result = [ValidStamp]();
            for validStampDuplicate in self.validStampDuplicateArray {
                let createDateString = validStampDuplicate.createDate.timeIntervalSince1970.unixTimeToDayMonthYearString()
                let currentDateString = Date().timeIntervalSince1970.unixTimeToDayMonthYearString()
                if validStampDuplicate.countryCode == self.currentStampCountryInfo?.alpha2 && createDateString == currentDateString {
                } else {
                    result.append(validStampDuplicate);
                }
            }
            
            self.validStampDuplicateArray = result;
            self.xt_stopNetworkIndicatorView()
            self.tableView.reloadData()
        }) {(error) in

            self.tableView.reloadData()
            self.xt_stopNetworkIndicatorView()
        }
    }
    
    
}

extension ValidStampPhotoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.delegate?.didSelectValidStamp(viewController: self, validStamp: nil)
            self.dismiss(animated: true, completion: nil)
        } else {
            let validStamp = self.validStampDuplicateArray[indexPath.row]
            self.delegate?.didSelectValidStamp(viewController: self, validStamp: validStamp)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension ValidStampPhotoViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return self.validStampDuplicateArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ValidStampCell", for: indexPath) as! ValidStampTableViewCell
        if indexPath.section == 0 {
            cell.countryNameLabel.text = self.currentStampCountryInfo?.name ?? ""
            cell.dateLabel.text = "Today"
            cell.flagImageView.image = UIImage.init(named: (self.currentStampCountryInfo?.alpha2)!)
        } else {
            cell.countryNameLabel.text = validStampDuplicateArray[indexPath.row].name ?? ""
            cell.dateLabel.text = validStampDuplicateArray[indexPath.row].createDate.timeIntervalSince1970.unixTimeToDayMonthYearString()
            cell.flagImageView.image = UIImage.init(named: (validStampDuplicateArray[indexPath.row].countryCode)!)
        }
        return cell
    }
}

extension ValidStampPhotoViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Opps!", attributes: nil)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No stamp to show", attributes: nil)
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
        return #imageLiteral(resourceName: "refesh")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        button.rotateButton(animationDuration: 1, inSecond: 10)
        self.refreshData()
    }
}

extension ValidStampPhotoViewController: StampManagerDelegate {
    func didGetValidStamp(withValidStampArray validStampArray: [ValidStamp]) {
        self.validStampArray = validStampArray
        self.updateCountryCodeForValidStamp()
    }
}
