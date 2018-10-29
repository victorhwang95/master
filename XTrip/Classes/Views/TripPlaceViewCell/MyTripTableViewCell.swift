//
//  MyTripTableViewCell.swift
//  XTrip
//
//  Created by Khoa Bui on 12/11/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit

class MyTripTableViewCell: UITableViewCell {

    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(trip: TDTrip?) {
        self.tripNameLabel.text = trip?.name ?? ""
        if TDUser.currentUser()?.id != trip?.friend?.id {
            self.ownerNameLabel.text = trip?.friend?.name ?? ""
        } else {
            self.ownerNameLabel.text = ""
        }
    }

}
