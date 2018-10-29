//
//  NotificationTableViewCell.swift
//  XTrip
//
//  Created by Khoa Bui on 12/29/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import Kingfisher

enum TripNotificationActionType {
    case accept
    case ignore
    case clear
    case invite
    case visitTrip
    case viewMyTrip
    case viewPicture
    case viewCity
}

protocol NotificationTableViewCellDelegate: class {
    func didTapButtonWithType(tripNotificationViewCell: NotificationTableViewCell, withAction type: TripNotificationActionType, atNotification noti: TDTripNotification)
}

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var leftTripDetailConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var clearView: RoundedView!
    @IBOutlet weak var acceptView: UIStackView!
    @IBOutlet weak var tripDetailButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notificationImageView: UIImageView!
    
    var notificationData: TDTripNotification!
    weak var delegate: NotificationTableViewCellDelegate?
    var tapGesture: UITapGestureRecognizer!
    
    var viewMyTrip: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imageTapped))
        self.notificationImageView.addGestureRecognizer(self.tapGesture)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(notificationData: TDTripNotification) {
        self.notificationData = notificationData
        
        self.resetLayout()
        guard let notificationTripType  =  notificationData.notiType else {return}
        
        switch notificationTripType {
            case .inviteTrip:
                self.descriptionLabel.text = "Invited you to join \(notificationData.trip?.name ?? "") trip"
                self.acceptView.isHidden = false
                self.leftTripDetailConstraint.constant = -100
            case .rejectInviteTrip:
                self.descriptionLabel.text = "You have ignored to join \(notificationData.trip?.name ?? "") trip"
                self.descriptionLabel.textColor = UIColor.init(hex: "FF6469")
                self.clearView.isHidden = false
                self.leftTripDetailConstraint.constant = -100
            case .acceptTrip:
                self.descriptionLabel.text = "You have accepted to join \(notificationData.trip?.name ?? "") trip"
                self.leftTripDetailConstraint.constant = 5
            case .tripRejected:
                self.descriptionLabel.text = "Have ignored to join \(notificationData.trip?.name ?? "") trip"
                self.descriptionLabel.textColor = UIColor.init(hex: "FF6469")
                self.tripDetailButton.setTitleColor(UIColor.init(hex: "FF6469"), for: .normal)
                self.tripDetailButton.setTitle("INVITE AGAIN", for: .normal)
                self.clearView.isHidden = false
                self.leftTripDetailConstraint.constant = 5
            case .tripAccepted:
                self.viewMyTrip = true
                self.descriptionLabel.text = "Have accepted to join \(notificationData.trip?.name ?? "") trip"
                self.leftTripDetailConstraint.constant = 5
            case .liked, .commented:
                if notificationData.modelType == .image {
                    self.notificationImageView.isHidden = false
                    self.tripDetailButton.isHidden = true
                    self.descriptionLabel.text = notificationData.title ?? ""
                    
                    if let utlStr = notificationData.picture?.imageUrl,
                        let url = URL(string: utlStr) {
                        _ = self.notificationImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "sampleImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                            
                        },completionHandler: { image, error, cacheType, imageURL in
                            
                        })
                    }
                } else if notificationData.modelType == .city {
                    self.descriptionLabel.text = notificationData.title ?? ""
                }
            case .viewCity:
                break
        }
        self.nameLabel.text = notificationData.sender?.name
        if let utlStr = notificationData.sender?.profilePicture,
            let url = URL(string: utlStr) {
            _ = self.avatarImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "avatar_placeholder"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                
            },completionHandler: { image, error, cacheType, imageURL in
                
            })
        }
        if let createDate = notificationData.createdAt {
            self.dateLabel.text = "\(createDate.unixTimeToHourDayMonthYearString())"
        }
    }
    
    fileprivate func resetLayout() {
        self.nameLabel.text = ""
        self.descriptionLabel.text = ""
        self.descriptionLabel.textColor = UIColor.init(hex: "8C8C8C")
        self.tripDetailButton.setTitleColor(UIColor.init(hex: "1F93D6"), for: .normal)
        self.tripDetailButton.setTitle("TRIP DETAIL", for: .normal)
        self.acceptView.isHidden = true
        self.clearView.isHidden = true
        self.notificationImageView.isHidden = true
        self.tripDetailButton.isHidden = false
    }
    
    @IBAction func ignoreButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(tripNotificationViewCell: self, withAction: .ignore, atNotification: self.notificationData)
    }
    
    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(tripNotificationViewCell: self, withAction: .accept, atNotification: self.notificationData)
    }
    
    @IBAction func clearButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(tripNotificationViewCell: self, withAction: .clear, atNotification: self.notificationData)
    }
    
    @IBAction func tripDetailButtonTapped(_ sender: UIButton) {
        if notificationData.modelType == .city {
            self.delegate?.didTapButtonWithType(tripNotificationViewCell: self, withAction: .viewCity, atNotification: self.notificationData)
        } else {
            guard let notificationTripType  =  notificationData.notiType else {return}
            if notificationTripType == .tripRejected {
                self.delegate?.didTapButtonWithType(tripNotificationViewCell: self, withAction: .invite, atNotification: self.notificationData)
            } else {
                if self.viewMyTrip {
                    self.delegate?.didTapButtonWithType(tripNotificationViewCell: self, withAction: .viewMyTrip, atNotification: self.notificationData)
                } else {
                    self.delegate?.didTapButtonWithType(tripNotificationViewCell: self, withAction: .visitTrip, atNotification: self.notificationData)
                }
            }
        }
    }
    
    func imageTapped() {
        self.delegate?.didTapButtonWithType(tripNotificationViewCell: self, withAction: .viewPicture, atNotification: self.notificationData)
    }
}
