//
//  FooterDetailCityTripView.swift
//  XTrip
//
//  Created by Khoa Bui on 12/18/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit

protocol FooterDetailCityTripViewDelegate: class {
    func didTapLikeButton(footerDetailCitytView: FooterDetailCityTripView)
    func didTapShareButton(footerDetailCitytView: FooterDetailCityTripView)
}

class FooterDetailCityTripView: UIView {

    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    weak var delegate: FooterDetailCityTripViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setData(tripCity: TDTripCity?, isFriendCity: Bool = false) {
        if let tripCity = tripCity {
            self.likeImageView.image = tripCity.isLiked ? #imageLiteral(resourceName: "button_heart") : #imageLiteral(resourceName: "button_not_heart")
            self.likeCountLabel.text = "\(tripCity.likeCount ?? 0)"
            self.commentCountLabel.text = "\(tripCity.commentCount ?? 0)"
        }
        self.shareButton.isHidden = isFriendCity
        self.shareImageView.isHidden = isFriendCity
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapShareButton(footerDetailCitytView: self)
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapLikeButton(footerDetailCitytView: self)
    }
    
}
