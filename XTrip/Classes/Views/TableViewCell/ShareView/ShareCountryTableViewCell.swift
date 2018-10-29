//
//  ShareCountryTableViewCell.swift
//  XTrip
//
//  Created by Khoa Bui on 1/17/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit
import Kingfisher

protocol ShareCountryTableViewCellDelegate: class {
    func didChooseCountryOnMap(tableViewCell: ShareCountryTableViewCell, friendInfo friend: TDUser?, withTrip trip: TDTrip, withCountryName countryName: String, withCountryCode countryCode: String, coordinate: CLLocationCoordinate2D)
}

class ShareCountryTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var mapContentView: UIView!
    
    var shareTrip: TDTrip!
    var shareFriend: TDUser!
    var tripMapView: TripMapView!
    weak var delegate: ShareCountryTableViewCellDelegate?
    
    weak var delegateVisitFriend: ShareTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
        self.tripMapView = TripMapView.viewFromNib() as! TripMapView
        self.mapContentView.addSubview(self.tripMapView!)
        self.tripMapView!.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(self.mapContentView)
        }
    }
    
    func setShareLikeAndCommentCount(likeCount: Int, commentCount: Int) {
        self.likeLabel.text = "\(likeCount)"
        self.commentLabel.text = "\(commentCount)"
    }
    
    func setShareCountryData(countryData: TDTrip, friend: TDUser, atTimeInterval: Double?) {
        // Set data for trip info
        self.shareTrip = countryData
        self.shareFriend = friend
        
        if let timeShare = atTimeInterval {
            let date = Date(timeIntervalSince1970: TimeInterval(timeShare))
            self.timeAgoLabel.text = date.timeAgoSinceNow
        } else {
            self.timeAgoLabel.text = ""
        }
        
        if let _ = self.tripMapView {
            self.tripMapView?.tripMapViewDelegate = self
            self.tripMapView?.setCountryTripData(scheduleArray: countryData.tripSchedule, tripData: countryData)
        } else {
            self.tripMapView = TripMapView.viewFromNib() as! TripMapView
            self.tripMapView?.tripMapViewDelegate = self
            self.tripMapView?.setCountryTripData(scheduleArray: countryData.tripSchedule, tripData: countryData)
        }
    }
    
    func setUserData(userData: TDUser) {
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func visitFriendProfileButtonTapped(_ sender: UIButton) {
        self.delegateVisitFriend?.didTapToVisitFriendProfile(friendProfile: self.shareFriend)
    }
}

extension ShareCountryTableViewCell: TripMapViewDelegate {
    func didTapAnntatioCountry(tripMapView: TripMapView, atTripId tripId: Int, friendInfo: TDUser?, andCountryCode countryCode: String?, coordinate: CLLocationCoordinate2D, andCountryName countryName: String?, andCityId cityId: Int?, andCityName cityName: String?) {
        guard let countryName = countryName else {return}
        guard let countryCode = countryCode else {return}
        self.delegate?.didChooseCountryOnMap(tableViewCell: self, friendInfo: self.shareFriend, withTrip: self.shareTrip, withCountryName: countryName, withCountryCode: countryCode, coordinate: coordinate)
    }
}

