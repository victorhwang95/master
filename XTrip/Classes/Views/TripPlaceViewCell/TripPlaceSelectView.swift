//
//  TripPlaceSelectView.swift
//  XTrip
//
//  Created by Khoa Bui on 12/10/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation

enum ItemPosition {
    case first
    case last
    case mid
}

class TripPlaceSelectView: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var choiceButton: UIButton!
    @IBOutlet weak var coverView: RoundedView!
    @IBOutlet weak var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setData(googlePlaceData: TDPlace?, selectedPlace: TDPlace?) {
        dateLabel.isHidden = true
        self.titleLabel.text = googlePlaceData?.name ?? ""
        if let googlePlaceData = googlePlaceData,
            let selectedPlace = selectedPlace,
            googlePlaceData.placeId == selectedPlace.placeId,
            googlePlaceData.type == selectedPlace.type {
            self.choiceButton.isSelected = true
        } else {
            self.choiceButton.isSelected = false
        }
    }
    
    func setDataCityLocation(cityLocation: TDCityLocation?) {
        if let cityLocation = cityLocation {
            self.choiceButton.isHidden = true
            self.titleLabel.text = cityLocation.name
            if let startDate = cityLocation.startDate,
                let endDate = cityLocation.endDate {
                self.dateLabel.text = "\(startDate.unixTimeToString()) - \(endDate.unixTimeToString())"
            }
        }
    }
}
