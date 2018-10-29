//
//  ShareStampTableViewCell.swift
//  XTrip
//
//  Created by Khoa Bui on 2/3/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit

protocol ShareStampTableViewCellDelegate: class {
    func didLoadStampView(view: ShareStampTableViewCell, isdownloadAt: Int, andViews: [OneStampView])
}

class ShareStampTableViewCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    @IBOutlet weak var firstStampView: UIView!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var firstTimeLabel: UILabel!
    @IBOutlet weak var firstCountryLabel: UILabel!
    
    @IBOutlet weak var secondStampView: UIView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var secondTimeLabel: UILabel!
    @IBOutlet weak var secondCountryLabel: UILabel!

    @IBOutlet weak var thirdStampView: UIView!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var thirdTimeLabel: UILabel!
    @IBOutlet weak var thirdCountryLabel: UILabel!
    
    var stampArray: [TDStamp] = []
    
    var countryListFromJsonFile:[TDLocalCountry] = []
    
    weak var delegate: ShareTableViewCellDelegate?
    
    weak var delegateStamp: ShareStampTableViewCellDelegate?
    
    var friendInfo: TDUser!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.countryListFromJsonFile = self.getCountryListFromJsonFile()
        self.setupLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        for view in self.stackView.subviews {
            view.removeFromSuperview()
        }
    }
    
    func setupLayout() {
        self.selectionStyle = .none
    }
    
    func setData(stampArray: [TDStamp], atTimeInterval: Double?, id: Int, views: [OneStampView]) {
        
        if views.count == 0 {
            print("dang tao moi")
            DispatchQueue.global().async {
                self.stampArray = stampArray
                var views: [OneStampView] = []
                for (index, stamp) in self.stampArray.enumerated() {
                    for localStamp in self.countryListFromJsonFile {
                        if stamp.countryCode == localStamp.alpha2 {
                            let stampView = OneStampView.viewFromNib() as! OneStampView
                            
                            stampView.stampView.transform = .identity
                            stampView.stampView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / -20)
                            
                            stampView.imageView.image = UIImage(named: localStamp.stamp ?? "")?.tinted(with: UIColor(hex: localStamp.color ?? ""))
                            stampView.countryLabel.text = localStamp.name;
                            stampView.countryLabel.textColor = UIColor(hex: localStamp.color ?? "")
                            if let createAt = stamp.uploadedAt {
                                stampView.timeLabel.text = "\(createAt.unixTimeToDayMonthYearString())"
                            } else {
                                stampView.timeLabel.text = ""
                            }
                            views.append(stampView)
                            break
                        }
                    }
                }
                DispatchQueue.main.async {
                    for (index, view) in views.enumerated() {
                        self.stackView.insertArrangedSubview(view, at: index)
                    }
                    self.delegateStamp?.didLoadStampView(view: self, isdownloadAt: id, andViews: views)
                }
            }
            
        } else {
            print("dung trong DB")
            for (index, view) in views.enumerated() {
                self.stackView.insertArrangedSubview(view, at: index)
            }
        }

        if let dateCreate = atTimeInterval {
            let date = Date(timeIntervalSince1970: TimeInterval(dateCreate))
            self.timeAgoLabel.text = date.timeAgoSinceNow
        } else {
            self.timeAgoLabel.text = ""
        }
    }
    
    func setUserData(userData: TDUser) {
        self.friendInfo = userData
        // Set data for user info
        if let utlStr = userData.profilePicture,
            let url = URL(string: utlStr) {
            _ = self.avatarImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "avatar_placeholder"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                
            },completionHandler: { image, error, cacheType, imageURL in
                
            })
        }
        self.nameLabel.text = userData.name ?? ""
        self.descriptionLabel.text = "shared a stamp collection."
    }
    
    @IBAction func visitFriendProfileButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapToVisitFriendProfile(friendProfile: self.friendInfo)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
