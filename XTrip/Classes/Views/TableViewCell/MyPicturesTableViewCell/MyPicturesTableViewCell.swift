//
//  MyPicturesTableViewCell.swift
//  XTrip
//
//  Created by Khoa Bui on 12/15/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import Kingfisher

enum ImageActionType {
    case share
    case edit
    case delete
    case update
}

protocol MyPicturesTableViewCellDelegate: class {
    func didTapButtonWithType(imageViewCell: MyPicturesTableViewCell, withAction type: ImageActionType, andPicture picture: TDMyPicture)
}

class MyPicturesTableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    weak var delegate: MyPicturesTableViewCellDelegate?
    var picture: TDMyPicture!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(data: TDMyPicture) {
        self.picture = data
        
        if let isUpload = data.isUpload, isUpload == false {
            self.updateButton.isHidden = false
            self.likeView.isHidden = true
            self.postImageView.image = Ultilities.getImage(data.imageUrl ?? "")
        } else {
            self.updateButton.isHidden = true
            self.likeView.isHidden = false
//            self.likeImageView.image = data.isLiked ? #imageLiteral(resourceName: "button_heart") : #imageLiteral(resourceName: "button_not_heart")
            self.likeCountLabel.text = "\(data.likeCount ?? 0)"
            self.commentCountLabel.text = "\(data.commentCount ?? 0)"
            if let utlStr = data.imageUrl, let url = URL(string: utlStr) {
                _ = self.postImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "sampleImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                    
                },completionHandler: { image, error, cacheType, imageURL in
                    
                })
            }
        }
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonWithType(imageViewCell: self, withAction: .update, andPicture: self.picture)
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        self.delegate?.didTapButtonWithType(imageViewCell: self, withAction: .edit, andPicture: self.picture)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        if let isUpload = picture.isUpload, isUpload == false {
            // delele local
        } else {
            self.delegate?.didTapButtonWithType(imageViewCell: self, withAction: .delete, andPicture: self.picture)
        }
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {

    }
}
