//
//  TripDetailTableViewCell.swift
//  XTrip
//
//  Created by Khoa Bui on 12/2/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

protocol TripDetailTableViewCellDelegate: class {
    func didTapButtonToToogleCell(tableViewCell: TripDetailTableViewCell, atTripId: Int, isFriendTrip: Bool)
    func didTapButtonWithType(tableViewCell: TripDetailTableViewCell, withAction type: PostActionType, atTrip trip: TDTrip?, shareScreenShot screenShot: UIImage?)
}

class TripDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var coverView: RoundedView!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var heightShareViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightMapViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var friendView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var tripData: TDTrip!
    var tripMapView: TripMapView?
    var isFriendTrip: Bool = false
    var isFriendProfile: Bool = false
    
    weak var didToogleCellDelegate: TripDetailTableViewCellDelegate?
    weak var tripMapViewDelegate: TripMapViewDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK:- Action
    
    @IBAction func dropdownAction(_ sender: UIButton) {
        self.didToogleCellDelegate?.didTapButtonToToogleCell(tableViewCell: self, atTripId: self.tripData.tripId ?? 0, isFriendTrip: self.isFriendProfile)
    }
    
    func setData(data: TDTrip, expandTripArray: [Int], isFriendTrip: Bool = false, isFriendProfile: Bool = false) {
        self.isFriendProfile = isFriendProfile
        self.tripData = data
        self.titleLabel.text = data.name
        if let startDate = data.startDate,
            let endDate = data.endDate {
            self.dateLabel.text = "\(startDate.unixTimeToString()) - \(endDate.unixTimeToString())"
        }
        if let _ = self.tripMapView {
            self.tripMapView?.tripMapViewDelegate = self
            self.tripMapView?.setCountryTripData(scheduleArray: data.tripSchedule, tripData: data)
        } else {
            self.tripMapView = TripMapView.viewFromNib() as! TripMapView
            self.tripMapView?.tripMapViewDelegate = self
            self.tripMapView?.setCountryTripData(scheduleArray: data.tripSchedule, tripData: data)
        }
        self.configStatusCell(expandTripArray: expandTripArray)
        if isFriendTrip {
            self.isFriendTrip = isFriendTrip
            self.friendView.alpha = 1
            self.shareButton.alpha = 0
            self.editButton.alpha = 0
            self.deleteButton.alpha = 0
            self.nameLabel.text = data.friend?.name
            if let utlStr = data.friend?.profilePicture,
                let url = URL(string: utlStr) {
                _ = self.avatarImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "avatarsample"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                    
                },completionHandler: { image, error, cacheType, imageURL in
                    
                })
            }
        } else {
            self.friendView.alpha = 0
            self.shareButton.alpha = 1
            self.editButton.alpha = 1
            self.deleteButton.alpha = 1
        }
    }
    
    func configStatusCell(expandTripArray: [Int]) {
        if (expandTripArray.contains(self.tripData.tripId ?? 0)) {

            self.toggleButton.isSelected = true
            
            self.mapView.addSubview(self.tripMapView!)
            self.tripMapView!.snp.makeConstraints { (make) in
                make.top.bottom.equalTo(self.mapView)
                make.left.equalTo(self.mapView).offset(10)
                make.right.equalTo(self.mapView).offset(-10)
            }
            self.heightMapViewConstraint.constant = 200
            self.heightShareViewConstraint.constant = 52
            self.layoutIfNeeded()
            UIView.animate(withDuration: 0.5, animations: {
                self.shareView.alpha = 1
            })
            
        } else {
            self.toggleButton.isSelected = false
            self.heightMapViewConstraint.constant = 0
            self.heightShareViewConstraint.constant = 0
            self.tripMapView!.removeFromSuperview()
            self.shareView.alpha = 0
            self.layoutIfNeeded()
        }
    }
    
    @IBAction func visitFriendButtonTapped(_ sender: UIButton) {
        if !self.isFriendProfile {
            self.didToogleCellDelegate?.didTapButtonWithType(tableViewCell: self, withAction: .view, atTrip: self.tripData, shareScreenShot: nil)
        }
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let screenShot = self.tripMapView?.takeScreenshot()
        self.didToogleCellDelegate?.didTapButtonWithType(tableViewCell: self, withAction: .share, atTrip: self.tripData, shareScreenShot: screenShot)
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        self.didToogleCellDelegate?.didTapButtonWithType(tableViewCell: self, withAction: .edit, atTrip: self.tripData, shareScreenShot: nil)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        self.didToogleCellDelegate?.didTapButtonWithType(tableViewCell: self, withAction: .delete, atTrip: self.tripData, shareScreenShot: nil)
    }
}

extension TripDetailTableViewCell: TripMapViewDelegate {
    func didTapAnntatioCountry(tripMapView: TripMapView, atTripId tripId: Int, friendInfo: TDUser?, andCountryCode countryCode: String?, coordinate: CLLocationCoordinate2D, andCountryName countryName: String?, andCityId cityId: Int?, andCityName cityName: String?) {
        self.tripMapViewDelegate?.didTapAnntatioCountry(tripMapView: tripMapView, atTripId: tripId, friendInfo: friendInfo, andCountryCode: countryCode, coordinate: coordinate, andCountryName: countryName, andCityId: cityId, andCityName: cityName)
    }
}
