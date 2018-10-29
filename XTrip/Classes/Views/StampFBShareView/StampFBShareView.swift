//
//  StampFBShareView.swift
//  XTrip
//
//  Created by Khoa Bui on 4/3/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit

class StampFBShareView: UIView {

    @IBOutlet weak var stampImageView: UIImageView!
    @IBOutlet weak var stampNameLabel: UILabel!
//    @IBOutlet weak var dayLabel: UILabel!
//    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var stampView: UIView!
    @IBOutlet weak var customDateLabel: UILabel!

    
    let rotateArray = [-19,-20,20,19]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupLayout()
    }
    
    func setupLayout() {
        stampView.transform = .identity
        let randomArc = (Int(arc4random_uniform(UInt32(rotateArray.count))))
        stampView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / CGFloat(rotateArray[randomArc]))
        print(CGFloat(rotateArray[randomArc]))
    }
    
    func loadData(stamp: TDStamp, selectedStamp: [Int], isVisitFriendLayout: Bool = false) {
        for localStamp in self.getCountryListFromJsonFile() {
            if stamp.countryCode == localStamp.alpha2 {
                self.stampImageView.image = UIImage(named: localStamp.stamp ?? "")?.tinted(with: UIColor(hex: localStamp.color ?? ""))
                self.stampNameLabel.text = localStamp.name ?? ""
                self.stampNameLabel.textColor = UIColor(hex: localStamp.color ?? "")
                if let createAt = stamp.uploadedAt {
//                    self.dayLabel.text = "\(createAt.unixTimeToDayString())"
//                    self.dateLabel.text = "\(createAt.unixTimeToDayMonthYearString())"
                    self.customDateLabel.text = "\(createAt.unixTimeToDayMonthYearString())"
                } else {
//                    self.dayLabel.text = ""
//                    self.dateLabel.text = ""
                    self.customDateLabel.text = ""
                }
                break
            }
        }
    }
    
}
