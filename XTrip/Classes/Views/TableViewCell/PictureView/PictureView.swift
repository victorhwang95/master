//
//  PictureView.swift
//  XTrip
//
//  Created by Khoa Bui on 1/7/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit
import Kingfisher

class PictureView: UITableViewCell {

    @IBOutlet weak var pictureImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func setData(pictureData: TDMyPicture?) {
        if let utlStr = pictureData?.imageUrl,
            let url = URL(string: utlStr) {
            _ = self.pictureImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "sampleImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                
            },completionHandler: { image, error, cacheType, imageURL in
                
            })
        }
    }
}
