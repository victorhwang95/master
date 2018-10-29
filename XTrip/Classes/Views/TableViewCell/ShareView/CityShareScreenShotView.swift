//
//  CityShareScreenShotView.swift
//  XTrip
//
//  Created by Khoa Bui on 1/19/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit

class CityShareScreenShotView: UIView {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!

    @IBOutlet weak var hotelLabel: UILabel!
    @IBOutlet weak var resLabel: UILabel!
    @IBOutlet weak var barLabel: UILabel!
    @IBOutlet weak var museumLabel: UILabel!
    
    var shareCity: TDTripCity!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setSharePictureData(cityData: TDTripCity) {
        self.shareCity = cityData
        if let dateCreate = cityData.createDate {
            let date = Date(timeIntervalSince1970: TimeInterval(dateCreate))
            self.timeAgoLabel.text = date.timeAgoSinceNow
        } else {
            self.timeAgoLabel.text = ""
        }
        self.cityNameLabel.text = cityData.name ?? ""
        self.hotelLabel.text = "Hotel(\(cityData.hotelCount ?? 0))"
        self.resLabel.text = "Restaurant(\(cityData.restaurantCount ?? 0))"
        self.barLabel.text = "Bar(\(cityData.barCount ?? 0))"
        self.museumLabel.text = "Museum(\(cityData.museumCount ?? 0))"
    }
}
