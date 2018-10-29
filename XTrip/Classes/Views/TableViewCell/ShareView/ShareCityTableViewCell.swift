//
//  ShareCityTableViewCell.swift
//  XTrip
//
//  Created by Khoa Bui on 1/16/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit
import Kingfisher

class ShareCityTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var hotelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var resWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var barWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var musWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var hotelLabel: UILabel!
    @IBOutlet weak var resLabel: UILabel!
    @IBOutlet weak var barLabel: UILabel!
    @IBOutlet weak var museumLabel: UILabel!
    
    var shareCity: TDTripCity!
    var friendInfo: TDUser!
    
    weak var delegate: ShareTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        let menuHeaderViewWidth = SCREEN_SIZE.width - 20
        self.hotelWidthConstraint.constant = menuHeaderViewWidth/4
        self.resWidthConstraint.constant = menuHeaderViewWidth/4
        self.barWidthConstraint.constant = menuHeaderViewWidth/4
        self.musWidthConstraint.constant = menuHeaderViewWidth/4
    }

    func setSharePictureData(cityData: TDTripCity, atTimeInterval: Double?) {
        self.shareCity = cityData
        if let dateCreate = atTimeInterval {
            let date = Date(timeIntervalSince1970: TimeInterval(dateCreate))
            self.timeAgoLabel.text = date.timeAgoSinceNow
        } else {
            self.timeAgoLabel.text = ""
        }
        self.cityNameLabel.text = cityData.name ?? ""
        self.hotelLabel.text = "Hotel(\(cityData.hotelCount ?? 0))"
        self.resLabel.text = "Restaurant(\(cityData.restaurantCount ?? 0))"
        self.barLabel.text = "Bar(\(cityData.barCount ?? 0))"
        self.museumLabel.text = "Museum(\(cityData.museumCount ?? 0))"
    }
    
    func setShareLikeAndCommentCount(likeCount: Int, commentCount: Int) {
        self.likeLabel.text = "\(likeCount)"
        self.commentLabel.text = "\(commentCount)"
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
        self.descriptionLabel.text = "shared a trip."
    }

    @IBAction func visitFriendProfileButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapToVisitFriendProfile(friendProfile: self.friendInfo)
    }
}
