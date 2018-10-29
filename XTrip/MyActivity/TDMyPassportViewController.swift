//
//  TDMyPassportViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 1/14/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit
import MJRefresh
import DZNEmptyDataSet

class TDMyPassportViewController: TDBaseViewController {
    
    // MARK: - Scrolling delegate
    weak var scrollingDelegate: FriendProfileContentScrollingDelegate?;
    
    // MARK:- Outlets
    @IBOutlet weak var selectAllStampLabel: UILabel!
    @IBOutlet weak var shareStampButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedAllStampButton: UIButton!
    @IBOutlet weak var topTableViewConstraint: NSLayoutConstraint!
    
    // MARK:- Properties
    fileprivate var hasLoaded: Bool = false
    var stampArray: [TDStamp] = []
    var countrySelectedArray: [Int] = []
    var stampSelectedArray: [TDStamp] = []
    let header = MJRefreshNormalHeader()
    
    var friendId: String? // Only use for view Friend profile
    
    var stampRotationDict: [Int : Int] = [:]
    
    // MARK:- Public method
    static func newInstance() -> TDMyPassportViewController {
        return UIStoryboard.init(name: "MyActivity", bundle: nil).instantiateViewController(withIdentifier: "TDMyPassportViewController") as! TDMyPassportViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = self.friendId {
            // Hiden selection button in friend view
            self.selectedAllStampButton.isHidden = true
            self.shareStampButton.isHidden = true
            self.selectAllStampLabel.isHidden = true
            self.topTableViewConstraint.constant = 0
        }
        
        self.header.setRefreshingTarget(self, refreshingAction: #selector(self.refreshData))
        // add header to table view
        self.tableView.mj_header = self.header
        // Do any additional setup after loading the view.
        
        self.tableView.tableFooterView = UIView()
        
        self.refreshData()
    }
    
    @objc fileprivate func refreshData(isShowIndicator: Bool = true) {
        
        // Noti to TDFriendProfileViewController to update total count
        self.scrollingDelegate?.didPullToRefresh(self)
        
        if isShowIndicator {
            self.xt_startNetworkIndicatorView(withMessage: "Loading...")
        }
        xt_startNetworkIndicatorView(withMessage: "Loading...")
        
        // Firebase analytics
        FIR_MANAGER.sendAppEvent(withEvent: FIREvent.LOAD_MY_PASSPORT_FUNCTION.rawValue, userId: nil)
        
        API_MANAGER.fetchStampByCountryCode(countryCode: nil, userId: self.friendId, success: { [weak self](stampArray) in
            if let weakSelf = self {
                weakSelf.stampArray = stampArray
                weakSelf.tableView.reloadData()
                weakSelf.hasLoaded = true
                weakSelf.xt_stopNetworkIndicatorView()
                weakSelf.tableView.mj_header.endRefreshing()
            }
        }) { [weak self](error) in
            if let weakSelf = self {
                weakSelf.hasLoaded = true
                weakSelf.xt_stopNetworkIndicatorView()
                weakSelf.tableView.mj_header.endRefreshing()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeNavigationBarToTransparentStyle()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func shareStampButtonTapped(_ sender: UIButton) {
        if self.countrySelectedArray.count == 0 {
            UIAlertController.show(in: self, withTitle: "Reminder", message: "Please select at least one stamp to share", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        } else {
            UIAlertController.showActionSheet(in: self, withTitle: title, message: nil, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: ["Share On The Activity", "Share On Facebook"], popoverPresentationControllerBlock: { (popOver) in
                popOver.sourceView = self.view
                
            }) { (controller, index) in
                if self.countrySelectedArray.count > 0 {
                    if (index == 3) {
                        let stampFBShareContainerView = StampFBShareContainerView.viewFromNib() as! StampFBShareContainerView
                        stampFBShareContainerView.loadData(stampSelectedArray: self.stampSelectedArray)
                        let shareImage = stampFBShareContainerView.takeScreenshot()
                        FACEBOOK_MANAGER.sharePicture(image: shareImage, hastag: "TravelXStampCollection", viewController: self)
                    } else if (index == 2) {
                        self.xt_startNetworkIndicatorView(withMessage: "Sharing...")
                        
                        
                        API_MANAGER.requestShareActivityWithType(activityId: 0, activityType: "Stamp", stampIdArray: self.countrySelectedArray, success: { message in
                            // Refresh Data
                            self.xt_stopNetworkIndicatorView()
                            UIAlertController.show(in: self, withTitle: "Notice", message: message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil);
                        }, failure: { (error) in
                            self.xt_stopNetworkIndicatorView()
                            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                        })
                    }
                }
                self.selectedAllStampButton.isSelected = false
                self.countrySelectedArray.removeAll()
                self.stampSelectedArray.removeAll()
                self.tableView.reloadData()
            }
            
        }
    }
    
    @IBAction func selectAllButtonTapped(_ sender: UIButton) {
        if self.selectedAllStampButton.isSelected == true {
            self.selectedAllStampButton.isSelected = false
            self.countrySelectedArray.removeAll()
            self.stampSelectedArray.removeAll()
        } else {
            self.selectedAllStampButton.isSelected = true
            self.countrySelectedArray.removeAll()
            for stamp in stampArray {
                self.countrySelectedArray.append(stamp.id ?? 0)
            }
            self.stampSelectedArray = self.stampArray
        }
        for cell in self.tableView.visibleCells {
            for stamp in stampArray {
                if (cell as! StampTableViewCell).stamp.id == stamp.id {
                    if let rotationValue = self.stampRotationDict[stamp.id ?? 0] {
                        (cell as! StampTableViewCell).loadData(stamp: stamp, selectedStamp: self.countrySelectedArray, rotationValue: rotationValue)
                    } else {
                        (cell as! StampTableViewCell).loadData(stamp: stamp, selectedStamp: self.countrySelectedArray, rotationValue: nil)
                    }
                }
            }
        }
    }
}

extension TDMyPassportViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stampArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.stampArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "stampCell") as! StampTableViewCell
        cell.delegate = self
        if let _ = self.friendId {
            if let rotationValue = self.stampRotationDict[data.id ?? 0] {
                cell.loadData(stamp: data, selectedStamp: self.countrySelectedArray, isVisitFriendLayout: true, rotationValue: rotationValue)
            } else {
                cell.loadData(stamp: data, selectedStamp: self.countrySelectedArray, isVisitFriendLayout: true, rotationValue: nil)
            }
        } else {
            if let rotationValue = self.stampRotationDict[data.id ?? 0] {
                cell.loadData(stamp: data, selectedStamp: self.countrySelectedArray, rotationValue: rotationValue)
            } else {
                 cell.loadData(stamp: data, selectedStamp: self.countrySelectedArray, rotationValue: nil)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let countryCode = self.stampArray[indexPath.row].id {
            if (self.countrySelectedArray.contains(countryCode)) {
                self.countrySelectedArray.remove(countryCode)
                for (index, stamp) in self.stampSelectedArray.enumerated() {
                    if stamp.id == countryCode {
                        self.stampSelectedArray.remove(at: index)
                        break
                    }
                }
            } else {
                self.countrySelectedArray.append(countryCode)
                if self.stampSelectedArray.count == 0 {
                    self.stampSelectedArray.append(self.stampArray[indexPath.row])
                } else {
                    var isAllowAdd = true
                    for stamp in self.stampSelectedArray {
                        if stamp.id == countryCode {
                            isAllowAdd = false
                        }
                    }
                    if isAllowAdd {
                        self.stampSelectedArray.append(self.stampArray[indexPath.row])
                    }
                }
            }
            for cell in self.tableView.visibleCells {
                
                if (cell as! StampTableViewCell).stamp.id == self.stampArray[indexPath.row].id {
                    if let rotationValue = self.stampRotationDict[self.stampArray[indexPath.row].id ?? 0] {
                        (cell as! StampTableViewCell).loadData(stamp: self.stampArray[indexPath.row], selectedStamp: self.countrySelectedArray, rotationValue: rotationValue)
                    } else {
                        (cell as! StampTableViewCell).loadData(stamp: self.stampArray[indexPath.row], selectedStamp: self.countrySelectedArray, rotationValue: nil)
                    }
                    
                    break
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
}

extension TDMyPassportViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
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

extension TDMyPassportViewController: UIScrollViewDelegate {
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

extension TDMyPassportViewController: StampTableViewCellDelegate {
    func didLoadStampView(view: StampTableViewCell, atStampId: Int, withRotationValue: Int) {
        self.stampRotationDict[atStampId] = withRotationValue
    }
}

