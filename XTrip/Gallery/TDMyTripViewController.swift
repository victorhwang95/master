//
//  TDMyTripViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 12/11/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import MJRefresh

protocol TDMyTripViewDelegate: class {
    func didSelectedTrip(viewController vc: TDMyTripViewController, withTrip trip: TDTrip)
    func didSelectedCreateNewTrip(viewController vc: TDMyTripViewController)
}

class TDMyTripViewController: UIViewController {

    // MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK:- Properties
    let footer = MJRefreshBackNormalFooter()
    weak var delegate:TDMyTripViewDelegate?
    var tripArray: [TDTrip] = []
    var currentTripPage = 0
    
    var isFriendTrip: Bool = false // Use to load friend trip when upload or edit new picture
    
    // MARK:- Public method
    static func newInstance() -> TDMyTripViewController {
        return UIStoryboard.init(name: "MyPictures", bundle: nil).instantiateViewController(withIdentifier: "TDMyTripViewController") as! TDMyTripViewController
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
        
        self.footer.setRefreshingTarget(self, refreshingAction: #selector(self.loadData))
        // add header to table view
        self.tableView.mj_footer = self.footer
        self.tableView.tableFooterView = UIView()
        self.loadData()
    }
    
    // pull-up to loadmore
    @objc fileprivate func loadData(isShowIndicator: Bool = true) {
        if CONNECTION_MANAGER.isNetworkAvailable(willShowAlertView: false) {
            if isShowIndicator {
                self.xt_startNetworkIndicatorView(withMessage: "Loading...")
            }
            self.currentTripPage += 1
            API_MANAGER.requestGetTripList(isfriendTrip: self.isFriendTrip, page: currentTripPage, perPage: 10, showImage: 0, country: nil, time: nil, friendId: nil, userId: nil, success: { (baseData) in
                self.tableView.mj_footer.endRefreshing()
                self.xt_stopNetworkIndicatorView()
                // Add data to tableview
                self.tripArray.append(contentsOf: baseData.tripList ?? [])
                
                self.tableView.reloadData()
            }) { (error) in
                self.tableView.mj_footer.endRefreshing()
                self.xt_stopNetworkIndicatorView()
                UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            }
            
        } else {
            if let tripList = TDTrip.getCurrentTripList() as? [TDTrip] {
                self.tripArray = tripList
                self.tableView.reloadData()
            }
        }
    }

    // MARK:- Actions
    @IBAction func dismisTapped(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension TDMyTripViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isFriendTrip {
            let data = self.tripArray[indexPath.row]
            self.delegate?.didSelectedTrip(viewController: self, withTrip: data)
        } else {
            if indexPath.section == 0 {
                self.delegate?.didSelectedCreateNewTrip(viewController: self)
            } else {
                let data = self.tripArray[indexPath.row]
                self.delegate?.didSelectedTrip(viewController: self, withTrip: data)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension TDMyTripViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.isFriendTrip {
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFriendTrip {
            return self.tripArray.count
        } else {
            if section == 0 {
                return 1
            }
            return self.tripArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! MyTripTableViewCell
        if self.isFriendTrip {
            let data = self.tripArray[indexPath.row]
            cell.setData(trip: data)
            return cell
        } else {
            if indexPath.section == 0 {
                cell.tripNameLabel.text = "Create a trip"
                cell.ownerNameLabel.text = ""
                return cell
            } else {
                let data = self.tripArray[indexPath.row]
                cell.setData(trip: data)
                return cell
            }
        }
    }
}
