//
//  CommentTableViewCell.swift
//  XTrip
//
//  Created by Khoa Bui on 12/18/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import Kingfisher
import DateToolsSwift

protocol CommentTableViewCellDelegate: class {
    func didTapAvatar(friendInfo: TDUser?)
}
class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    weak var delegate: CommentTableViewCellDelegate?
    var user: TDUser?
    var isFriendProfile: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setData(commentData: TDCityComment? ,isFriendProfile: Bool = false) {
        self.isFriendProfile = isFriendProfile
        self.user = commentData?.user
        if let commentData = commentData {
            if let dateCreate = commentData.createdAt {
                let date = Date(timeIntervalSince1970: TimeInterval(dateCreate))
                self.dateLabel.text = date.timeAgoSinceNow
            }
            self.contentLabel.text = commentData.content ?? ""
            self.nameLabel.text = commentData.user?.name ?? "Unknown"
            if let utlStr = commentData.user?.profilePicture,
               let url = URL(string: utlStr) {
                _ = self.avatarImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "avatar_placeholder"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                    
                },completionHandler: { image, error, cacheType, imageURL in
                    
                })
            }
        }
    }
    
    @IBAction func visitFriendButtonTapped(_ sender: UIButton) {
        if !isFriendProfile {
            self.delegate?.didTapAvatar(friendInfo: self.user)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
