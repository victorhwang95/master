//
//  TDTripDetailViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 12/4/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

protocol TripDetailViewControllerDelegate: class {
    func didUpdateCityMetadata(viewController: TDTripDetailViewController,  cityData city: TDTripCity)
}

class TDTripDetailViewController: TDBaseViewController {
    
    // MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK:- Properties
    var isFriendCity: Bool = false
    var cityId: Int! = 0
    var cityName: String! = ""
    var selectedTypeTab: PlaceType = .hotel
    var tripCity: TDTripCity?
    var cityLocationDict = [String: [TDCityLocation]]()
    var headerView: HeaderTripView?
    
    weak var delegate: TripDetailViewControllerDelegate?
    
    var isFriendProfile: Bool = false // Use in the friend profile layout
    
    // MARK:- Public method
    static func newInstance() -> TDTripDetailViewController {
        return UIStoryboard.init(name: "MyTrips", bundle: nil).instantiateViewController(withIdentifier: "TDTripDetailViewController") as! TDTripDetailViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = cityName
        setupRightButtons(buttonType: .setting)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let tripCity = self.tripCity else {return}
        self.delegate?.didUpdateCityMetadata(viewController: self, cityData: tripCity)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Private method
    
    // MARK:- Private method
    fileprivate func setupView() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 300
        
        let tripPlaceSingleView = UINib(nibName: "TripPlaceSingleView", bundle: nil)
        self.tableView.register(tripPlaceSingleView, forCellReuseIdentifier: "TripPlaceSingleView")
        
        let tripPlaceSelectView = UINib(nibName: "TripPlaceSelectView", bundle: nil)
        self.tableView.register(tripPlaceSelectView, forCellReuseIdentifier: "TripPlaceSelectView")
        
        let tripPlaceSelectFirstView = UINib(nibName: "TripPlaceSelectFirstView", bundle: nil)
        self.tableView.register(tripPlaceSelectFirstView, forCellReuseIdentifier: "TripPlaceSelectFirstView")
        
        let tripPlaceSelectLastView = UINib(nibName: "TripPlaceSelectLastView", bundle: nil)
        self.tableView.register(tripPlaceSelectLastView, forCellReuseIdentifier: "TripPlaceSelectLastView")
        
        let commentTableViewCell = UINib(nibName: "CommentTableViewCell", bundle: nil)
        self.tableView.register(commentTableViewCell, forCellReuseIdentifier: "CommentTableViewCell")
        
        // Load data
        self.refreshData()
    }
    
    fileprivate func refreshData(isShowIndicator: Bool = true) {
        if isShowIndicator {
            self.xt_startNetworkIndicatorView(withMessage: "Loading...")
        }
        self.cityLocationDict.removeAll()
        
        // Firebase analytics
        FIR_MANAGER.sendAppEvent(withEvent: FIREvent.LOAD_MY_DETAIL_CITY_TRIP_FUNCTION.rawValue, userId: nil)
        
        API_MANAGER.requestGetTripListByCity(cityId: self.cityId, success: { (tripCity) in
            self.xt_stopNetworkIndicatorView()
            self.tripCity = tripCity
            self.filterCityLocationData()
            self.tableView.reloadData()
        }) { (error) in
            self.xt_stopNetworkIndicatorView()
//            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: { (alerController, index) in
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    fileprivate func filterCityLocationData() {
        if let tripCity = self.tripCity {
            var cityHotelLocation = [TDCityLocation]()
            var cityRestLocation = [TDCityLocation]()
            var cityBarLocation = [TDCityLocation]()
            var cityMuseLocation = [TDCityLocation]()
            if let locations = tripCity.locations {
                for location in locations {
                    if let type = location.type {
                        switch type {
                        case .restaurant:
                            cityRestLocation.append(location)
                        case .bar:
                            cityBarLocation.append(location)
                        case .museum:
                            cityMuseLocation.append(location)
                        default:
                            cityHotelLocation.append(location)
                        }
                    }
                }
            }
            self.cityLocationDict[PlaceType.hotel.description] = cityHotelLocation
            self.cityLocationDict[PlaceType.restaurant.description] = cityRestLocation
            self.cityLocationDict[PlaceType.bar.description] = cityBarLocation
            self.cityLocationDict[PlaceType.museum.description] = cityMuseLocation
            self.tripCity?.comments = self.tripCity?.comments?.reversed()
            
        }
    }
}

extension TDTripDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 50
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 100
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 50
        }
        return 0
    }
}

extension TDTripDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.cityLocationDict[self.selectedTypeTab.description]?.count ?? 0
        }
        return self.tripCity?.comments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            if let cell = self.headerView {
                cell.delegate = self
                cell.setData(tripCity: self.tripCity, googlePlaceData: nil, tabPosition: self.selectedTypeTab, atSection: 0)
                return cell
            } else {
                let cell = HeaderTripView.viewFromNib() as! HeaderTripView
                cell.delegate = self
                cell.setData(tripCity: self.tripCity, googlePlaceData: nil, tabPosition: self.selectedTypeTab, atSection: 0)
                self.headerView = cell
                return cell
            }
        }
        let cell = CommentView.viewFromNib() as! CommentView
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let footerDetailCityTripView = FooterDetailCityTripView.viewFromNib() as! FooterDetailCityTripView
            footerDetailCityTripView.delegate = self
            footerDetailCityTripView.setData(tripCity: self.tripCity, isFriendCity: self.isFriendCity)
            return footerDetailCityTripView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let data = self.cityLocationDict[self.selectedTypeTab.description]?[indexPath.row]
            if self.cityLocationDict[self.selectedTypeTab.description]?.count == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TripPlaceSingleView", for: indexPath) as! TripPlaceSelectView
                cell.setDataCityLocation(cityLocation: data)
                return cell
            } else {
                switch indexPath.row {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TripPlaceSelectFirstView", for: indexPath) as! TripPlaceSelectView
                    cell.setDataCityLocation(cityLocation: data)
                    return cell
                    
                case self.tableView(tableView, numberOfRowsInSection: 0) - 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TripPlaceSelectLastView", for: indexPath) as! TripPlaceSelectView
                    cell.setDataCityLocation(cityLocation: data)
                    return cell
                    
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TripPlaceSelectView", for: indexPath) as! TripPlaceSelectView
                    cell.setDataCityLocation(cityLocation: data)
                    return cell
                    
                }
            }
        } else {
            let data = self.tripCity?.comments?[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
            cell.delegate = self
            cell.setData(commentData: data, isFriendProfile: self.isFriendProfile)
            return cell
        }
    }
}

extension TDTripDetailViewController: HeaderTripViewDelegate {
    func didWriteCustomLocation(name: String) {
    }
    
    func didTapButtonToChannelTypePlace(placeType: PlaceType, atSection: Int) {
        self.selectedTypeTab = placeType
        self.tableView.reloadData()
    }
}

extension TDTripDetailViewController: CommentViewDelegate {
    func didTapCommentButton(commentView: CommentView, withComment comment: String) {
        self.xt_startNetworkIndicatorView(withMessage: "Posting...")
        if let userID = TDUser.currentUser()?.id,
            let userIDInt = Int(userID){
            
            // Firebase analytics
            FIR_MANAGER.sendAppEvent(withEvent: FIREvent.CMT_TRIP_FUNCTION.rawValue, userId: nil)
            
            API_MANAGER.requestPostCommentOnCityTrip(cityId: self.cityId, userId: userIDInt, content: comment, success: {
                commentView.commentTextField.text = nil
                self.refreshData(isShowIndicator: false)
            }, failure: { (error) in
                self.xt_stopNetworkIndicatorView()
                UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            })
        }
    }
}

extension TDTripDetailViewController: FooterDetailCityTripViewDelegate {
    func didTapLikeButton(footerDetailCitytView: FooterDetailCityTripView) {
        
        let isLike = self.tripCity?.isLiked
        var behavior: String = "like"
        if isLike == true {
            behavior = "unlike"
        }
        
        self.xt_startNetworkIndicatorView(withMessage: "Posting...")
        
        // Firebase analytics
        FIR_MANAGER.sendAppEvent(withEvent: FIREvent.LIKE_TRIP_FUNCTION.rawValue, userId: nil)
        
        API_MANAGER.requestLikeCityTrip(cityId: self.cityId, behavior: behavior, success: { cityData in
            self.refreshData(isShowIndicator: false)
        }, failure: { (error) in
            self.xt_stopNetworkIndicatorView()
            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        })
    }
    
    func didTapShareButton(footerDetailCitytView: FooterDetailCityTripView) {
        self.xt_startNetworkIndicatorView(withMessage: "Sharing...")
        
        // Firebase analytics
        FIR_MANAGER.sendAppEvent(withEvent: FIREvent.SHARE_TRIP_FUNCTION.rawValue, userId: nil)
        
        API_MANAGER.requestShareActivityWithType(activityId: self.cityId, activityType: "City", stampIdArray: nil, success: { message in
            // Refresh Data
            self.xt_stopNetworkIndicatorView()
            UIAlertController.show(in: self, withTitle: "Notice", message: message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        }, failure: { (error) in
            self.xt_stopNetworkIndicatorView()
            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        })
    }
}

extension TDTripDetailViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Opps!", attributes: nil)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No trips to show", attributes: nil)
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
        return #imageLiteral(resourceName: "refesh")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        button.rotateButton(animationDuration: 1, inSecond: 10)
        self.refreshData()
    }
}

extension TDTripDetailViewController: CommentTableViewCellDelegate {
    func didTapAvatar(friendInfo: TDUser?) {
        guard let userId = friendInfo?.id else {return}
        let friendInfoVC = TDFriendProfileViewController.newInstance()
        friendInfoVC.userId = userId
        self.navigationController?.pushViewController(friendInfoVC, animated: true)
    }
}

