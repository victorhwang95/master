//
//  TripPictureTableViewCell.swift
//  XTrip
//
//  Created by Khoa Bui on 1/5/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit
import Kingfisher

protocol TripPictureTableViewDelegate: class {
    func didTapButtonWithType(footerView: TripPictureTableViewCell, withAction type: PostActionType, atTrip trip: TDTrip?, atPicture picture: TDMyPicture?, shareScreenShot screenShot: UIImage?)
}

class TripPictureTableViewCell: UITableViewCell {

    @IBOutlet weak var myTimeView: UIView!
    @IBOutlet weak var myTimeLabel: UILabel!
    @IBOutlet weak var tripThumbImageView: UIImageView!
    @IBOutlet weak var friendPicView: UIView!
    @IBOutlet weak var myPicView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var myPicLikeImageView: UIImageView!
    @IBOutlet weak var myPicLikeLabel: UILabel!
    @IBOutlet weak var myPicCommentLabel: UILabel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    @IBOutlet weak var friendPicLikeImageView: UIImageView!
    @IBOutlet weak var friendPicLikeLabel: UILabel!
    @IBOutlet weak var friendPicCommentLabel: UILabel!
    @IBOutlet weak var rightToolView: UIView!
    
    @IBOutlet weak var updateButton: UIButton!
    weak var delegate: TripPictureTableViewDelegate?
    
    var tripData: TDTrip!
    var pictureData: TDMyPicture!
    var isFriendProfile: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(tripData: TDTrip, isFriendPicture: Bool, isFriendProfile: Bool = false) {
        tripData.tripLastPicture?.trip = tripData
        self.isFriendProfile = isFriendProfile
        self.tripData = tripData
        self.friendPicView.isHidden = !isFriendPicture
        self.myPicView.isHidden = isFriendPicture
        
        if let utlStr = tripData.tripLastPicture?.imageUrl,
            let url = URL(string: utlStr) {
            _ = self.tripThumbImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "sampleImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                
            },completionHandler: { image, error, cacheType, imageURL in
                
            })
        }
        
        self.titleLabel?.text = tripData.name ?? ""
        if let dateEnd = tripData.tripLastPicture?.uploadedAt {
            let date = Date(timeIntervalSince1970: TimeInterval(dateEnd))
            self.timeAgoLabel.text = date.timeAgoSinceNow
            self.timeLabel?.text = date.timeAgoSinceNow
        } else {
            self.timeAgoLabel.text = ""
            self.timeLabel?.text = ""
        }
        
        self.myPicLikeImageView.image = tripData.tripLastPicture?.isLiked ?? false ? #imageLiteral(resourceName: "button_heart") : #imageLiteral(resourceName: "button_not_heart")
        self.myPicLikeLabel.text = "\(tripData.tripLastPicture?.likeCount ?? 0)"
        self.myPicCommentLabel.text = "\(tripData.tripLastPicture?.commentCount ?? 0)"
        
        self.friendPicLikeImageView.image = tripData.tripLastPicture?.isLiked ?? false ? #imageLiteral(resourceName: "button_heart") : #imageLiteral(resourceName: "button_not_heart")
        self.friendPicLikeLabel.text = "\(tripData.tripLastPicture?.likeCount ?? 0)"
        self.friendPicCommentLabel.text = "\(tripData.tripLastPicture?.commentCount ?? 0)"
        
        if let utlStr = tripData.friend?.profilePicture,
            let url = URL(string: utlStr) {
            _ = self.avatarImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "avatar_placeholder"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                
            },completionHandler: { image, error, cacheType, imageURL in
                
            })
        }
        
        self.nameLabel.text = tripData.friend?.name ?? ""
        
    }
    
    func setPictureData(pictureData: TDMyPicture, friendData: TDUser?, isFriendPicture: Bool, isFriendProfile: Bool = false) {
        self.isFriendProfile = isFriendProfile
        if pictureData.isUpload == false {
            self.rightToolView.isHidden = true
            self.updateButton.isHidden = false
            if let imageName = pictureData.imageUrl {
                self.tripThumbImageView.image = Ultilities.getImage(imageName)
            }
        } else {
            self.rightToolView.isHidden = false
            self.updateButton.isHidden = true
            
            if let utlStr = pictureData.imageUrl,
                let url = URL(string: utlStr) {
                _ = self.tripThumbImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "sampleImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                    
                },completionHandler: { image, error, cacheType, imageURL in
                    
                })
            }
        }
        
        self.pictureData = pictureData
        
        if isFriendPicture {
            if "\(String(describing: pictureData.uploadBy!))" == TDUser.currentUser()!.id {
                self.friendPicView.isHidden = isFriendPicture
                self.myPicView.isHidden = !isFriendPicture
            } else {
                self.friendPicView.isHidden = !isFriendPicture
                self.myPicView.isHidden = isFriendPicture
            }
        } else {
            self.friendPicView.isHidden = !isFriendPicture
            self.myPicView.isHidden = isFriendPicture
        }
        
        
        if let utlStr = pictureData.imageUrl,
            let url = URL(string: utlStr) {
            _ = self.tripThumbImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "sampleImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                
            },completionHandler: { image, error, cacheType, imageURL in
                
            })
        }
        
        self.myPicLikeImageView.image = pictureData.isLiked ?? false ? #imageLiteral(resourceName: "button_heart") : #imageLiteral(resourceName: "button_not_heart")
        self.myPicLikeLabel.text = "\(pictureData.likeCount ?? 0)"
        self.myPicCommentLabel.text = "\(pictureData.commentCount ?? 0)"
        
        self.friendPicLikeImageView.image = pictureData.isLiked ?? false ? #imageLiteral(resourceName: "button_heart") : #imageLiteral(resourceName: "button_not_heart")
        self.friendPicLikeLabel.text = "\(pictureData.likeCount ?? 0)"
        self.friendPicCommentLabel.text = "\(pictureData.commentCount ?? 0)"
        
        if let profilePicture = friendData?.profilePicture,
            let url = URL(string: profilePicture) {
            _ = self.avatarImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "avatar_placeholder"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                
            },completionHandler: { image, error, cacheType, imageURL in
                
            })
        }
        
        if let uploadedAt = pictureData.uploadedAt {
            let date = Date(timeIntervalSince1970: TimeInterval(uploadedAt))
            self.timeAgoLabel.text = date.timeAgoSinceNow
            if isFriendPicture {
                self.myTimeLabel.isHidden = true
                self.myTimeView.isHidden = true
            }
            self.myTimeLabel.text = date.timeAgoSinceNow
        } else {
            if isFriendPicture {
                self.myTimeLabel.isHidden = true
                self.myTimeView.isHidden = true
            }
            self.timeAgoLabel.text = ""
            self.myTimeLabel.text = ""
        }
        
        self.nameLabel.text = friendData?.name ?? ""
    }

    @IBAction func editButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(footerView: self, withAction: .edit, atTrip: self.tripData, atPicture: self.pictureData, shareScreenShot: nil)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(footerView: self, withAction: .delete, atTrip: self.tripData, atPicture: self.pictureData, shareScreenShot: nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let screenShot = self.tripThumbImageView.takeScreenshot()
        self.delegate?.didTapButtonWithType(footerView: self, withAction: .share, atTrip: self.tripData, atPicture: self.pictureData, shareScreenShot: screenShot)
    }
    
    @IBAction func likeMyPicButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(footerView: self, withAction: .like, atTrip: self.tripData, atPicture: self.pictureData, shareScreenShot: nil)
    }
    
    @IBAction func commentMyPicButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(footerView: self, withAction: .comment, atTrip: self.tripData, atPicture: self.pictureData, shareScreenShot: nil)
    }
    
    @IBAction func friendLikePicButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(footerView: self, withAction: .like, atTrip: self.tripData, atPicture: self.pictureData, shareScreenShot: nil)
    }
    
    @IBAction func friendCommentPicButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(footerView: self, withAction: .comment, atTrip: self.tripData, atPicture: self.pictureData, shareScreenShot: nil)
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(footerView: self, withAction: .update, atTrip: self.tripData, atPicture: self.pictureData, shareScreenShot: nil)
    }
    
    @IBAction func visitFriendButtonTapped(_ sender: UIButton) {
        if !self.isFriendProfile {
            self.delegate?.didTapButtonWithType(footerView: self, withAction: .view, atTrip: self.tripData, atPicture: self.pictureData, shareScreenShot: nil)
        }
    }
}
