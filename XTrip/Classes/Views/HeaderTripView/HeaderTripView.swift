//
//  HeaderTripView.swift
//  XTrip
//
//  Created by Khoa Bui on 12/6/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit

protocol HeaderTripViewDelegate: class {
    func didTapButtonToChannelTypePlace(placeType: PlaceType, atSection: Int)
}

protocol HeaderTripViewCustomLocationDelegate: class {
    func didWriteCustomLocation(name: String)
}

class HeaderTripView: UIView, UITextFieldDelegate {
    
    @IBOutlet weak var hotelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var resWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var barWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var musWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var otherWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var poiWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tabBarOffsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var resImageView: UIImageView!
    @IBOutlet weak var barImageView: UIImageView!
    @IBOutlet weak var museumImageView: UIImageView!
    @IBOutlet weak var hotelImageVIew: UIImageView!
    @IBOutlet weak var ortherImageView: UIImageView!
    @IBOutlet weak var poiImageView: UIImageView!
    @IBOutlet weak var hotelLabel: UILabel!
    @IBOutlet weak var resLabel: UILabel!
    @IBOutlet weak var barLabel: UILabel!
    @IBOutlet weak var museumLabel: UILabel!
    @IBOutlet weak var ortherLabel: UILabel!
    @IBOutlet weak var poiLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    
    weak var delegate: HeaderTripViewDelegate?
    weak var customTextDelegate: HeaderTripViewCustomLocationDelegate?
    var section: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setCustomText(keyword:String) {
        self.locationTextField.text = keyword
    }
    
    func resetToDefault() {
        self.resLabel.textColor = UIColor.init(hex: "5E5E5E")
        self.resImageView.image = #imageLiteral(resourceName: "black_plate_ic")
        
        self.barLabel.textColor = UIColor.init(hex: "5E5E5E")
        self.barImageView.image = #imageLiteral(resourceName: "black_bar_ic")
        
        self.museumLabel.textColor = UIColor.init(hex: "5E5E5E")
        self.museumImageView.image = #imageLiteral(resourceName: "black_museum_ic")
        
        self.hotelLabel.textColor = UIColor.init(hex: "5E5E5E")
        self.hotelImageVIew.image = #imageLiteral(resourceName: "black_hotel_ic")
        
        self.ortherLabel.textColor = UIColor.init(hex: "5E5E5E")
        self.ortherImageView.image = #imageLiteral(resourceName: "black_other2_ic")
        
        self.poiLabel.textColor = UIColor.init(hex: "5E5E5E")
        self.poiImageView.image = #imageLiteral(resourceName: "black_other_ic")
    }
    
    func setData(tripCity: TDTripCity?, googlePlaceData: [String: [TDPlace]]?, tabPosition: PlaceType, atSection: Int = 0) {
        self.resetToDefault()
        self.section = atSection
        switch tabPosition {
        case .restaurant:
            self.resLabel.textColor = UIColor.init(hex: "30B3FF")
            self.resImageView.image = #imageLiteral(resourceName: "plate_ic")
        case .bar:
            self.barLabel.textColor = UIColor.init(hex: "30B3FF")
            self.barImageView.image = #imageLiteral(resourceName: "bar_ic")
        case .museum:
            self.museumLabel.textColor = UIColor.init(hex: "30B3FF")
            self.museumImageView.image = #imageLiteral(resourceName: "museum_ic")
        case .hotel:
            self.hotelLabel.textColor = UIColor.init(hex: "30B3FF")
            self.hotelImageVIew.image = #imageLiteral(resourceName: "hotel_ic")
        case .other, .unknown:
            self.ortherLabel.textColor = UIColor.init(hex: "30B3FF")
            self.ortherImageView.image = #imageLiteral(resourceName: "other2_ic")
        case .POI:
            self.poiLabel.textColor = UIColor.init(hex: "30B3FF")
            self.poiImageView.image = #imageLiteral(resourceName: "other_ic")
        }
        
        if let tripCity = tripCity {
            if let startDate = tripCity.startDate,
                let endDate = tripCity.endDate {
                self.dateLabel.text = "\(startDate.unixTimeToString()) - \(endDate.unixTimeToString())"
            }
            self.hotelLabel.text = "Hotel(\(tripCity.hotelCount ?? 0))"
            self.resLabel.text = "Restaurant(\(tripCity.restaurantCount ?? 0))"
            self.barLabel.text = "Bar(\(tripCity.barCount ?? 0))"
            self.museumLabel.text = "Museum(\(tripCity.museumCount ?? 0))"
            self.ortherLabel.text = "Other(\(tripCity.otherCount ?? 0))"
            self.poiLabel.text = "POI(\(tripCity.poiCount ?? 0))"
            self.cityNameLabel.text = tripCity.name
            self.bringSubview(toFront: self.cityView)
            
        } else if let googlePlaceData = googlePlaceData {
            self.hotelLabel.text = "Hotel(\(googlePlaceData[PlaceType.hotel.description]?.count ?? 0))"
            self.resLabel.text = "Restaurant(\(googlePlaceData[PlaceType.restaurant.description]?.count ?? 0))"
            self.barLabel.text = "Bar(\(googlePlaceData[PlaceType.bar.description]?.count ?? 0))"
            self.museumLabel.text = "Museum(\(googlePlaceData[PlaceType.museum.description]?.count ?? 0))"
            self.ortherLabel.text = "Other(\(googlePlaceData[PlaceType.other.description]?.count ?? 0))"
            self.poiLabel.text = "POI(\(googlePlaceData[PlaceType.POI.description]?.count ?? 0))"
            self.bringSubview(toFront: self.locationView)
        }
        
    }

    @IBAction func hotelTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonToChannelTypePlace(placeType: .hotel, atSection: self.section)
    }
    
    @IBAction func restaurantTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonToChannelTypePlace(placeType: .restaurant, atSection: self.section)
    }
    
    @IBAction func barTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonToChannelTypePlace(placeType: .bar, atSection: self.section)
    }
    
    @IBAction func museumTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonToChannelTypePlace(placeType: .museum, atSection: self.section)
    }
    
    @IBAction func ortherButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonToChannelTypePlace(placeType: .other, atSection: self.section)
    }
    
    @IBAction func poiButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapButtonToChannelTypePlace(placeType: .POI, atSection: self.section)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.customTextDelegate?.didWriteCustomLocation(name: textField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

