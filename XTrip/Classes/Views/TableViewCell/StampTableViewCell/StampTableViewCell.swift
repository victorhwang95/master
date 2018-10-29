//
//  StampTableViewCell.swift
//  XTrip
//
//  Created by Khoa Bui on 1/28/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit
import ObjectMapper

protocol StampTableViewCellDelegate: class {
    func didLoadStampView(view: StampTableViewCell, atStampId: Int, withRotationValue: Int)
}

class StampTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stampImageView: UIImageView!
    @IBOutlet weak var stampNameLabel: UILabel!
    @IBOutlet weak var selectedButton: UIButton!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var stampView: UIView!
    @IBOutlet weak var customDateLabel: UILabel!
    
    weak var delegate: StampTableViewCellDelegate?
    var countryList :[TDLocalCountry] = []
    let rotateArray = [-19,-20,20,19]
    var stamp: TDStamp!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.countryList = self.getCountryListFromJsonFile()
    }

    func loadData(stamp: TDStamp, selectedStamp: [Int], isVisitFriendLayout: Bool = false, rotationValue: Int?) {
        self.stamp = stamp
        for localStamp in self.countryList  {
            if stamp.countryCode == localStamp.alpha2 {
                self.stampImageView.image = UIImage(named: localStamp.stamp ?? "")?.tinted(with: UIColor(hex: localStamp.color ?? ""))
                self.stampNameLabel.text = localStamp.name ?? ""
                self.stampNameLabel.textColor = UIColor(hex: localStamp.color ?? "")
                if let uploadedAt = stamp.uploadedAt {
                    self.dayLabel.text = "\(uploadedAt.unixTimeToDayString())"
                    self.dateLabel.text = "\(uploadedAt.unixTimeToDayMonthYearString())"
                    self.customDateLabel.text = "\(uploadedAt.unixTimeToDayMonthYearString())"
                } else {
                    self.dayLabel.text = ""
                    self.dateLabel.text = ""
                    self.customDateLabel.text = ""
                }
                break
            }
        }
        
        if selectedStamp.contains(stamp.id ?? 0) {
            selectedButton.isSelected = true
        } else {
            selectedButton.isSelected = false
        }
        
        if isVisitFriendLayout {
            self.selectedButton.isHidden = true
        }
        
        if let rotationValue = rotationValue {
            stampView.transform = .identity
            let randomArc = rotationValue
            stampView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / CGFloat(rotateArray[randomArc]))
            print("dung lai")
        } else {
            stampView.transform = .identity
            let randomArc = (Int(arc4random_uniform(UInt32(rotateArray.count))))
            stampView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / CGFloat(rotateArray[randomArc]))
            self.delegate?.didLoadStampView(view: self, atStampId: stamp.id ?? 0, withRotationValue: randomArc)
            print("tao moi")
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func selectedButtonTapped(_ sender: UIButton) {
        
    }
}

extension UIImage {
    func tinted(with color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        color.set()
        withRenderingMode(.alwaysTemplate)
            .draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

