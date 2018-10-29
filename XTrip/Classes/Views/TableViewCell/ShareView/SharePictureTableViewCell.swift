//
//  SharePictureTableViewCell.swift
//  XTrip
//
//  Created by Khoa Bui on 1/14/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit
import Kingfisher

protocol ShareTableViewCellDelegate: class {
    func didTapToVisitFriendProfile(friendProfile: TDUser)
}

class SharePictureTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    var sharePicture: TDMyPicture!
    var friendInfo: TDUser!
    
    weak var delegate: ShareTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }
    
    func setShareLikeAndCommentCount(likeCount: Int, commentCount: Int) {
        self.likeLabel.text = "\(likeCount)"
        self.commentLabel.text = "\(commentCount)"
    }
    
    func setSharePictureData(pictureData: TDMyPicture) {
        // Set data for picture info
        self.sharePicture = pictureData
//        if let timeShare = atTimeInterval {
//            let date = Date(timeIntervalSince1970: TimeInterval(timeShare))
//            self.timeAgoLabel.text = date.timeAgoSinceNow
//        } else {
//            self.timeAgoLabel.text = ""
//        }
        if let utlStr = pictureData.imageUrl,
            let url = URL(string: utlStr) {
            _ = self.thumbImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "sampleImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                
            },completionHandler: { image, error, cacheType, imageURL in
                
            })
        }
    }
    
    func setCreateTime(atTimeInterval: Double?) {
        if let timeShare = atTimeInterval {
            let date = Date(timeIntervalSince1970: TimeInterval(timeShare))
            self.timeAgoLabel.text = date.timeAgoSinceNow
        } else {
            self.timeAgoLabel.text = ""
        }
    }
    
    func setUserData(userData: TDUser) {
        // Set data for user info
        self.friendInfo = userData
        if let utlStr = userData.profilePicture,
            let url = URL(string: utlStr) {
            _ = self.avatarImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "avatar_placeholder"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                
            },completionHandler: { image, error, cacheType, imageURL in
                
            })
        }
        self.nameLabel.text = userData.name ?? ""
        self.descriptionLabel.text = "shared a new photo."
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func visitFriendProfileButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapToVisitFriendProfile(friendProfile: self.friendInfo)
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {

    }
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        
    }
}
