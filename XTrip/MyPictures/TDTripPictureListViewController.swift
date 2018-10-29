//
//  TDTripPictureListViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 12/15/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import MJRefresh
import FacebookShare
import FBSDKShareKit
import Social

class TDTripPictureListViewController: TDBaseViewController {
    
    // MARK: - Scrolling delegate
    weak var scrollingDelegate: FriendProfileContentScrollingDelegate?;
    
    // MARK:- Outlets
    @IBOutlet weak var leftFilterView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var leftFilterNameLabel: UILabel!
    @IBOutlet weak var countryFilterNameLabel: UILabel!
    
    // MARK:- Properties
    var friendId: String? // Only use for view Friend profile
    
    var isFriendPicture: Bool = false
    var myPictureList: [TDTrip] = []
    var friendPictureList: [TDTrip] = []
    let header = MJRefreshNormalHeader()
    let footer = MJRefreshBackNormalFooter()
    
    fileprivate var currentMyPage  =  0
    fileprivate var currentFriendPage  =  0
    fileprivate var timeFilterKey: String?
    fileprivate var countryFiterKey: String?
    fileprivate var friendFilterKey: String?
    fileprivate var hasMyPicLoaded = false
    fileprivate var hasFriendPicLoaded = false
    
    // MARK:- Public method
    static func newInstance() -> TDTripPictureListViewController {
        return UIStoryboard.init(name: "MyPictures", bundle: nil).instantiateViewController(withIdentifier: "TDTripPictureListViewController") as! TDTripPictureListViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshData), name: NotificationName.didEditPictureSuccess, object: nil)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.goToMyTripPicture), name: NotificationName.didUploadPictureSuccess, object: nil)
        
        if self.isFriendPicture {
            self.leftFilterNameLabel.text = "All Friends"
        } else {
            self.leftFilterNameLabel.text = "Recent Added"
        }
        
        if let _ = self.friendId {
            // Hiden selection button in friend view
            self.leftFilterView.isHidden = true
        }
        
        self.header.setRefreshingTarget(self, refreshingAction: #selector(self.refreshData))
        // add header to table view
        self.tableView.mj_header = self.header
        
        self.footer.setRefreshingTarget(self, refreshingAction: #selector(self.loadData))
        // add header to table view
        self.tableView.mj_footer = self.footer
        
        self.loadData()
    }
    
    // pull-down to refresh data
    @objc fileprivate func refreshData (isShowIndicator: Bool = true) {
        
        // Noti to TDFriendProfileViewController to update total count
        self.scrollingDelegate?.didPullToRefresh(self)
        
        if isShowIndicator {
            self.xt_startNetworkIndicatorView(withMessage: "Loading...")
        }
        if self.isFriendPicture {
            self.currentFriendPage = 1
            
            // Firebase analytics
            FIR_MANAGER.sendAppEvent(withEvent: FIREvent.LOAD_MY_PIC_FUNCTION.rawValue, userId: nil)
            
            API_MANAGER.requestGetTripList(isfriendTrip: true, page: self.currentFriendPage, perPage: 5, showImage: 1, country: self.countryFiterKey, time: self.timeFilterKey, friendId: self.friendFilterKey, userId: self.friendId, success: { (baseData) in
                self.tableView.mj_header.endRefreshing()
                self.xt_stopNetworkIndicatorView()
                // Add data to tableview
                self.friendPictureList = baseData.tripList ?? []
                self.hasFriendPicLoaded = true
                self.tableView.reloadData()
            }) { (error) in
                self.hasFriendPicLoaded = true
                self.tableView.reloadData()
                self.tableView.mj_header.endRefreshing()
                self.xt_stopNetworkIndicatorView()
                UIAlertController.show(in: self, withTitle: "Error", message: "Can't load albums", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            }
        } else {
            self.currentMyPage = 1
            
            // Firebase analytics
            FIR_MANAGER.sendAppEvent(withEvent: FIREvent.LOAD_FRIEND_CITY_TRIP_FUNCTION.rawValue, userId: nil)
            
            API_MANAGER.requestGetTripList(isfriendTrip: false, page: self.currentMyPage, perPage: 5, showImage: 1, country: self.countryFiterKey, time: self.timeFilterKey, friendId: self.friendFilterKey, userId: self.friendId, success: { (baseData) in
                self.tableView.mj_header.endRefreshing()
                self.xt_stopNetworkIndicatorView()
                // Add data to tableview
                self.myPictureList = baseData.tripList ?? []
                self.hasMyPicLoaded = true
                self.tableView.reloadData()
            }) { (error) in
                self.hasMyPicLoaded = true
                self.tableView.reloadData()
                self.tableView.mj_header.endRefreshing()
                self.xt_stopNetworkIndicatorView()
                UIAlertController.show(in: self, withTitle: "Error", message: "Can't load albums", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            }
        }
    }
    
    // pull-up to loadmore
    @objc fileprivate func loadData(isShowIndicator: Bool = true) {
        if isShowIndicator {
            self.xt_startNetworkIndicatorView(withMessage: "Loading...")
        }
        if self.isFriendPicture {
            self.currentFriendPage += 1
            API_MANAGER.requestGetTripList(isfriendTrip: true, page: self.currentFriendPage, perPage: 5, showImage: 1, country: self.countryFiterKey, time: self.timeFilterKey, friendId: self.friendFilterKey, userId: self.friendId, success: { (baseData) in
                self.tableView.mj_footer.endRefreshing()
                self.xt_stopNetworkIndicatorView()
                // Add data to tableview
                self.friendPictureList.append(contentsOf: baseData.tripList ?? [])
                self.tableView.reloadData()
            }) { (error) in
                self.tableView.mj_footer.endRefreshing()
                self.xt_stopNetworkIndicatorView()
                UIAlertController.show(in: self, withTitle: "Error", message: "Can't load albums", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            }
        } else {
            self.currentMyPage += 1
            API_MANAGER.requestGetTripList(isfriendTrip: false, page: self.currentMyPage, perPage: 5, showImage: 1, country: self.countryFiterKey, time: self.timeFilterKey, friendId: self.friendFilterKey, userId: self.friendId, success: { (baseData) in
                self.tableView.mj_footer.endRefreshing()
                self.xt_stopNetworkIndicatorView()
                // Add data to tableview
                self.myPictureList.append(contentsOf: baseData.tripList ?? [])
                self.tableView.reloadData()
            }) { (error) in
                self.tableView.mj_footer.endRefreshing()
                self.xt_stopNetworkIndicatorView()
                UIAlertController.show(in: self, withTitle: "Error", message: "Can't load albums", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            }
        }
    }
    
    fileprivate func setDefaultSetting() {
        if self.isFriendPicture {
            self.currentFriendPage = 0
            self.friendPictureList.removeAll()
        } else {
            self.currentMyPage = 0
            self.myPictureList.removeAll()
        }
        
    }

    func goToMyTripPicture(_ notification: NSNotification) {
        let pictureListVC = TDPictureListViewController.newInstance()
        if let tripId = notification.userInfo?["tripId"] as? Int,
            let tripName = notification.userInfo?["tripName"] as? String {
            pictureListVC.tripId = tripId
            pictureListVC.tripName = tripName
            self.navigationController?.popToRootViewController(animated: false)
            self.navigationController?.pushViewController(pictureListVC, animated: true)
        }
    }
    
    //MARK:- Action method
    @IBAction func friendButtonTapped(_ sender: UIButton) {
        if self.isFriendPicture {
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
            filterCountryVC.countryTypeFilter = .myPicture
        }
        filterCountryVC.delegate = self
        self.present(filterCountryVC, animated: true, completion: nil)
    }
}

extension TDTripPictureListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFriendPicture {
            return self.friendPictureList.count
        } else {
            return self.myPictureList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyTripPictureCell") as! TripPictureTableViewCell
        cell.delegate = self
        if self.isFriendPicture {
            if let _ = self.friendId {
                cell.setData(tripData: self.friendPictureList[indexPath.row], isFriendPicture: true, isFriendProfile: true)
            } else {
                cell.setData(tripData: self.friendPictureList[indexPath.row], isFriendPicture: true)
            }
        } else {
            cell.setData(tripData: self.myPictureList[indexPath.row], isFriendPicture: false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 247
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pictureData = self.isFriendPicture ? self.friendPictureList[indexPath.row] : self.myPictureList[indexPath.row]
        let pictureListVC = TDPictureListViewController.newInstance()
        pictureListVC.friendData = pictureData.friend
        pictureListVC.tripId = pictureData.tripId
        pictureListVC.tripName = pictureData.name
        pictureListVC.isFriendPicture = self.isFriendPicture
        if let _ = self.friendId {
            pictureListVC.isFriendProfile = true
        }
        self.navigationController?.pushViewController(pictureListVC, animated: true)
    }
}

extension TDTripPictureListViewController: TripPictureTableViewDelegate {
    func didTapButtonWithType(footerView: TripPictureTableViewCell, withAction type: PostActionType, atTrip trip: TDTrip?, atPicture picture: TDMyPicture?, shareScreenShot screenShot: UIImage?) {
        switch type {
        case .share:
            if let isUpload = picture?.isUpload, isUpload == false {
                UIAlertController.show(in: self, withTitle: "Notice", message: "Please update the picture before sharing", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            } else {
                UIAlertController.showActionSheet(in: self, withTitle: title, message: nil, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: ["Share On The Activity", "Share On Facebook"], popoverPresentationControllerBlock: { (popOver) in
                    popOver.sourceView = self.view
                    
                }) { (controller, index) in
                    if (index == 3) {
                        // Share on Facebook
                        if let screenShot = screenShot {
                            FACEBOOK_MANAGER.sharePicture(image: screenShot, hastag: "TravelXAlbum", viewController: self)
                        }
                    } else if (index == 2) {
                        // Share on the activity
                        if let tripId = trip?.tripId {
                            self.xt_startNetworkIndicatorView(withMessage: "Sharing...")
                            
                            // Firebase analytics
                            FIR_MANAGER.sendAppEvent(withEvent: FIREvent.SHARE_PIC_FUNCTION.rawValue, userId: nil)
                            
                            API_MANAGER.requestShareActivityWithType(activityId: tripId, activityType: "Album", stampIdArray: nil, success: { message in
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
            }
        case .delete:
            _ = self.showAlertWithTitle(nil, message: "Are you sure you want to delete ?", okButton: "YES", alertViewType:.alert, okHandler: { (actionSheet) in
                self.xt_startNetworkIndicatorView(withMessage: "Deleting...")
                if let imageId = trip?.tripLastPicture?.imageId {
                    API_MANAGER.requesDeleteTripPicture(pictureId: imageId, success: {
                        // Refresh Data
                        self.refreshData(isShowIndicator: false)
                    }, failure: { (error) in
                        self.xt_stopNetworkIndicatorView()
                        UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                    })
                }
            }, closeButton: "NO THANKS", closeHandler: { (actionSheet) in }, completionHanlder: nil)
        case .like:
            let currentPicArray = self.isFriendPicture ? self.friendPictureList : self.myPictureList
            if  let imageId = trip?.tripLastPicture?.imageId {
                
                let isLike = trip?.tripLastPicture?.isLiked
                var behavior: String = "like"
                if let isLike = isLike, isLike == true {
                    behavior = "unlike"
                }
                self.xt_startNetworkIndicatorView(withMessage: "Posting...")
                
                // Firebase analytics
                FIR_MANAGER.sendAppEvent(withEvent: FIREvent.LIKE_PIC_FUNCTION.rawValue, userId: nil)
                
                API_MANAGER.requestLikeTripPicture(pictureId: imageId, behavior: behavior, success: { (updatePic) in
                    self.xt_stopNetworkIndicatorView()
                    for (index, currentPic) in currentPicArray.enumerated() {
                        if let currentPicId = currentPic.tripLastPicture?.imageId,
                            imageId == currentPicId {
                            if self.isFriendPicture {
                                self.friendPictureList[index].tripLastPicture = updatePic
                            } else {
                                self.myPictureList[index].tripLastPicture = updatePic
                            }
                            break
                        }
                    }
                    for cell in self.tableView.visibleCells {
                        if let cell = cell as? TripPictureTableViewCell,
                            let imageId = cell.tripData.tripLastPicture?.imageId,
                            let updateImageId = trip?.tripLastPicture?.imageId,
                            imageId == updateImageId {
                            if self.isFriendPicture {
                                cell.friendPicLikeImageView.image = updatePic.isLiked ?? false ? #imageLiteral(resourceName: "button_heart") : #imageLiteral(resourceName: "button_not_heart")
                                cell.friendPicLikeLabel.text = "\(updatePic.likeCount ?? 0)"
                                cell.friendPicCommentLabel.text = "\(updatePic.commentCount ?? 0)"
                            } else {
                                cell.myPicLikeImageView.image = updatePic.isLiked ?? false ? #imageLiteral(resourceName: "button_heart") : #imageLiteral(resourceName: "button_not_heart")
                                cell.myPicLikeLabel.text = "\(updatePic.likeCount ?? 0)"
                                cell.myPicCommentLabel.text = "\(updatePic.commentCount ?? 0)"
                            }
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
            FIR_MANAGER.sendAppEvent(withEvent: FIREvent.CMT_PIC_FUNCTION.rawValue, userId: nil)
            
            guard let pictureId = trip?.tripLastPicture?.imageId else {return}
            guard let pictureName = trip?.tripLastPicture?.caption else {return}
            let pictureDetailVC = TDPictureDetailViewController.newInstance()
            pictureDetailVC.pictureId = pictureId
            pictureDetailVC.pictureCaption = pictureName
            self.navigationController?.pushViewController(pictureDetailVC, animated: true)
        case .update:
            break
        case .edit:
            if let lastPic = trip?.tripLastPicture {
                let editPhotoInfoVC = TDEditPhotoInfoViewController.newInstance()
                editPhotoInfoVC.delegate = self
                editPhotoInfoVC.tripPictureDataArray.append(lastPic)
                self.navigationController?.pushViewController(editPhotoInfoVC, animated: true)
            }
        case .view:
            guard let userId = trip?.friend?.id else {return}
            let friendInfoVC = TDFriendProfileViewController.newInstance()
            friendInfoVC.userId = userId
            self.navigationController?.pushViewController(friendInfoVC, animated: true)
        }
    }
}

extension TDTripPictureListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Opps!", attributes: nil)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No pictures to show", attributes: nil)
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
        return #imageLiteral(resourceName: "refesh")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        button.rotateButton(animationDuration: 1, inSecond: 10)
        self.refreshData()
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        if self.isFriendPicture {
            return self.hasFriendPicLoaded
        }
        return self.hasMyPicLoaded
    }
}

extension TDTripPictureListViewController: FilterTimeListViewControllerDelegate {
    func didSelectFilterTime(viewController: TDFilterTimeListViewController, filterTimeKey: (key: String?, title: String), resignFilterMode resign: Bool) {
        if resign {
            self.timeFilterKey = nil
            self.leftFilterNameLabel.text = "Recent Added"
        } else {
            self.timeFilterKey = filterTimeKey.key
            self.leftFilterNameLabel.text = filterTimeKey.title
        }
        self.refreshData(isShowIndicator: true)
    }
}

extension TDTripPictureListViewController: FilterCountryListViewControllerDelegate {
    func didSelectFilterCountry(viewController: TDFilterCountryListViewController, filterCountryKey: (key: String?, title: String), resignFilterMode resign: Bool) {
        if resign {
            self.countryFiterKey = nil
            self.countryFilterNameLabel.text = "All Country"
        } else {
            self.countryFiterKey = filterCountryKey.key
            self.countryFilterNameLabel.text = filterCountryKey.title
        }
        self.refreshData(isShowIndicator: true)
    }
}

extension TDTripPictureListViewController: FilterFriendListViewControllerDelegate {
    func didSelectFilterFriend(viewController: TDFilterFriendListViewController, filterFriendKey: (key: String?, title: String), resignFilterMode resign: Bool) {
        if resign {
            self.friendFilterKey = nil
            self.leftFilterNameLabel.text = "All Friends"
        } else {
            self.friendFilterKey = filterFriendKey.key
            self.leftFilterNameLabel.text = filterFriendKey.title
        }
        self.refreshData(isShowIndicator: true)
    }
}

extension TDTripPictureListViewController: UpdatePhotoInfoViewControllerDelegate {
    
    func didUploadSuccess(viewController: TDUpdatePhotoInfoViewController, withPicture updatePic: TDMyPicture) {
        let currentPicArray = self.isFriendPicture ? self.friendPictureList : self.myPictureList
        for (index, currentPic) in currentPicArray.enumerated() {
            if let currentPicId = currentPic.tripLastPicture?.imageId,
                let imageId = updatePic.imageId,
                imageId == currentPicId {
                if self.isFriendPicture {
                    self.friendPictureList[index].tripLastPicture = updatePic
                } else {
                    self.myPictureList[index].tripLastPicture = updatePic
                }
                break
            }
        }
        for cell in self.tableView.visibleCells {
            if let cell = cell as? TripPictureTableViewCell,
                let imageId = cell.tripData.tripLastPicture?.imageId,
                let updatePicId = updatePic.imageId,
                imageId == updatePicId {
                if self.isFriendPicture {
                    cell.friendPicLikeImageView.image = updatePic.isLiked ?? false ? #imageLiteral(resourceName: "button_heart") : #imageLiteral(resourceName: "button_not_heart")
                    cell.friendPicLikeLabel.text = "\(updatePic.likeCount ?? 0)"
                    cell.friendPicCommentLabel.text = "\(updatePic.commentCount ?? 0)"
                } else {
                    cell.myPicLikeImageView.image = updatePic.isLiked ?? false ? #imageLiteral(resourceName: "button_heart") : #imageLiteral(resourceName: "button_not_heart")
                    cell.myPicLikeLabel.text = "\(updatePic.likeCount ?? 0)"
                    cell.myPicCommentLabel.text = "\(updatePic.commentCount ?? 0)"
                }
                break
            }
        }
    }
}


extension TDTripPictureListViewController: UIScrollViewDelegate {
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

