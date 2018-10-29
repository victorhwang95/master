//
//  FooterTripView.swift
//  XTrip
//
//  Created by Khoa Bui on 12/6/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit

enum PostActionType {
    case share
    case delete
    case like
    case comment
    case edit
    case update
    case view
}

protocol FooterTripViewDelegate: class {
    func didTapButtonWithType(footerView: FooterTripView, withAction type: PostActionType, atTripCity city: TDTripCity, shareScreenShot screenShot: UIImage?)
}

class FooterTripView: UIView {

    weak var delegate: FooterTripViewDelegate?
    
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    var section: Int = 0
    var tripCity: TDTripCity!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setData(tripCity: TDTripCity?, googlePlaceData: [String: [TDPlace]]?, atSection: Int = 0) {
        self.section = atSection
        if let tripCity = tripCity {
            self.tripCity = tripCity
            self.likeImageView.image = tripCity.isLiked ? #imageLiteral(resourceName: "button_heart") : #imageLiteral(resourceName: "button_not_heart")
            self.likeCountLabel.text = "\(tripCity.likeCount ?? 0)"
            self.commentCountLabel.text = "\(tripCity.commentCount ?? 0)"
        }
    }

    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let screenShot = self.takeScreenshot()
        self.delegate?.didTapButtonWithType(footerView: self, withAction: .share, atTripCity: self.tripCity, shareScreenShot: screenShot)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(footerView: self, withAction: .delete, atTripCity: self.tripCity, shareScreenShot: nil)
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(footerView: self, withAction: .like, atTripCity: self.tripCity, shareScreenShot: nil)
    }
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(footerView: self, withAction: .comment, atTripCity: self.tripCity, shareScreenShot: nil)
    }
}
