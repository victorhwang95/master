//
//  ValidStampTableViewCell.swift
//  XTrip
//
//  Created by Khoa Bui on 2/11/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit

class ValidStampTableViewCell: UITableViewCell {

    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
