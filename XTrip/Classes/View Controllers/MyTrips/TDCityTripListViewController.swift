//
//  TDCityTripListViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 12/4/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import MJRefresh
import CoreLocation

class TDCityTripListViewController: TDBaseViewController {
    
    // MARK:- Outlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK:- Properties
    var tripMapView: TripMapView!
    var tripId: Int = 0
    var countryName: String = ""
    var countryCode: String = ""
    var currentCountryCodinate: CLLocationCoordinate2D!
    var friendInfo: TDUser?
    var selectedTypeTabArray: [PlaceType] = [PlaceType]()
    var tripCityArray: [TDTripCity]?
    var cityLocationArray = [[String: [TDCityLocation]]]()
    let header = MJRefreshNormalHeader()
    var isFriendProfile: Bool = false // Use in the friend profile layout
    
    var headerViewDict: [Int : HeaderTripView] = [:]
    
    // MARK:- Public method
    static func newInstance() -> TDCityTripListViewController {
        return UIStoryboard.init(name: "MyTrips", bundle: nil).instantiateViewController(withIdentifier: "TDCityTripListViewController") as! TDCityTripListViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = self.countryName
        setupRightButtons(buttonType: .setting)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Private method
    fileprivate func setupView() {
        self.setupChildViewControllers()
        
        let tripPlaceSingleView = UINib(nibName: "TripPlaceSingleView", bundle: nil)
        self.tableView.register(tripPlaceSingleView, forCellReuseIdentifier: "TripPlaceSingleView")
        
        let tripPlaceSelectView = UINib(nibName: "TripPlaceSelectView", bundle: nil)
        self.tableView.register(tripPlaceSelectView, forCellReuseIdentifier: "TripPlaceSelectView")
        
        let tripPlaceSelectFirstView = UINib(nibName: "TripPlaceSelectFirstView", bundle: nil)
        self.tableView.register(tripPlaceSelectFirstView, forCellReuseIdentifier: "TripPlaceSelectFirstView")
        
        let tripPlaceSelectLastView = UINib(nibName: "TripPlaceSelectLastView", bundle: nil)
        self.tableView.register(tripPlaceSelectLastView, forCellReuseIdentifier: "TripPlaceSelectLastView")
        
        // Set refreshing with target
        self.header.setRefreshingTarget(self, refreshingAction: #selector(self.refreshData))
        // add header to table view
        self.tableView.mj_header = self.header
        
        // Load data
        self.refreshData()
    }
    
    fileprivate func setupChildViewControllers() {
        if self.tripMapView == nil {
            self.tripMapView = TripMapView.viewFromNib() as! TripMapView
            self.tripMapView?.tripMapViewDelegate = self
            self.headerView.addSubview(self.tripMapView)
            self.tripMapView.snp.makeConstraints { (make) in
                make.top.left.bottom.right.equalTo(self.headerView)
            }
        }
    }
    
    @objc fileprivate func refreshData(isShowIndicator: Bool = true) {
        if isShowIndicator {
            self.xt_startNetworkIndicatorView(withMessage: "Loading...")
        }
        self.xt_startNetworkIndicatorView(withMessage: "Loading...")
        
        // Firebase analytics
        FIR_MANAGER.sendAppEvent(withEvent: FIREvent.LOAD_MY_CITY_TRIP_FUNCTION.rawValue, userId: nil)
        
        API_MANAGER.requestGetTripListByCountry(tripId: self.tripId, countryCode: self.countryCode, success: { (tripCities) in
            self.tableView.mj_header.endRefreshing()
            self.xt_stopNetworkIndicatorView()
            self.tripMapView?.setCityTripData(tripCityArray: tripCities, currentCountryCodinate: self.currentCountryCodinate)
            self.tripCityArray = tripCities
            self.headerViewDict.removeAll()
            self.filterCityLocationData()
            self.tableView.reloadData()
        }) { (error) in
            self.tableView.mj_header.endRefreshing()
            self.tableView.reloadData()
            self.xt_stopNetworkIndicatorView()
//            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: { (alerController, index) in
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    fileprivate func filterCityLocationData() {
        self.cityLocationArray.removeAll()
        self.selectedTypeTabArray.removeAll()
        if let tripCityArray = self.tripCityArray {
            for cityLocation in tripCityArray {
                var cityLocationTempt = [String: [TDCityLocation]]()
                var cityHotelLocation = [TDCityLocation]()
                var cityRestLocation = [TDCityLocation]()
                var cityBarLocation = [TDCityLocation]()
                var cityMuseLocation = [TDCityLocation]()
                var cityOtherLocation = [TDCityLocation]()
                var cityPOILocation = [TDCityLocation]()
                if let locations = cityLocation.locations {
                    for location in locations {
                        if let type = location.type {
                            switch type {
                            case .restaurant:
                                cityRestLocation.append(location)
                            case .bar:
                                cityBarLocation.append(location)
                            case .museum:
                                cityMuseLocation.append(location)
                            case .hotel:
                                cityHotelLocation.append(location)
                            case .other, .unknown:
                                cityOtherLocation.append(location)
                            case .POI:
                                cityPOILocation.append(location)
                            }
                        }
                    }
                }
                cityLocationTempt[PlaceType.hotel.description] = cityHotelLocation
                cityLocationTempt[PlaceType.restaurant.description] = cityRestLocation
                cityLocationTempt[PlaceType.bar.description] = cityBarLocation
                cityLocationTempt[PlaceType.museum.description] = cityMuseLocation
                cityLocationTempt[PlaceType.other.description] = cityOtherLocation
                cityLocationTempt[PlaceType.POI.description] = cityPOILocation
                self.cityLocationArray.append(cityLocationTempt)
                self.selectedTypeTabArray.append(.hotel)
            }
        }
    }
    
}

extension TDCityTripListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension TDCityTripListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tripCityArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cityLocationArray[section][self.selectedTypeTabArray[section].description]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cell = self.headerViewDict[section] {
            cell.delegate = self
            if (self.tripCityArray?.count ?? 0) != 0 {
                cell.setData(tripCity: self.tripCityArray?[section], googlePlaceData: nil, tabPosition: self.selectedTypeTabArray[section], atSection: section)
            }
            return cell
        } else {
            let cell = HeaderTripView.viewFromNib() as! HeaderTripView
            self.headerViewDict[section] = cell
            cell.delegate = self
            if (self.tripCityArray?.count ?? 0) != 0 {
                cell.setData(tripCity: self.tripCityArray?[section], googlePlaceData: nil, tabPosition: self.selectedTypeTabArray[section], atSection: section)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let friendInfo = self.friendInfo, friendInfo.id != TDUser.currentUser()?.id {
            let cell = FriendInfoView.viewFromNib() as! FriendInfoView
            cell.delegate = self
            cell.setData(tripCity: self.tripCityArray?[section], googlePlaceData: nil, friendInfo: self.friendInfo, atSection: section, isFriendProfile: self.isFriendProfile)
            return cell
        } else {
            let cell = FooterTripView.viewFromNib() as! FooterTripView
            cell.delegate = self
            cell.setData(tripCity: self.tripCityArray?[section], googlePlaceData: nil, atSection: section)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.cityLocationArray[indexPath.section][self.selectedTypeTabArray[indexPath.section].description]?[indexPath.row]
        if self.cityLocationArray[indexPath.section][self.selectedTypeTabArray[indexPath.section].description]?.count == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TripPlaceSingleView", for: indexPath) as! TripPlaceSelectView
            cell.setDataCityLocation(cityLocation: data)
            return cell
        } else {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TripPlaceSelectFirstView", for: indexPath) as! TripPlaceSelectView
                cell.setDataCityLocation(cityLocation: data)
                return cell
                
            case self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TripPlaceSelectLastView", for: indexPath) as! TripPlaceSelectView
                cell.setDataCityLocation(cityLocation: data)
                return cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TripPlaceSelectView", for: indexPath) as! TripPlaceSelectView
                cell.setDataCityLocation(cityLocation: data)
                return cell
            }
        }
    }
}

extension TDCityTripListViewController: HeaderTripViewDelegate {
    func didTapButtonToChannelTypePlace(placeType: PlaceType, atSection: Int) {
        if self.selectedTypeTabArray.indices.contains(atSection) {
            self.selectedTypeTabArray[atSection] = placeType
            self.tableView.reloadData()
        }
    }
    
    func didWriteCustomLocation(name: String) {
    }
}

extension TDCityTripListViewController: FooterTripViewDelegate {
    
    func didTapButtonWithType(footerView: FooterTripView, withAction type: PostActionType, atTripCity city: TDTripCity, shareScreenShot screenShot: UIImage?) {
        switch type {
        case .share:
            UIAlertController.showActionSheet(in: self, withTitle: title, message: nil, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: ["Share On The Activity", "Share On Facebook"], popoverPresentationControllerBlock: { (popOver) in
                popOver.sourceView = self.view
                
            }) { (controller, index) in
                if (index == 3) {
                    // Share on Facebook
                    let cityView = CityShareScreenShotView.viewFromNib() as! CityShareScreenShotView
                    cityView.setSharePictureData(cityData: city)
                    let screenShot = cityView.takeScreenshot()
                    FACEBOOK_MANAGER.sharePicture(image: screenShot, hastag: "TravelXCity", viewController: self)
                } else if (index == 2) {
                    // Share on the activity
                    if let cityId = city.id {
                        self.xt_startNetworkIndicatorView(withMessage: "Sharing...")
                        
                        // Firebase analytics
                        FIR_MANAGER.sendAppEvent(withEvent: FIREvent.SHARE_TRIP_FUNCTION.rawValue, userId: nil)
                        
                        API_MANAGER.requestShareActivityWithType(activityId: cityId, activityType: "City", stampIdArray: nil, success: { message in
                            // Refresh Data
                            self.xt_stopNetworkIndicatorView()
                            UIAlertController.show(in: self, withTitle: "Notice", message: message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                        }, failure: { (error) in
                            self.xt_stopNetworkIndicatorView()
                            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                        })
                    }
                }
            }
        case .delete:
            guard let cityId = city.id else {return}
            _ = self.showAlertWithTitle(nil, message: "Are you sure you want to delete ?", okButton: "YES", alertViewType:.alert, okHandler: { (actionSheet) in
                self.xt_startNetworkIndicatorView(withMessage: "Deleting...")
                API_MANAGER.requesDeleteCityTrip(cityId: cityId , success: {
                    // Refresh Data
                    self.refreshData(isShowIndicator: false)
                }, failure: { (error) in
                    self.xt_stopNetworkIndicatorView()
                    UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                })
            }, closeButton: "NO THANKS", closeHandler: { (actionSheet) in }, completionHanlder: nil)
        case .like:
            if let cityId = city.id {
                
                let isLike = city.isLiked
                var behavior: String = "like"
                if isLike == true {
                    behavior = "unlike"
                }
                self.xt_startNetworkIndicatorView(withMessage: "Posting...")
                
                // Firebase analytics
                FIR_MANAGER.sendAppEvent(withEvent: FIREvent.LIKE_TRIP_FUNCTION.rawValue, userId: nil)
                
                API_MANAGER.requestLikeCityTrip(cityId: cityId, behavior: behavior, success: { cityData in
                    // Refresh Data
                    self.xt_stopNetworkIndicatorView()
                    guard let tripCityArray = self.tripCityArray else {return}
                    for (index, currentCity) in tripCityArray.enumerated() {
                        if let currentCityId = currentCity.id,
                            let updateCityId = cityData.id,
                            currentCityId == updateCityId {
                            self.tripCityArray?[index] = cityData
                            self.tableView.reloadData()
                            break
                        }
                    }
                }, failure: { (error) in
                    self.xt_stopNetworkIndicatorView()
                    UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                })
            }
        case .comment:
            
            // Firebase analytics
            FIR_MANAGER.sendAppEvent(withEvent: FIREvent.CMT_TRIP_FUNCTION.rawValue, userId: nil)
            
            let detailCityTripListVC = TDTripDetailViewController.newInstance()
            if let cityId = city.id,
                let cityName = city.name {
                detailCityTripListVC.cityId = cityId
                detailCityTripListVC.cityName = cityName
                self.navigationController?.pushViewController(detailCityTripListVC, animated: true)
            }
        case .edit:
            break
        case .update:
            break
        case .view:
            break
        }
        
    }
}

extension TDCityTripListViewController: FriendInfoViewDelegate {
    func didTapButtonWithType(friendInfoView: FriendInfoView, withAction type: PostActionType, atTripCity city: TDTripCity) {
        switch type {
        case .like:
            self.xt_startNetworkIndicatorView(withMessage: "Posting...")
            if let cityId = city.id {
                
                let isLike = city.isLiked
                var behavior: String = "like"
                if isLike == true {
                    behavior = "unlike"
                }
                
                API_MANAGER.requestLikeCityTrip(cityId: cityId, behavior:behavior, success: { cityData in
                    // Refresh Data
                    self.xt_stopNetworkIndicatorView()
                    guard let tripCityArray = self.tripCityArray else {return}
                    for (index, currentCity) in tripCityArray.enumerated() {
                        if let currentCityId = currentCity.id,
                            let updateCityId = city.id,
                            currentCityId == updateCityId {
                            self.tripCityArray?[index] = cityData
                            self.tableView.reloadData()
                            break
                        }
                    }
                }, failure: { (error) in
                    self.xt_stopNetworkIndicatorView()
                    UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                })
            }
        case .comment:
            let detailCityTripListVC = TDTripDetailViewController.newInstance()
            if let cityId = city.id,
                let cityName = city.name {
                detailCityTripListVC.cityId = cityId
                detailCityTripListVC.cityName = cityName
                detailCityTripListVC.delegate = self
                detailCityTripListVC.isFriendProfile = self.isFriendProfile
                self.navigationController?.pushViewController(detailCityTripListVC, animated: true)
            }
        case .view:
            guard let userId = self.friendInfo?.id else {return}
            let friendInfoVC = TDFriendProfileViewController.newInstance()
            friendInfoVC.userId = userId
            self.navigationController?.pushViewController(friendInfoVC, animated: true)
        default:
            break
        }
    }
}

extension TDCityTripListViewController: TripMapViewDelegate {
    
    func didTapAnntatioCountry(tripMapView: TripMapView, atTripId tripId: Int, friendInfo: TDUser?, andCountryCode countryCode: String?, coordinate: CLLocationCoordinate2D, andCountryName countryName: String?, andCityId cityId: Int?, andCityName cityName: String?) {
        let detailCityTripListVC = TDTripDetailViewController.newInstance()
        if let cityId = cityId,
            let cityName = cityName {
            detailCityTripListVC.cityId = cityId
            detailCityTripListVC.cityName = cityName
            detailCityTripListVC.delegate = self
            if let _ = self.friendInfo {
                detailCityTripListVC.isFriendCity = true
            } else {
                detailCityTripListVC.isFriendCity = false
            }
            detailCityTripListVC.isFriendProfile = self.isFriendProfile
            self.navigationController?.pushViewController(detailCityTripListVC, animated: true)
        }
    }
}

extension TDCityTripListViewController: TripDetailViewControllerDelegate {
    func didUpdateCityMetadata(viewController: TDTripDetailViewController, cityData city: TDTripCity) {
        guard let tripCityArray = self.tripCityArray else {return}
        for (index, currentCity) in tripCityArray.enumerated() {
            if let currentCityId = currentCity.id,
                let updateCityId = city.id,
                currentCityId == updateCityId {
                self.tripCityArray?[index] = city
                self.tableView.reloadData()
                break
            }
        }
    }
}

extension TDCityTripListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Opps!", attributes: nil)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No cities to show", attributes: nil)
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
        return #imageLiteral(resourceName: "refesh")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        button.rotateButton(animationDuration: 1, inSecond: 10)
        self.refreshData()
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        if self.tripCityArray?.count == 0 {
            return true
        }
        return false
    }
}


