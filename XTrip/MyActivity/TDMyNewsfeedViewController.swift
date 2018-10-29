//
//  TDMyNewsfeedViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 1/14/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit
import MJRefresh
import DZNEmptyDataSet
import GooglePlaces

class TDMyNewsfeedViewController: TDBaseViewController {
    
    // MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newStampView: UIView!
    @IBOutlet weak var topTableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    // MARK:- Properties
    let header = MJRefreshNormalHeader()
    let footer = MJRefreshBackNormalFooter()
    
    fileprivate var hasLoaded: Bool = false
    fileprivate var currentPage = 0
    fileprivate var activityList: [AbstractActivity] = []
    fileprivate var heightAtIndexPath:NSMutableDictionary!
    
    let loadDataGroup = DispatchGroup()
    var stampCountryInfo: TDLocalCountry?
    
    var oneStampViewDict: [Int : [OneStampView]] = [:]
    
    // MARK:- Public method
    static func newInstance() -> TDMyNewsfeedViewController {
        return UIStoryboard.init(name: "MyActivity", bundle: nil).instantiateViewController(withIdentifier: "TDMyNewsfeedViewController") as! TDMyNewsfeedViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeNavigationBarToTransparentStyle()
        self.topTableViewConstraint.constant = 0
        
        APP_PERMISSIONS_MANAGER.checkLocationInUsePermissions(viewController: self, completionHandler: { (isAuthorized) in
            if isAuthorized {
                LOCATION_MANAGER.startLocationService()
                let long = LOCATION_MANAGER.lastKnownCoordinate!.longitude
                let lat = LOCATION_MANAGER.lastKnownCoordinate!.latitude
                
                LOCATION_MANAGER.getAdress(atLocation: CLLocation(latitude: lat, longitude: long)) { [weak self](address, error) in
                    if  let weakSelf = self,
                        let address = address,
                        let countryCode = address["CountryCode"] as? String {
                        API_MANAGER.fetchStampByCountryCode(countryCode: countryCode, userId: nil, success: { (stampArray) in
                            if stampArray.count == 0 {
                                weakSelf.handleShowStampViewInLocation(countryCode: countryCode)
                            } else {
                                if let latestStamp = stampArray.first {
                                    let currentUnixTime = Date().timeIntervalSince1970
                                    print((currentUnixTime - (latestStamp.uploadedAt ?? 0.0))/3600/24)
                                    if (currentUnixTime - (latestStamp.uploadedAt ?? 0.0))/3600/24 >= 1 {
                                        weakSelf.handleShowStampViewInLocation(countryCode: countryCode)
                                    } else {
                                        weakSelf.topTableViewConstraint.constant = 0
                                    }
                                } else {
                                    weakSelf.topTableViewConstraint.constant = 0
                                }
                            }
                        }) { (error) in }
                    }
                }
            }
        }, onTapped: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Private method
    fileprivate func setupView() {
        
        self.header.setRefreshingTarget(self, refreshingAction: #selector(self.refreshData))
        // add header to table view
        self.tableView.mj_header = self.header
        
        self.footer.setRefreshingTarget(self, refreshingAction: #selector(self.loadData))
        // add footer to table view
        self.tableView.mj_footer = self.footer
        
        let sharePictureView = UINib(nibName: "SharePictureTableViewCell", bundle: nil)
        self.tableView.register(sharePictureView, forCellReuseIdentifier: "SharePictureTableViewCell")
        
        let shareCityView = UINib(nibName: "ShareCityTableViewCell", bundle: nil)
        self.tableView.register(shareCityView, forCellReuseIdentifier: "ShareCityTableViewCell")
        
        let shareCountryView = UINib(nibName: "ShareCountryTableViewCell", bundle: nil)
        self.tableView.register(shareCountryView, forCellReuseIdentifier: "ShareCountryTableViewCell")
        
        let shareAlbumTableView = UINib(nibName: "ShareAlbumTableViewCell", bundle: nil)
        self.tableView.register(shareAlbumTableView, forCellReuseIdentifier: "ShareAlbumTableViewCell")
        
        let shareStampTableView = UINib(nibName: "ShareStampTableViewCell", bundle: nil)
        self.tableView.register(shareStampTableView, forCellReuseIdentifier: "ShareStampTableViewCell")
        
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 300
        self.heightAtIndexPath = NSMutableDictionary()
        
        // Load data
        self.refreshData()
    }
    
    @objc fileprivate func refreshData(isShowIndicator: Bool = true) {
        
        if isShowIndicator {
            self.xt_startNetworkIndicatorView(withMessage: "Loading...")
        }
        xt_startNetworkIndicatorView(withMessage: "Loading...")
        
        self.currentPage = 1
        
        // Firebase analytics
        FIR_MANAGER.sendAppEvent(withEvent: FIREvent.LOAD_NEW_FEED_FUNCTION.rawValue, userId: nil)
        
        API_MANAGER.requestGetActivityList(page: self.currentPage, perPage: 5, success: { (activityList) in
            self.activityList = activityList
            self.hasLoaded = true
            self.oneStampViewDict.removeAll()
            self.tableView.reloadData()
            self.tableView.mj_header.endRefreshing()
            self.xt_stopNetworkIndicatorView()
        }) { (error) in
            self.hasLoaded = true
            self.tableView.reloadData()
            self.tableView.mj_header.endRefreshing()
            self.xt_stopNetworkIndicatorView()
            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        }
    }
    
    fileprivate func handleShowStampViewInLocation(countryCode: String ) {
        if self.checkCountryCountryIsNotMyCountry(countryCode:  countryCode) {
            if let stampCountryInfo = self.checkCountryIsValid(countryCode: countryCode) {
                self.stampCountryInfo = stampCountryInfo
                UIView.animate(withDuration: 0.5, animations: {
                    self.welcomeLabel.text = "Welcome to \(stampCountryInfo.name!)"
                    self.topTableViewConstraint.constant = 120
                    self.view.layoutIfNeeded()
                })
            } else {
                self.topTableViewConstraint.constant = 0
            }
        } else {
            self.topTableViewConstraint.constant = 0
        }
    }
    
    fileprivate func checkCountryIsValid(countryCode: String) -> TDLocalCountry? {
        for country in self.getCountryListFromJsonFile() {
            if country.alpha2 == countryCode {
                if let stamp = country.stamp,
                    let _ = UIImage(named: stamp) {
                    return country
                }
            }
        }
        return nil
    }
    
    fileprivate func checkCountryCountryIsNotMyCountry(countryCode: String) -> Bool {
        if let myCountryCode = TDUser.currentUser()?.country, myCountryCode == countryCode {
            return false
        }
        return true
    }
    
    // pull-up to loadmore
    @objc fileprivate func loadData(isShowIndicator: Bool = true) {
        if isShowIndicator {
            self.xt_startNetworkIndicatorView(withMessage: "Loading...")
        }
        self.currentPage += 1
        API_MANAGER.requestGetActivityList(page: self.currentPage, perPage: 5, success: { (activityList) in
            self.activityList.append(contentsOf: activityList)
            self.tableView.reloadData()
            self.tableView.mj_footer.endRefreshing()
            self.xt_stopNetworkIndicatorView()
        }) { (error) in
            self.tableView.mj_footer.endRefreshing()
            self.xt_stopNetworkIndicatorView()
            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        }
    }
    
    @IBAction func newStampButtonTapped(_ sender: UIButton) {
        if let stampCountryInfo = stampCountryInfo {
            let processStampVC = TDProcessStampViewController.newInstance()
            processStampVC.stampCountryInfo = stampCountryInfo
            self.navigationController?.pushViewController(processStampVC, animated: true)
        }
    }
}

extension TDMyNewsfeedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activityList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let activityData = self.activityList[indexPath.row]
        if let type = activityData.postType {
            if type == "City" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShareCityTableViewCell") as! ShareCityTableViewCell
                cell.delegate = self
                cell.setShareLikeAndCommentCount(likeCount: activityData.totalLike ?? 0, commentCount: activityData.totalComment ?? 0)
                if let sharePicture = (activityData as? CityActivity)?.city {
                    cell.setSharePictureData(cityData: sharePicture, atTimeInterval: activityData.createdAt)
                }
                if let shareUser = activityData.user {
                    cell.setUserData(userData: shareUser)
                }
                return cell
            } else if type == "Album" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShareAlbumTableViewCell") as! ShareAlbumTableViewCell
                cell.delegate = self
                cell.setShareLikeAndCommentCount(likeCount: activityData.totalLike ?? 0, commentCount: activityData.totalComment ?? 0)
                if let shareAlbum = (activityData as? AblumActivity)?.pictures {
                    cell.setAlbumData(myPictureArray: shareAlbum, atTimeInterval: activityData.createdAt)
                }
                if let shareUser = activityData.user {
                    cell.setUserData(userData: shareUser)
                }
                return cell
            } else if type == "Country" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShareCountryTableViewCell") as! ShareCountryTableViewCell
                cell.delegate = self
                cell.delegateVisitFriend = self
                cell.setShareLikeAndCommentCount(likeCount: activityData.totalLike ?? 0, commentCount: activityData.totalComment ?? 0)
                if let shareTrip = (activityData as? TripActivity)?.trip,
                    let friendTrip = activityData.user {
                    cell.setShareCountryData(countryData: shareTrip, friend: friendTrip, atTimeInterval: activityData.createdAt)
                }
                if let shareUser = activityData.user {
                    cell.setUserData(userData: shareUser)
                }
                return cell
            } else if type == "Stamp" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShareStampTableViewCell") as! ShareStampTableViewCell
                cell.delegate = self
                cell.delegateStamp = self
                if let shareStamp = (activityData as? StampActivity)?.stamps,
                    let id = activityData.id{
                    if let views = self.oneStampViewDict[id] {
                        cell.setData(stampArray: shareStamp, atTimeInterval: activityData.createdAt, id: id, views: views)
                    } else {
                        cell.setData(stampArray: shareStamp, atTimeInterval: activityData.createdAt, id: id, views: [])
                    }
                }
                if let shareUser = activityData.user {
                    cell.setUserData(userData: shareUser)
                }
                return cell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SharePictureTableViewCell") as! SharePictureTableViewCell
        cell.delegate = self
        cell.setShareLikeAndCommentCount(likeCount: activityData.totalLike ?? 0, commentCount: activityData.totalComment ?? 0)
        if let sharePicture = (activityData as? PictureActivity)?.picture {
            cell.setSharePictureData(pictureData: sharePicture)
            cell.setCreateTime(atTimeInterval: activityData.createdAt)
        }
        if let shareUser = activityData.user {
            cell.setUserData(userData: shareUser)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = self.heightAtIndexPath.object(forKey: indexPath) as?  CGFloat {
            return height
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let height = cell.frame.size.height
        self.heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let type = self.activityList[indexPath.row].postType {
            if type == "Image" {
                guard let pictureData = self.activityList[indexPath.row] as? PictureActivity else {return}
                guard let pictureId = pictureData.picture.imageId else {return}
                guard let pictureCaption = pictureData.picture.caption else {return}
                let pictureDetailVC = TDPictureDetailViewController.newInstance()
                pictureDetailVC.delegate = self
                pictureDetailVC.pictureId = pictureId
                pictureDetailVC.pictureCaption = pictureCaption
                self.navigationController?.pushViewController(pictureDetailVC, animated: true)
            } else if type == "City" {
                guard let cityData = self.activityList[indexPath.row] as? CityActivity else {return}
                guard let cityId = cityData.city.id else {return}
                guard let cityName = cityData.city.name else {return}
                let cityDetailVC = TDTripDetailViewController.newInstance()
                cityDetailVC.delegate = self
                cityDetailVC.cityId = cityId
                cityDetailVC.cityName = cityName
                cityDetailVC.isFriendCity = true
                self.navigationController?.pushViewController(cityDetailVC, animated: true)
            } else if type == "Album"{
                guard let myPicture = self.activityList[indexPath.row] as? AblumActivity else {return}
                guard let userData = self.activityList[indexPath.row].user else {return}
                let pictureListVC = TDPictureListViewController.newInstance()
                pictureListVC.friendData = userData
                pictureListVC.tripId = myPicture.pictures.first?.trip?.tripId
                pictureListVC.tripName = myPicture.pictures.first?.trip?.name
                pictureListVC.isFriendPicture = true
                self.navigationController?.pushViewController(pictureListVC, animated: true)
            }
        }
        
    }
}

extension TDMyNewsfeedViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Opps!", attributes: nil)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No feeds to show", attributes: nil)
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
        return #imageLiteral(resourceName: "refesh")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        button.rotateButton(animationDuration: 1, inSecond: 10)
        self.refreshData()
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return self.hasLoaded
    }
}

extension TDMyNewsfeedViewController: PictureDetailViewControllerDelegate {
    func didUpdatePictureMetadata(viewController: TDPictureDetailViewController, pictureData picture: TDMyPicture) {
        for (index, oldActivity) in self.activityList.enumerated() {
            if  let imageData = (oldActivity as? PictureActivity)?.picture,
                let imageId = imageData.imageId,
                let updateImageId = picture.imageId,
                imageId == updateImageId {
                self.activityList[index].totalLike = picture.likeCount
                self.activityList[index].totalComment = picture.commentCount
                break
            }
        }
        for cell in tableView.visibleCells {
            if let cell = cell as? SharePictureTableViewCell,
                let imageId = cell.sharePicture.imageId,
                let updateImageId = picture.imageId,
                imageId == updateImageId {
                cell.setSharePictureData(pictureData: picture)
                cell.setShareLikeAndCommentCount(likeCount: picture.likeCount ?? 0, commentCount: picture.commentCount ?? 0)
                break
            }
        }
    }
}

extension TDMyNewsfeedViewController: TripDetailViewControllerDelegate {
    func didUpdateCityMetadata(viewController: TDTripDetailViewController, cityData city: TDTripCity) {
        
        for (index, currentCity) in self.activityList.enumerated() {
            if let cityData = currentCity as? CityActivity,
                let currentCityId = cityData.city.id,
                let updateCityId = city.id,
                currentCityId == updateCityId {
                self.activityList[index].totalLike = city.likeCount
                self.activityList[index].totalComment = city.commentCount
                self.tableView.reloadData()
                break
            }
        }
    }
}

extension TDMyNewsfeedViewController: ShareCountryTableViewCellDelegate {
    func didChooseCountryOnMap(tableViewCell: ShareCountryTableViewCell, friendInfo friend: TDUser?, withTrip trip: TDTrip, withCountryName countryName: String, withCountryCode countryCode: String, coordinate: CLLocationCoordinate2D) {
        let cityTripListVC = TDCityTripListViewController.newInstance()
        cityTripListVC.countryName = countryName
        cityTripListVC.countryCode = countryCode
        cityTripListVC.friendInfo = friend
        cityTripListVC.currentCountryCodinate = coordinate
        if let id = trip.tripId {
            cityTripListVC.tripId = id
            self.navigationController?.pushViewController(cityTripListVC, animated: true)
        }
    }
    
}

extension TDMyNewsfeedViewController: ShareTableViewCellDelegate {
    func didTapToVisitFriendProfile(friendProfile: TDUser) {
        guard let userId = friendProfile.id else {return}
        let friendInfoVC = TDFriendProfileViewController.newInstance()
        friendInfoVC.userId = userId
        self.navigationController?.pushViewController(friendInfoVC, animated: true)
    }
}

extension TDMyNewsfeedViewController: ShareStampTableViewCellDelegate {
    func didLoadStampView(view: ShareStampTableViewCell, isdownloadAt: Int, andViews: [OneStampView]) {
        self.oneStampViewDict[isdownloadAt] = andViews
    }
}


