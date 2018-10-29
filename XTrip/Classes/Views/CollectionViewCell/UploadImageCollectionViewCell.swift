//
//  UploadImageCollectionViewCell.swift
//  XTrip
//
//  Created by Khoa Bui on 12/13/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import Kingfisher

class UploadImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    
    func setData(image: UIImage?, editImageUrl: String?, updateImageUrl: String?) {
        if let updateImageUrl = updateImageUrl {
            self.postImageView.image = Ultilities.getImage(updateImageUrl)
        } else if let utlStr = editImageUrl, let url = URL(string: utlStr) {
            
            _ = self.postImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "sampleImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                
            },completionHandler: { image, error, cacheType, imageURL in
                
            })
        } else if let image = image {
            self.postImageView.image = image
        }
    }
}
