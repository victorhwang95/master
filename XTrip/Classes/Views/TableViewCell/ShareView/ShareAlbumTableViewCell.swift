//
//  ShareAlbumTableViewCell.swift
//  XTrip
//
//  Created by Khoa Bui on 1/18/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit
import Kingfisher

class ShareAlbumTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var picLineFristView: UIView!
    @IBOutlet weak var picLineSecondView: UIView!
    @IBOutlet weak var morePicLabel: UILabel!
    @IBOutlet weak var morePicImageView: UIImageView!
    
    @IBOutlet weak var picZeroImageView: UIImageView!
    @IBOutlet weak var picOneImageView: UIImageView!
    @IBOutlet weak var picTwoImageView: UIImageView!
    @IBOutlet weak var picThreeImageView: UIImageView!
    @IBOutlet weak var picFourImageView: UIImageView!
    @IBOutlet weak var picFiveImageView: UIImageView!
    @IBOutlet weak var picSixImageView: UIImageView!
    
    @IBOutlet weak var secondViewTopConstaint: NSLayoutConstraint!
    
    @IBOutlet weak var zeroPicHeightConstaint: NSLayoutConstraint!
    @IBOutlet var picImageView: [UIImageView]!
    
    var friendInfo: TDUser!
    
    weak var delegate: ShareTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        picZeroImageView.image = nil
        picOneImageView.image = nil
        picTwoImageView.image = nil
        picThreeImageView.image = nil
        picFourImageView.image = nil
        picFiveImageView.image = nil
        picSixImageView.image = nil
    }
    
    func setAlbumData(myPictureArray: [TDMyPicture], atTimeInterval: Double?) {
        if let timeShare = atTimeInterval {
            let date = Date(timeIntervalSince1970: TimeInterval(timeShare))
            self.timeAgoLabel.text = date.timeAgoSinceNow
        } else {
            self.timeAgoLabel.text = ""
        }
        
        if myPictureArray.count < 5 {
            self.secondViewTopConstaint.constant = 0
            self.picLineSecondView.isHidden = true
        } else {
            self.secondViewTopConstaint.constant = self.zeroPicHeightConstaint.constant + 10
            self.picLineSecondView.isHidden = false
            self.morePicImageView.isHidden = true
            self.morePicLabel.isHidden = true
            if myPictureArray.count > 7 {
                self.morePicLabel.text = "\(myPictureArray.count - 7)\nMORE"
                self.morePicImageView.isHidden = false
                self.morePicLabel.isHidden = false
            }
        }
        for (index, myPicture) in myPictureArray.enumerated() {
            if self.picImageView.count > index {
               let pic = self.picImageView[index]
                if let utlStr = myPicture.imageUrl,
                    let url = URL(string: utlStr) {
                    _ = pic.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "sampleImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                        
                    },completionHandler: { image, error, cacheType, imageURL in
                        
                    })
                }
            }
        }
    }
    
    func setUserData(userData: TDUser) {
        self.friendInfo = userData
        // Set data for user info
        if let utlStr = userData.profilePicture,
            let url = URL(string: utlStr) {
            _ = self.avatarImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "avatar_placeholder"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                
            },completionHandler: { image, error, cacheType, imageURL in
                
            })
        }
        self.nameLabel.text = userData.name ?? ""
        self.descriptionLabel.text = "shared a new album."
    }
    
    func setShareLikeAndCommentCount(likeCount: Int, commentCount: Int) {
        self.likeLabel.text = "\(likeCount)"
        self.commentLabel.text = "\(commentCount)"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func visitFriendProfileButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapToVisitFriendProfile(friendProfile: self.friendInfo)
    }
}
