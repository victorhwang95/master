//
//  MyFriendsTableViewCell.swift
//  XTrip
//
//  Created by Khoa Bui on 12/23/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import Kingfisher

enum FriendActionType {
    case delete
    case invite
    case add
    case viewProfile
}

protocol MyFriendsTableViewCellDelegate: class {
    func didTapButtonWithType(friendViewCell: MyFriendsTableViewCell, withAction type: FriendActionType, atFriend friend: AppContact)
}

class MyFriendsTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    
    weak var delegate: MyFriendsTableViewCellDelegate?
    var contactData: AppContact!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(contactData: AppContact, inviteArray: [Int], isInvite: Bool = false, showFriendListForFilter: Bool = false, joinedFriendIdArray:[Int]) {
        
        self.contactData = contactData
        self.nameLabel.text = contactData.name
        if let utlStr = contactData.profilePicture,
            let url = URL(string: utlStr) {
            _ = self.avatarImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "avatar_placeholder"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in

            },completionHandler: { image, error, cacheType, imageURL in

            })
        } else {
            self.avatarImageView.image = #imageLiteral(resourceName: "avatar_placeholder");
        }
        self.configStatusCell(inviteArray: inviteArray, joinedFriendIdArray: joinedFriendIdArray)
        
        if showFriendListForFilter {
            self.deleteButton.isHidden = true
            self.inviteButton.isHidden = true
        } else {
            if isInvite {
                self.inviteButton.isHidden = false
                self.deleteButton.isHidden = true
            } else {
                self.deleteButton.isHidden = false
                self.inviteButton.isHidden = true
            }
        }
        
    }
    
    func configStatusCell(inviteArray: [Int], joinedFriendIdArray:[Int]) {
        if joinedFriendIdArray.contains(self.contactData.id ?? 0) {
            self.inviteButton.isEnabled = false
            self.inviteButton.setTitleColor(UIColor.init(hex: "8C8C8C"), for: .normal)
            self.inviteButton.setTitle("JOINED", for: .normal)
        } else {
            if (inviteArray.contains(self.contactData.id ?? 0)) {
                self.inviteButton.isEnabled = false
                self.inviteButton.setTitleColor(UIColor.init(hex: "8C8C8C"), for: .normal)
                self.inviteButton.setTitle("INVITED", for: .normal)
            } else {
                self.inviteButton.isEnabled = true
                self.inviteButton.setTitleColor(UIColor.init(hex: "30B3FF"), for: .normal)
                self.inviteButton.setTitle("INVITE", for: .normal)
            }
        }
    }

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(friendViewCell: self, withAction: .delete, atFriend: self.contactData)
    }
    
    @IBAction func inviteButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(friendViewCell: self, withAction: .invite, atFriend: self.contactData)
    }
    
    @IBAction func viewProfileButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(friendViewCell: self, withAction: .viewProfile, atFriend: self.contactData)
    }
}

