//
//  MyCityTripDetailTableViewCell.swift
//  XTrip
//
//  Created by Khoa Bui on 12/4/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit



class MyCityTripDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var coverView: UIView!
    
//    lazy var cityMyTripView: CityMyTripView = {
//        let cityMyTripView = CityMyTripView.viewFromNib() as! CityMyTripView
//        return cityMyTripView
//    }()
    
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    func setupView() {

    }
    


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

