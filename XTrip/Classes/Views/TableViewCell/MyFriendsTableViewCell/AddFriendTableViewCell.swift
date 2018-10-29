//
//  AddFriendTableViewCell.swift
//  XTrip
//
//  Created by Khoa Bui on 1/19/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit

protocol AddFriendTableViewCellDelegate: class {
    func didTapButtonWithType(friendViewCell: AddFriendTableViewCell, withAction type: FriendActionType, atFriend friend: PhoneContact)
}

class AddFriendTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    var contactData: PhoneContact!
    weak var delegate: AddFriendTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.avatarImageView.image = #imageLiteral(resourceName: "avatar_placeholder")
        self.nameLabel.text = ""
    }
    
    enum AddFriendTableViewCellKind: Int {
        case invite;//Display the cell with an "invite" action
        case added;//Display the cell with an "added" label
        case invited;//Display the cell with an "invited" label
        case requested;//Display the cell with an "invited" label
        
        var stringValue: String {
            switch self {
            case .invite:
                return "INVITE"
            case .added:
                return "FRIEND ADDED"
            case .invited:
                return "INVITED"
            case .requested:
                return "REQUEST SENT"
            }
        }
        
    }
    
    func setData(contactData: PhoneContact?, cellKind kind: AddFriendTableViewCellKind = .invite) {
        if let contactData = contactData {
            self.contactData = contactData
            self.nameLabel.text = contactData.contactFullName as String? ?? "Unknown"
            if let thumbData = contactData.contactImage {
                self.avatarImageView.image = UIImage(data: thumbData)
            }
            self.addButton.setTitle(kind.stringValue, for: .normal);
            switch kind {
            case .invite:
                self.addButton.setTitleColor(UIColor.init(hex: "30B3FF"), for: .normal);
                self.addButton.isUserInteractionEnabled = true;
                break;
            case .added:
                self.addButton.setTitleColor(UIColor.gray, for: .normal);
                self.addButton.isUserInteractionEnabled = false;
                break;
            case .invited:
                self.addButton.setTitleColor(UIColor.gray, for: .normal);
                self.addButton.isUserInteractionEnabled = false;
                break;
            case .requested:
                self.addButton.setTitleColor(UIColor.gray, for: .normal);
                self.addButton.isUserInteractionEnabled = false;
                break;
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(friendViewCell: self, withAction: .add, atFriend: self.contactData)
    }
}
