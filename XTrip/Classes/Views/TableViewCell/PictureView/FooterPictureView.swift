//
//  FooterPictureView.swift
//  XTrip
//
//  Created by Khoa Bui on 1/7/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit

protocol FooterPictureViewDelegate: class {
    func didTapButtonWithType(footerView: FooterPictureView, withAction type: PostActionType, atPicture picture: TDMyPicture)
}

class FooterPictureView: UIView {

    @IBOutlet weak var picNameLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var pictureData: TDMyPicture!
    weak var delegate: FooterPictureViewDelegate?
    
    func setData(pictureData: TDMyPicture, isFriendPicture: Bool) {
        self.pictureData = pictureData
        self.picNameLabel.text = pictureData.caption ?? ""
        self.likeImageView.image = pictureData.isLiked ?? false ? #imageLiteral(resourceName: "button_heart") : #imageLiteral(resourceName: "button_not_heart")
        self.likeCountLabel.text = "\(pictureData.likeCount ?? 0)"
        self.locationNameLabel.text = pictureData.imageLocation?.name ?? ""
        if let dateCreate = pictureData.uploadedAt {
            let date = Date(timeIntervalSince1970: TimeInterval(dateCreate))
            self.timeLabel.text = date.timeAgoSinceNow
        }
    }

    @IBAction func shareButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(footerView: self, withAction: .share, atPicture: self.pictureData)
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(footerView: self, withAction: .like, atPicture: self.pictureData)
    }
}
