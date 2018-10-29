    //
//  TDTripListViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 12/2/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import MJRefresh

class TDTripListViewController: TDBaseViewController {
    
    // MARK: - Scrolling delegate
    weak var scrollingDelegate: FriendProfileContentScrollingDelegate?;
    
    // MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leftFilterNameLabel: UILabel!
    @IBOutlet weak var countryFilterNameLabel: UILabel!
    
    @IBOutlet weak var leftFilterView: UIView!
    // MARK:- Properties
    
    var friendId: String? // Only use for view Friend profile
    
    var isFriendTrip: Bool = false
    var tripList: [TDTrip] = []
    var expandTripArray: [Int] = []
    var friendtTripList: [TDTrip] = []
    var friendExpandTripArray: [Int] = []
    
    let header = MJRefreshNormalHeader()
    let footer = MJRefreshBackNormalFooter()
    
    fileprivate var currentMyPage  =  0
    fileprivate var currentFriendPage  =  0
    fileprivate var timeFilterKey: String?
    fileprivate var countryFiterKey: String?
    fileprivate var friendFilterKey: String?
    fileprivate var hasMyTripLoaded = false
    fileprivate var hasFriendTripLoaded = false
    
    // MARK:- Public method
    
    static func newInstance() -> TDTripListViewController {
        return UIStoryboard.init(name: "MyTrips", bundle: nil).instantiateViewController(withIdentifier: "TDTripListViewController") as! TDTripListViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeNavigationBarToTransparentStyle()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK:- Private method
    fileprivate func setupView() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshData), name: NotificationName.didCreateTripSuccess, object: nil)
        
        if self.isFriendTrip {
            self.leftFilterNameLabel.text = "All Friends"
        } else {
            self.leftFilterNameLabel.text = "Recent Added"
        }
        
        if let _ = self.friendId {
            // Hiden selection button in friend view
            self.leftFilterView.isHidden = true
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Set refreshing with target
        self.header.setRefreshingTarget(self, refreshingAction: #selector(self.refreshData))
        // add header to table view
        self.tableView.mj_header = self.header
        
        self.footer.setRefreshingTarget(self, refreshingAction: #selector(self.loadData))
        // add header to table view
        self.tableView.mj_footer = self.footer
        
        self.tableView.allowsSelectionDuringEditing = false;
        
        self.loadData()
    }
    
    // pull-down to refresh
    @objc fileprivate func refreshData() {
        
        // Noti to TDFriendProfileViewController to update total count
        self.scrollingDelegate?.didPullToRefresh(self)
        
        xt_startNetworkIndicatorView(withMessage: "Loading...")
        if self.isFriendTrip {
            
            // Firebase analytics
            FIR_MANAGER.sendAppEvent(withEvent: FIREvent.LOAD_FRIEND_TRIP_FUNCTION.rawValue, userId: nil)
            
            self.currentFriendPage = 1
            API_MANAGER.requestGetTripList(isfriendTrip: true, page: self.currentFriendPage, perPage: 10, showImage: 0, country: self.countryFiterKey, time: self.timeFilterKey, friendId: self.friendFilterKey, userId: self.friendId, success: { (baseData) in
                self.tableView.mj_header.endRefreshing()
                self.xt_stopNetworkIndicatorView()
                self.friendtTripList = baseData.tripList ?? []
                self.hasFriendTripLoaded = true
                self.tableView.reloadData()
            }, failure: { (error) in
                self.hasFriendTripLoaded = true
                self.tableView.reloadData()
                self.tableView.mj_header.endRefreshing()
                self.xt_stopNetworkIndicatorView()
                UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            })
        } else {
            
            // Firebase analytics
            FIR_MANAGER.sendAppEvent(withEvent: FIREvent.LOAD_MY_TRIP_FUNCTION.rawValue, userId: nil)
            
            self.currentMyPage = 1
            API_MANAGER.requestGetTripList(isfriendTrip: false, page: self.currentMyPage, perPage: 10, showImage: 0, country: self.countryFiterKey, time: self.timeFilterKey, friendId: self.friendFilterKey, userId: self.friendId, success: { (baseData) in
                self.tableView.mj_header.endRefreshing()
                self.xt_stopNetworkIndicatorView()
                self.tripList = baseData.tripList ?? []
                self.hasMyTripLoaded = true
                self.tableView.reloadData()
            }, failure: { (error) in
                self.hasMyTripLoaded = true
                self.tableView.reloadData()
                self.tableView.mj_header.endRefreshing()
                self.xt_stopNetworkIndicatorView()
                UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            })
        }
    }
    
    // pull-up to loadmore
    @objc fileprivate func loadData(isShowIndicator: Bool = true) {
        if isShowIndicator {
            self.xt_startNetworkIndicatorView(withMessage: "Loading...")
        }
        if self.isFriendTrip {
            self.currentFriendPage += 1
            API_MANAGER.requestGetTripList(isfriendTrip: true, page: self.currentFriendPage, perPage: 10, showImage: 0, country: self.countryFiterKey, time: self.timeFilterKey, friendId: self.friendFilterKey, userId: self.friendId, success: { (baseData) in
                self.tableView.mj_footer.endRefreshing()
                self.xt_stopNetworkIndicatorView()
                // Add data to tableview
                self.friendtTripList.append(contentsOf: baseData.tripList ?? [])
                self.tableView.reloadData()
            }) { (error) in
                self.tableView.mj_footer.endRefreshing()
                self.xt_stopNetworkIndicatorView()
                UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            }
        } else {

            self.currentMyPage += 1
            API_MANAGER.requestGetTripList(isfriendTrip: false, page: self.currentMyPage, perPage: 10, showImage: 0, country: self.countryFiterKey, time: self.timeFilterKey, friendId: self.friendFilterKey, userId: self.friendId, success: { (baseData) in
                self.tableView.mj_footer.endRefreshing()
                self.xt_stopNetworkIndicatorView()
                // Add data to tableview
                self.tripList.append(contentsOf: baseData.tripList ?? [])
                self.tableView.reloadData()
            }) { (error) in
                self.tableView.mj_footer.endRefreshing()
                self.xt_stopNetworkIndicatorView()
                UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            }
        }
    }
    
    //MARK:- Action Method
    @IBAction func timeButtonTapped(_ sender: UIButton) {
        if self.isFriendTrip {
            let filterFriendVC = TDFilterFriendListViewController.newInstance()
            filterFriendVC.delegate = self
            self.present(filterFriendVC, animated: true, completion: nil)
        } else {
            let filterTimeVC = TDFilterTimeListViewController.newInstance()
            filterTimeVC.delegate = self
            self.present(filterTimeVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func countryButtonTapped(_ sender: UIButton) {
        let filterCountryVC = TDFilterCountryListViewController.newInstance()
        if let friendId = self.friendId, let friendIdInt = Int(friendId) {
            filterCountryVC.friendId = friendIdInt
            filterCountryVC.countryTypeFilter = .friendTrip
        } else {
            filterCountryVC.countryTypeFilter = .userId
        }
        
        filterCountryVC.delegate = self
        self.present(filterCountryVC, animated: true, completion: nil)
    }
    
}

extension TDTripListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension TDTripListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFriendTrip {
            return self.friendtTripList.count
        } else {
            return self.tripList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripDetail", for: indexPath) as! TripDetailTableViewCell
        if self.friendId != nil {
            // Handle show profile friend
            cell.setData(data: self.friendtTripList[indexPath.row], expandTripArray: self.friendExpandTripArray, isFriendTrip: true, isFriendProfile: true)
        } else {
            let tripData = self.tripList[indexPath.row]
            if "\(tripData.ownerId ?? 0)" == TDUser.currentUser()?.id {
                cell.setData(data: self.tripList[indexPath.row], expandTripArray: self.expandTripArray)
            } else {
                cell.setData(data: self.tripList[indexPath.row], expandTripArray: self.expandTripArray, isFriendTrip: true)
            }
        }
        
        cell.tripMapViewDelegate = self
        cell.didToogleCellDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
}

extension TDTripListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollingDelegate?.childViewController(self, didScroll: scrollView);
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollingDelegate?.childViewController(self, didEndDecelerating: scrollView);
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.scrollingDelegate?.childViewController(self, willEndDragging: scrollView, velocity: velocity);
    }
}

extension TDTripListViewController: TripDetailTableViewCellDelegate {
    
    func didTapButtonWithType(tableViewCell: TripDetailTableViewCell, withAction type: PostActionType, atTrip trip: TDTrip?, shareScreenShot screenShot: UIImage?) {
        switch type {
        case .share:
            UIAlertController.showActionSheet(in: self, withTitle: title, message: nil, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: ["Share On The Activity", "Share On Facebook"], popoverPresentationControllerBlock: { (popOver) in
                popOver.sourceView = self.view
                
            }) { (controller, index) in
                if (index == 3) {
                    // Share on Facebook
                    if let screenShot = screenShot {
                        FACEBOOK_MANAGER.sharePicture(image: screenShot, hastag: "TravelXTrip", viewController: self)
                    }
                } else if (index == 2) {
                    // Share on the activity
                    if let tripId = trip?.tripId {
                        self.xt_startNetworkIndicatorView(withMessage: "Sharing...")
                        
                        // Firebase analytics
                        FIR_MANAGER.sendAppEvent(withEvent: FIREvent.SHARE_TRIP_FUNCTION.rawValue, userId: nil)
                        
                        API_MANAGER.requestShareActivityWithType(activityId: tripId, activityType: "Country", stampIdArray: nil, success: { message in
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
            _ = self.showAlertWithTitle(nil, message: "Are you sure you want to delete? Photos will be deleted.", okButton: "YES", alertViewType:.alert, okHandler: { (actionSheet) in
                if let indexPath = self.tableView.indexPath(for: tableViewCell) {
                    self.xt_startNetworkIndicatorView(withMessage: "Deleting...")
                    API_MANAGER.requesDeleteTrip(tripId: self.tripList[indexPath.row].tripId ?? 0, success: {
                        self.tripList.remove(self.tripList[indexPath.row])
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        self.tableView.reloadData()
                        self.xt_stopNetworkIndicatorView()
                    }, failure: { (error) in
                        self.xt_stopNetworkIndicatorView()
                        UIAlertController.show(in: self, withTitle: "Failed to delete trip", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil);
                    })
                }
            }, closeButton: "CANCEL", closeHandler: { (actionSheet) in }, completionHanlder: nil)
            break
        case .edit:
            // open edit trip page
            let editTripVC = TDCreateTripViewController.newInstance()
            editTripVC.editTrip = trip!
            self.navigationController?.pushViewController(editTripVC, animated: true)
            break
        case .view:
            guard let userId = trip?.friend?.id else {return}
            let friendInfoVC = TDFriendProfileViewController.newInstance()
            friendInfoVC.userId = userId
            self.navigationController?.pushViewController(friendInfoVC, animated: true)
        default:
            break
        }
    }
    
    func didTapButtonToToogleCell(tableViewCell: TripDetailTableViewCell, atTripId: Int, isFriendTrip: Bool) {
        
        if isFriendTrip {
            if (self.friendExpandTripArray.contains(atTripId)) {
                self.friendExpandTripArray.remove(atTripId)
                tableViewCell.configStatusCell(expandTripArray: self.friendExpandTripArray)
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            } else {
                self.friendExpandTripArray.append(atTripId)
                tableViewCell.configStatusCell(expandTripArray: self.friendExpandTripArray)
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        } else {
            if (self.expandTripArray.contains(atTripId)) {
                self.expandTripArray.remove(atTripId)
                tableViewCell.configStatusCell(expandTripArray: self.expandTripArray)
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            } else {
                self.expandTripArray.append(atTripId)
                tableViewCell.configStatusCell(expandTripArray: self.expandTripArray)
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
        
    }
    
}

extension TDTripListViewController: TripMapViewDelegate {
    func didTapAnntatioCountry(tripMapView: TripMapView, atTripId tripId: Int, friendInfo: TDUser?, andCountryCode countryCode: String?, coordinate: CLLocationCoordinate2D, andCountryName countryName: String?, andCityId cityId: Int?, andCityName cityName: String?) {
        let cityTripListVC = TDCityTripListViewController.newInstance()
        if let countryName = countryName,
            let countryCode = countryCode {
            cityTripListVC.tripId = tripId
            cityTripListVC.countryName = countryName
            cityTripListVC.countryCode = countryCode
            cityTripListVC.currentCountryCodinate = coordinate
            if let _ = friendInfo {
                cityTripListVC.friendInfo = friendInfo
            }
            // Check is friend profile
            if let _ = self.friendId {
                cityTripListVC.isFriendProfile = true
            }
            self.navigationController?.pushViewController(cityTripListVC, animated: true)
        }
    }    
}

extension TDTripListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
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
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        if self.isFriendTrip {
            return self.hasFriendTripLoaded
        }
        return self.hasMyTripLoaded
    }
}

extension TDTripListViewController: FilterTimeListViewControllerDelegate {
    func didSelectFilterTime(viewController: TDFilterTimeListViewController, filterTimeKey: (key: String?, title: String), resignFilterMode resign: Bool) {
        if resign {
            self.timeFilterKey = nil
            self.leftFilterNameLabel.text = "Recent Added"
        } else {
            self.timeFilterKey = filterTimeKey.key
            self.leftFilterNameLabel.text = filterTimeKey.title
        }
        self.refreshData()
    }
}

extension TDTripListViewController: FilterCountryListViewControllerDelegate {
    func didSelectFilterCountry(viewController: TDFilterCountryListViewController, filterCountryKey: (key: String?, title: String), resignFilterMode resign: Bool) {
        if resign {
            self.countryFiterKey = nil
            self.countryFilterNameLabel.text = "All Country"
        } else {
            self.countryFiterKey = filterCountryKey.key
            self.countryFilterNameLabel.text = filterCountryKey.title
        }
        self.refreshData()
    }
}

extension TDTripListViewController: FilterFriendListViewControllerDelegate {
    func didSelectFilterFriend(viewController: TDFilterFriendListViewController, filterFriendKey: (key: String?, title: String), resignFilterMode resign: Bool) {
        if resign {
            self.friendFilterKey = nil
            self.leftFilterNameLabel.text = "All Friends"
        } else {
            self.friendFilterKey = filterFriendKey.key
            self.leftFilterNameLabel.text = filterFriendKey.title
        }
        self.refreshData()
    }
}

