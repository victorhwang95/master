//
//  FriendInfoView.swift
//  XTrip
//
//  Created by Khoa Bui on 12/29/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import Kingfisher

protocol FriendInfoViewDelegate: class {
    func didTapButtonWithType(friendInfoView: FriendInfoView, withAction type: PostActionType, atTripCity city: TDTripCity)
}

class FriendInfoView: UIView {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    
    weak var delegate: FriendInfoViewDelegate?
    var tripCity: TDTripCity!
    
    var isFriendProfile: Bool = false
    
    func setData(tripCity: TDTripCity?, googlePlaceData: [String: [TDPlace]]?, friendInfo: TDUser?, atSection: Int = 0, isFriendProfile: Bool = false) {
        self.isFriendProfile = isFriendProfile
        if let tripCity = tripCity {
            self.tripCity = tripCity
            self.likeImageView.image = tripCity.isLiked ? #imageLiteral(resourceName: "button_heart") : #imageLiteral(resourceName: "button_not_heart")
            self.likeCountLabel.text = "\(tripCity.likeCount ?? 0)"
            self.commentCountLabel.text = "\(tripCity.commentCount ?? 0)"
            
            guard let startDateUnix = tripCity.startDate else {return}
            guard let endDateUnix = tripCity.endDate else {return}
            let dayCount = Ultilities.getDaysFromTwoDates(startDateUnix: startDateUnix, endDateUnix: endDateUnix)
            self.timeLabel.text = "\(dayCount ?? 0)" + (dayCount ?? 0 > 1 ? " days ago" : " day ago")
        }
        if let friendInfo = friendInfo {
            self.nameLabel.text = friendInfo.name
            if let utlStr = friendInfo.profilePicture,
                let url = URL(string: utlStr) {
                _ = self.avatarImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "avatar_placeholder"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                    
                },completionHandler: { image, error, cacheType, imageURL in
                    
                })
            }
        }
    }
    
    @IBAction func visitFriendButtonTapped(_ sender: UIButton) {
        if !self.isFriendProfile {
            self.delegate?.didTapButtonWithType(friendInfoView: self, withAction: .view, atTripCity: self.tripCity)
        }
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(friendInfoView: self, withAction: .like, atTripCity: self.tripCity)
    }
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(friendInfoView: self, withAction: .comment, atTripCity: self.tripCity)
    }
}
