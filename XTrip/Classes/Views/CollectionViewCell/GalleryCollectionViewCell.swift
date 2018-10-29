//
//  GalleryCollectionViewCell.swift
//  XTrip
//
//  Created by Khoa Bui on 12/9/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var galleryImageView: UIImageView!
    var representedAssetIdentifier: String!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.galleryImageView.image = #imageLiteral(resourceName: "sampleImage")
        self.selectButton.isSelected = false
    }
    
    func flash() {
        self.galleryImageView.alpha = 0
        setNeedsDisplay()
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.galleryImageView.alpha = 1
        })
    }
    

    func setData(image: UIImage, choosePhotoArray: [UIImage]) {
        if (choosePhotoArray.contains(image)) {
            self.selectButton.isSelected = true
        } else {
            self.selectButton.isSelected = false
        }
        self.galleryImageView.image = image
    }
}
