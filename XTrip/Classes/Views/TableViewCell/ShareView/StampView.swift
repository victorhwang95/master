//
//  StampView.swift
//  XTrip
//
//  Created by Khoa Bui on 2/3/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit

class StampView: UIView {
    
    @IBOutlet weak var firstStampView: UIView!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var firstTimeLabel: UILabel!
    
    @IBOutlet weak var secondStampView: UIView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var secondTimeLabel: UILabel!
    
    @IBOutlet weak var thirdStampView: UIView!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var thirdTimeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupLayout()
    }
    
    func setupLayout() {
        
        firstStampView.transform = .identity
        firstStampView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / -20)
        
        secondStampView.transform = .identity
        secondStampView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / -20)
        
        thirdStampView.transform = .identity
        thirdStampView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / -20)
        
        
    }
    
    func setData(stampCountryArray: [(stampId: Int, stampCountry: String)]) {
        if stampCountryArray.count > 0 {
            for localStamp in self.getCountryListFromJsonFile() {
                if stampCountryArray[0].stampCountry == localStamp.alpha2 {
                    self.firstImageView.image = UIImage(named: localStamp.stamp ?? "")
                    self.firstTimeLabel.text = localStamp.name ?? ""
                    break
                }
            }
            self.secondStampView.isHidden = true
            self.thirdStampView.isHidden = true
        }
        if stampCountryArray.count > 1 {
            for localStamp in self.getCountryListFromJsonFile() {
                if stampCountryArray[1].stampCountry == localStamp.alpha2 {
                    self.secondImageView.image = UIImage(named: localStamp.stamp ?? "")
                    self.secondTimeLabel.text = localStamp.name ?? ""
                    break
                }
            }
            self.thirdStampView.isHidden = true
        }
        if stampCountryArray.count > 2 {
            for localStamp in self.getCountryListFromJsonFile() {
                if stampCountryArray[2].stampCountry == localStamp.alpha2 {
                    self.thirdImageView.image = UIImage(named: localStamp.stamp ?? "")
                    self.thirdTimeLabel.text = localStamp.name ?? ""
                    break
                }
            }
        }
    }
}
