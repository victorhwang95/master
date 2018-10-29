//
//  TDPictureListViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 1/7/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit
import MJRefresh
import DZNEmptyDataSet

class TDPictureListViewController: TDBaseViewController {
    
    // MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK:- Properties
    var tripName: String!
    var tripId: Int!
    var friendData: TDUser?
    var isFriendPicture: Bool = false
    fileprivate var currentMyPage  =  0
    var myPictureList: [TDMyPicture] = []
    let header = MJRefreshNormalHeader()
    let footer = MJRefreshBackNormalFooter()
    var hasLoaded: Bool = false
    var isFriendProfile: Bool = false // Use in the friend profile layout

    // MARK:- Public method
    static func newInstance() -> TDPictureListViewController {
        return UIStoryboard.init(name: "MyPictures", bundle: nil).instantiateViewController(withIdentifier: "TDPictureListViewController") as! TDPictureListViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshData), name: NotificationName.didEditPictureSuccess, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = self.tripName
        setupRightButtons(buttonType: .setting)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK:- Private method
    fileprivate func setupView() {
        
        self.header.setRefreshingTarget(self, refreshingAction: #selector(self.refreshData))
        // add header to table view
        self.tableView.mj_header = self.header
        
        self.footer.setRefreshingTarget(self, refreshingAction: #selector(self.loadData))
        // add header to table view
        self.tableView.mj_footer = self.footer
        
        if let localPicture = TDMyPicture.getCurrentMyPictureList() as? [TDMyPicture] {
            self.myPictureList.removeAll()
            for localPic in localPicture {
                if localPic.tripId == self.tripId {
                    self.myPictureList.append(localPic)
                }
            }
            self.tableView.reloadData()
        }
        self.loadData()
    }
    
    // pull-down to refresh data
    @objc fileprivate func refreshData (isShowIndicator: Bool = true) {
        self.myPictureList.removeAll()
        if let localPicture = TDMyPicture.getCurrentMyPictureList() as? [TDMyPicture] {
            for localPic in localPicture {
                if localPic.tripId == self.tripId {
                    self.myPictureList.append(localPic)
                }
            }
        }
        if isShowIndicator {
            self.xt_startNetworkIndicatorView(withMessage: "Loading...")
        }
        self.currentMyPage = 1
        
        // Firebase analytics
        FIR_MANAGER.sendAppEvent(withEvent: FIREvent.UPLOAD_PIC_FUNCTION.rawValue, userId: nil)
        
        API_MANAGER.requestGetTripListImage(tripId: self.tripId, page: self.currentMyPage, perPage: 5, success: { (baseData) in
            self.tableView.mj_header.endRefreshing()
            self.xt_stopNetworkIndicatorView()
            // Add data to tableview
            self.myPictureList.append(contentsOf: baseData.pictureList ?? [])
            self.hasLoaded = true
            self.tableView.reloadData()
        }, failure: { (error) in
            self.hasLoaded = true
            self.tableView.reloadData()
            self.tableView.mj_header.endRefreshing()
            self.xt_stopNetworkIndicatorView()
//            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: { (alerController, index) in
                self.navigationController?.popViewController(animated: true)
            })
        })
    }
    
    // pull-up to loadmore
    @objc fileprivate func loadData(isShowIndicator: Bool = true) {
        if isShowIndicator {
            self.xt_startNetworkIndicatorView(withMessage: "Loading...")
        }
        self.currentMyPage += 1
        API_MANAGER.requestGetTripListImage(tripId: self.tripId, page: self.currentMyPage, perPage: 5, success: { (baseData) in
            self.tableView.mj_footer.endRefreshing()
            self.xt_stopNetworkIndicatorView()
            // Add data to tableview
            self.myPictureList.append(contentsOf: baseData.pictureList ?? [])
            self.tableView.reloadData()
        }) { (error) in
            self.tableView.mj_footer.endRefreshing()
            self.xt_stopNetworkIndicatorView()
            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        }
    }
    
    fileprivate func loadLocationImage() {
        
    }
}

extension TDPictureListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myPictureList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyTripPictureCell") as! TripPictureTableViewCell
        cell.delegate = self
        let pictureData = self.myPictureList[indexPath.row]
        cell.setPictureData(pictureData: pictureData, friendData: self.friendData , isFriendPicture: self.isFriendPicture, isFriendProfile: self.isFriendProfile)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let pictureId = self.myPictureList[indexPath.row].imageId else {return}
        guard let pictureCaption = self.myPictureList[indexPath.row].caption else {return}
        if self.myPictureList[indexPath.row].isUpload == false{
            UIAlertController.show(in: self, withTitle: "Notice", message: "Please update the picture before viewing the details", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        } else {
            let pictureDetailVC = TDPictureDetailViewController.newInstance()
            pictureDetailVC.delegate = self
            pictureDetailVC.pictureId = pictureId
            pictureDetailVC.pictureCaption = pictureCaption
            pictureDetailVC.isFriendProfile = self.isFriendProfile
            self.navigationController?.pushViewController(pictureDetailVC, animated: true)
        }
    }
}

extension TDPictureListViewController: TripPictureTableViewDelegate {
    
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
                            FACEBOOK_MANAGER.sharePicture(image: screenShot, hastag: "TravelXPicture", viewController: self)
                        }
                    } else if (index == 2) {
                        if let imageId = picture?.imageId {
                            self.xt_startNetworkIndicatorView(withMessage: "Sharing...")
                            
                            // Firebase analytics
                            FIR_MANAGER.sendAppEvent(withEvent: FIREvent.SHARE_PIC_FUNCTION.rawValue, userId: nil)
                            
                            API_MANAGER.requestShareActivityWithType(activityId: imageId, activityType: "Image", stampIdArray: nil, success: { message in
                                // Refresh Data
                                self.xt_stopNetworkIndicatorView()
                                UIAlertController.show(in: self, withTitle: "Notice", message: message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil);
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
                if let isUpload = picture?.isUpload, isUpload == true {
                    if let imageId = picture?.imageId {
                        API_MANAGER.requesDeleteTripPicture(pictureId: imageId, success: {
                            // Refresh Data
                            self.refreshData(isShowIndicator: false)
                        }, failure: { (error) in
                            self.xt_stopNetworkIndicatorView()
                            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                        })
                    }
                } else {
                    if let pic = picture {
                        TDMyPicture.removeLocalPicture(atPict: pic)
                        self.refreshData(isShowIndicator: false)
                        self.xt_stopNetworkIndicatorView()
                    }
                }
            }, closeButton: "NO THANKS", closeHandler: { (actionSheet) in }, completionHanlder: nil)
        case .like:
            self.xt_startNetworkIndicatorView(withMessage: "Posting...")
            if let imageId = picture?.imageId {
                let isLike = picture?.isLiked
                var behavior: String = "like"
                if let isLike = isLike, isLike == true {
                    behavior = "unlike"
                }
                // Firebase analytics
                FIR_MANAGER.sendAppEvent(withEvent: FIREvent.LIKE_PIC_FUNCTION.rawValue, userId: nil)
                
                API_MANAGER.requestLikeTripPicture(pictureId: imageId, behavior: behavior, success: { (updatePic) in
                    self.xt_stopNetworkIndicatorView()
                    for (index, myPic) in self.myPictureList.enumerated() {
                        if let myPicId = myPic.imageId,
                            imageId == myPicId {
                            self.myPictureList[index] = updatePic
                            break
                        }
                    }
                    for cell in self.tableView.visibleCells {
                        if let cell = cell as? TripPictureTableViewCell,
                            let imageId = cell.pictureData.imageId,
                            let updateImageId = updatePic.imageId,
                            imageId == updateImageId {
                            cell.setPictureData(pictureData: updatePic, friendData: self.friendData , isFriendPicture: self.isFriendPicture)
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
            
            guard let pictureId = picture?.imageId else {return}
            guard let pictureName = picture?.caption else {return}
            let pictureDetailVC = TDPictureDetailViewController.newInstance()
            pictureDetailVC.delegate = self
            pictureDetailVC.pictureId = pictureId
            pictureDetailVC.pictureCaption = pictureName
            pictureDetailVC.isFriendProfile = self.isFriendProfile
            self.navigationController?.pushViewController(pictureDetailVC, animated: true)
        case .update:
            if let picture = picture {
                let editPhotoInfoVC = TDEditPhotoInfoViewController.newInstance()
                editPhotoInfoVC.delegate = self
                editPhotoInfoVC.isUpDatePicture = true
                editPhotoInfoVC.tripPictureDataArray.append(picture)
                self.navigationController?.pushViewController(editPhotoInfoVC, animated: true)
            }
        case .edit:
            if let isUpload = picture?.isUpload, isUpload == false {
                UIAlertController.show(in: self, withTitle: "Notice", message: "Please update the image before editing", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            } else {
                if let picture = picture {
                    let editPhotoInfoVC = TDEditPhotoInfoViewController.newInstance()
                    editPhotoInfoVC.delegate = self
                    editPhotoInfoVC.tripPictureDataArray.append(picture)
                    self.navigationController?.pushViewController(editPhotoInfoVC, animated: true)
                }
            }
        case .view:
            guard let userId = self.friendData?.id else {return}
            let friendInfoVC = TDFriendProfileViewController.newInstance()
            friendInfoVC.userId = userId
            self.navigationController?.pushViewController(friendInfoVC, animated: true)
        }
    }
}


extension TDPictureListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
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
        return self.hasLoaded
    }
}

extension TDPictureListViewController: PictureDetailViewControllerDelegate {
    func didUpdatePictureMetadata(viewController: TDPictureDetailViewController, pictureData picture: TDMyPicture) {
        for (index, oldPic) in self.myPictureList.enumerated() {
            if let imageId = oldPic.imageId,
                let updateImageId = picture.imageId,
                imageId == updateImageId {
                self.myPictureList[index] = picture
                break
            }
        }
        for cell in tableView.visibleCells {
            if let cell = cell as? TripPictureTableViewCell,
                let imageId = cell.pictureData.imageId,
                let updateImageId = picture.imageId,
                imageId == updateImageId {
                cell.setPictureData(pictureData: picture, friendData: self.friendData , isFriendPicture: self.isFriendPicture, isFriendProfile: self.isFriendProfile)
                break
            }
        }
    }
}

extension TDPictureListViewController: UpdatePhotoInfoViewControllerDelegate {
    func didUploadSuccess(viewController: TDUpdatePhotoInfoViewController, withPicture updatePic: TDMyPicture) {
        for (index, oldPic) in self.myPictureList.enumerated() {
            if let imageId = oldPic.imageId,
                let updateImageId = updatePic.imageId,
                imageId == updateImageId {
                self.myPictureList[index] = updatePic
                break
            }
        }
        for cell in tableView.visibleCells {
            if let cell = cell as? TripPictureTableViewCell,
                let imageId = cell.pictureData.imageId,
                let updateImageId = updatePic.imageId,
                imageId == updateImageId {
                cell.setPictureData(pictureData: updatePic, friendData: self.friendData , isFriendPicture: self.isFriendPicture, isFriendProfile: self.isFriendProfile)
                break
            }
        }
    }
}

//extension TDPictureListViewController: EditPhotoInfoViewControllerDelegate {
//    func didEditPictureSuccess(viewController: TDEditPhotoInfoViewController, withPicture updatePic: TDMyPicture) {
//        for (index, oldPic) in self.myPictureList.enumerated() {
//            if let imageId = oldPic.imageId,
//                let updateImageId = updatePic.imageId,
//                imageId == updateImageId {
//                self.myPictureList[index] = updatePic
//                break
//            }
//        }
//        for cell in tableView.visibleCells {
//            if let cell = cell as? TripPictureTableViewCell,
//                let imageId = cell.pictureData.imageId,
//                let updateImageId = updatePic.imageId,
//                imageId == updateImageId {
//                cell.setPictureData(pictureData: updatePic, friendData: self.friendData , isFriendPicture: self.isFriendPicture)
//                break
//            }
//        }
//    }
//}

