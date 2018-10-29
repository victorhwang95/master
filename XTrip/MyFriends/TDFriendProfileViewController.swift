//
//  TDFriendProfileViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 2/1/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit
import Kingfisher



protocol FriendProfileContentScrollingDelegate: class {
    func childViewController(_ childViewController: UIViewController,didScroll scrollView: UIScrollView);
    func childViewController(_ childViewController: UIViewController,didEndDecelerating scrollView: UIScrollView);
    func childViewController(_ childViewController: UIViewController,willEndDragging scrollView: UIScrollView, velocity: CGPoint);
    func didPullToRefresh(_ childViewController: UIViewController)
}

class TDFriendProfileViewController: TDBaseViewController {
    
    // MARK:- Outlets
    
    @IBOutlet weak var outerHeaderView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avatarImageView: RoundedImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pictureLabel: UILabel!
    @IBOutlet weak var tripLabel: UILabel!
    @IBOutlet weak var stampLabel: UILabel!
    
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var stampImageView: UIImageView!
    @IBOutlet weak var tripImageView: UIImageView!
    
    
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    var userId: String! // always has value
    
    // MARK:- Properties
    var friendTripListVC: TDTripListViewController!
    var friendPictureListVC: TDTripPictureListViewController!
    var myPassportVC: TDMyPassportViewController!
    
    // MARK:- Public method
    static func newInstance() -> TDFriendProfileViewController {
        return UIStoryboard.init(name: "MyFriends", bundle: nil).instantiateViewController(withIdentifier: "TDFriendProfileViewController") as! TDFriendProfileViewController
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
        self.loadFriendInfo()
        self.setupChildViewControllers()
    }
    
    fileprivate func setupChildViewControllers() {
        
        if (self.friendPictureListVC == nil) {
            self.pictureImageView.isHidden = false
            self.tripImageView.isHidden = true
            self.stampImageView.isHidden = true
            self.friendPictureListVC = TDTripPictureListViewController.newInstance()
            self.friendPictureListVC.isFriendPicture = true
            self.friendPictureListVC.friendId = self.userId
            self.friendPictureListVC.scrollingDelegate = self
            self.addChild(childViewController: self.friendPictureListVC, inView: self.contentView)
        }
        if (self.myPassportVC == nil) {
            self.myPassportVC = TDMyPassportViewController.newInstance()
            self.myPassportVC.friendId = self.userId
            self.myPassportVC.scrollingDelegate = self
            self.addChild(childViewController: self.myPassportVC, inView: self.contentView)
        }
        if (self.friendTripListVC == nil) {
            self.friendTripListVC = TDTripListViewController.newInstance()
            self.friendTripListVC.isFriendTrip = true
            self.friendTripListVC.friendId = self.userId
            self.friendTripListVC.scrollingDelegate = self
            self.addChild(childViewController: self.friendTripListVC, inView: self.contentView)
        }
        
        self.pictureButtonTapped(UIButton());//Initially show the Pictures tab
    }
    
    fileprivate func loadFriendInfo() {
        API_MANAGER.getUserInfo(userId: self.userId, success: { [weak self](friendInfo) in
            self?.xt_stopNetworkIndicatorView()
            self?.nameLabel.text = friendInfo.user?.name
            if let utlStr = friendInfo.user?.coverPicture, let url = URL(string: utlStr) {
                _ = self?.coverImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "sampleImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                    
                },completionHandler: { image, error, cacheType, imageURL in
                    
                })
            }
            
            if let utlStr = friendInfo.user?.profilePicture, let url = URL(string: utlStr) {
                _ = self?.avatarImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "avatar_placeholder"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                    
                },completionHandler: { image, error, cacheType, imageURL in
                    
                })
            }
            
            self?.pictureLabel.text = "\(friendInfo.totalImage ?? 0)"
            self?.tripLabel.text = "\(friendInfo.totalTrip ?? 0)"
            self?.stampLabel.text = "\(friendInfo.totalTemp ?? 0)"
            
        }) { (error) in
            self.xt_stopNetworkIndicatorView()
            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        }
    }

    @IBAction func pictureButtonTapped(_ sender: UIButton) {
        self.pictureImageView.isHidden = false
        self.tripImageView.isHidden = true
        self.stampImageView.isHidden = true
        self.friendPictureListVC.view.superview?.bringSubview(toFront: self.friendPictureListVC.view);
    }
    
    @IBAction func tripButtonTapped(_ sender: UIButton) {
        self.pictureImageView.isHidden = true
        self.tripImageView.isHidden = false
        self.stampImageView.isHidden = true
        self.friendTripListVC.view.superview?.bringSubview(toFront: self.friendTripListVC.view);
    }
    
    @IBAction func stampButtonTapped(_ sender: UIButton) {
        self.pictureImageView.isHidden = true
        self.tripImageView.isHidden = true
        self.stampImageView.isHidden = false
        self.myPassportVC.view.superview?.bringSubview(toFront: self.myPassportVC.view);
    }
}

private let maximumHeaderHeight:CGFloat = 333;

private let minimumHeaderHeight:CGFloat = 240;

extension TDFriendProfileViewController: FriendProfileContentScrollingDelegate {
    
    func didPullToRefresh(_ childViewController: UIViewController) {
        self.loadFriendInfo()
    }
    
    func childViewController(_ childViewController: UIViewController, willEndDragging scrollView: UIScrollView, velocity: CGPoint) {
        
        print("velo: \(velocity)");
            /*Temprarily disable auto-align while header height is between min and max (due to the complicated layout of Trip List screen*/
//        if (velocity.y > 0) {
//            self.headerHeightConstraint.constant = minimumHeaderHeight;
//        } else {
//            self.headerHeightConstraint.constant = maximumHeaderHeight;
//        }
//        self.outerHeaderView.setNeedsUpdateConstraints();
//        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
//            self.view.layoutIfNeeded();
//        }, completion: nil)
    }
    
    func childViewController(_ childViewController: UIViewController, didEndDecelerating scrollView: UIScrollView) {
//        self.layoutHeaderIfNeeded();
    }
    
    func childViewController(_ childViewController: UIViewController, didScroll scrollView: UIScrollView) {
        
        let yOffset = scrollView.contentOffset.y;
        print(yOffset);
        
        if (yOffset > 0 && self.headerHeightConstraint.constant > minimumHeaderHeight) {

            self.headerHeightConstraint.constant = minimumHeaderHeight;

        } else if (yOffset < 0 && self.headerHeightConstraint.constant < maximumHeaderHeight) {
            self.headerHeightConstraint.constant = maximumHeaderHeight;
        }
        
        self.outerHeaderView.setNeedsUpdateConstraints();
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded();
        }, completion: nil)
    }
    
//    private func layoutHeaderIfNeeded() {
//        let currentHeaderHeight = self.headerHeightConstraint.constant;
//        let minHeightDistance = currentHeaderHeight - minimumHeaderHeight;
//        let maxHeightDistance = maximumHeaderHeight - currentHeaderHeight;
//
//        if (minHeightDistance < maxHeightDistance) {
//            self.headerHeightConstraint.constant = minimumHeaderHeight;
//        } else {
//            self.headerHeightConstraint.constant = maximumHeaderHeight;
//        }
//
//        self.outerHeaderView.setNeedsUpdateConstraints();
//        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
//            self.view.layoutIfNeeded();
//        }, completion: nil)
//    }
}
