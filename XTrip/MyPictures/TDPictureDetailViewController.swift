//
//  TDPictureDetailViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 1/7/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import MJRefresh
import SimpleImageViewer

protocol PictureDetailViewControllerDelegate: class {
    func didUpdatePictureMetadata(viewController: TDPictureDetailViewController,  pictureData picture: TDMyPicture)
}

class TDPictureDetailViewController: TDBaseViewController {
    
    // MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK:- Properties
    var pictureId: Int!
    var pictureCaption: String!
    var pictureData: TDMyPicture?
    var isFriendPicture: Bool = false
    let header = MJRefreshNormalHeader()
    
    weak var delegate: PictureDetailViewControllerDelegate?
    
    var isFriendProfile: Bool = false // Use in the friend profile layout
    
    // MARK:- Public method
    static func newInstance() -> TDPictureDetailViewController {
        return UIStoryboard.init(name: "MyPictures", bundle: nil).instantiateViewController(withIdentifier: "TDPictureDetailViewController") as! TDPictureDetailViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = self.pictureCaption
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let pictureData = self.pictureData else {return}
        self.delegate?.didUpdatePictureMetadata(viewController: self, pictureData: pictureData)
    }
    
    // MARK:- Private method
    fileprivate func setupView() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 300
        
        let pictureView = UINib(nibName: "PictureView", bundle: nil)
        self.tableView.register(pictureView, forCellReuseIdentifier: "PictureView")
        
        let commentTableViewCell = UINib(nibName: "CommentTableViewCell", bundle: nil)
        self.tableView.register(commentTableViewCell, forCellReuseIdentifier: "CommentTableViewCell")
        
        self.header.setRefreshingTarget(self, refreshingAction: #selector(self.refreshData))
        // add header to table view
        self.tableView.mj_header = self.header

        // Load data
        self.refreshData()
    }
    
    @objc fileprivate func refreshData(isShowIndicator: Bool = true) {
        if isShowIndicator {
            self.xt_startNetworkIndicatorView(withMessage: "Loading...")
        }
        
        // Firebase analytics
        FIR_MANAGER.sendAppEvent(withEvent: FIREvent.LOAD_MY_DETAIL_PIC_FUNCTION.rawValue, userId: nil)
        
        API_MANAGER.requestGetPictureDetail(pictureId: self.pictureId, success: { (pictureData) in
            self.tableView.mj_header.endRefreshing()
            self.xt_stopNetworkIndicatorView()
            self.pictureData = pictureData
            self.tableView.reloadData()
        }) { (error) in
            self.tableView.mj_header.endRefreshing()
            self.xt_stopNetworkIndicatorView()
            
            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: { (alerController, index) in
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
}

extension TDPictureDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 240
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 70
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let configuration = ImageViewerConfiguration { config in
                let cell = tableView.cellForRow(at: indexPath) as! PictureView
                config.imageView = cell.pictureImageView
            }
            
            let imageViewerController = ImageViewerController(configuration: configuration)
            
            present(imageViewerController, animated: true)
        }
    }
}

extension TDPictureDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return self.pictureData?.comments?.count ?? 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let cell = CommentView.viewFromNib() as! CommentView
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            guard let pictureData = self.pictureData else {return nil}
            let footerPictureView = FooterPictureView.viewFromNib() as! FooterPictureView
            footerPictureView.delegate = self
            footerPictureView.setData(pictureData: pictureData, isFriendPicture: self.isFriendPicture)
            return footerPictureView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PictureView", for: indexPath) as! PictureView
            cell.setData(pictureData: self.pictureData)
            return cell
        } else {
            let commentData = self.pictureData?.comments?[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
            cell.delegate = self
            cell.setData(commentData: commentData, isFriendProfile: self.isFriendProfile)
            return cell
        }
    }
}

extension TDPictureDetailViewController: CommentTableViewCellDelegate {
    func didTapAvatar(friendInfo: TDUser?) {
        guard let userId = friendInfo?.id else {return}
        let friendInfoVC = TDFriendProfileViewController.newInstance()
        friendInfoVC.userId = userId
        self.navigationController?.pushViewController(friendInfoVC, animated: true)
    }
}


extension TDPictureDetailViewController: CommentViewDelegate {
    func didTapCommentButton(commentView: CommentView, withComment comment: String) {
        self.xt_startNetworkIndicatorView(withMessage: "Posting...")
        if let userID = TDUser.currentUser()?.id,
            let userIDInt = Int(userID){
            
            // Firebase analytics
            FIR_MANAGER.sendAppEvent(withEvent: FIREvent.CMT_PIC_FUNCTION.rawValue, userId: nil)
            
            API_MANAGER.requestPostCommentOnTripPicture(pictureId: self.pictureId, userId: userIDInt, content: comment, success: {
                commentView.commentTextField.text = nil
                self.refreshData(isShowIndicator: false)
            }, failure: { (error) in
                self.xt_stopNetworkIndicatorView()
                UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            })
        }
    }
}

extension TDPictureDetailViewController: FooterPictureViewDelegate {
    
    func didTapButtonWithType(footerView: FooterPictureView, withAction type: PostActionType, atPicture picture: TDMyPicture) {
        switch type {
        case .share:
            break
        case .delete:
            break
        case .like:
            self.xt_startNetworkIndicatorView(withMessage: "Posting...")
            if let imageId = picture.imageId {
                let isLike = picture.isLiked
                var behavior: String = "like"
                if let isLike = isLike, isLike == true {
                    behavior = "unlike"
                }
                // Firebase analytics
                FIR_MANAGER.sendAppEvent(withEvent: FIREvent.LIKE_PIC_FUNCTION.rawValue, userId: nil)
                
                API_MANAGER.requestLikeTripPicture(pictureId: imageId, behavior: behavior, success: { (updatePic) in
                    // Refresh Data
                    self.refreshData(isShowIndicator: false)
                }, failure: { (error) in
                    self.xt_stopNetworkIndicatorView()
                    UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                })
            }
        case .comment:
            break
        case .update:
            break
        case .edit:
            break
        case .view:
            break
        }
    }
}

extension TDPictureDetailViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
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
}

