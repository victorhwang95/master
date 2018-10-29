//
//  FilterCountryTableViewCell.swift
//  XTrip
//
//  Created by Khoa Bui on 1/9/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit

class FilterCountryTableViewCell: UITableViewCell {

    @IBOutlet weak var widthImageView: NSLayoutConstraint!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var countryNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
