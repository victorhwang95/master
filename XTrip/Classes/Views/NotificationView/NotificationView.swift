//
//  NotificationView.swift
//  XTrip
//
//  Created by Khoa Bui on 1/2/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit

protocol NotificationViewDelegate: class {
    func didTapNotificationBarButton()
}

class NotificationView: UIView {

    @IBOutlet weak var notificationCountLabel: UILabel!
    weak var delegate: NotificationViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.notificationCountLabel.setRoundedCorner(radius: self.notificationCountLabel.width/2)
        self.notificationCountLabel.text = ""
        self.notificationCountLabel.isHidden = true
    }
    
    func setData(count: Int) {
        if count != 0 {
            self.notificationCountLabel.isHidden = false
            self.notificationCountLabel.text = "\(count)"
        } else {
            self.notificationCountLabel.isHidden = true
            self.notificationCountLabel.text = ""
        }
    }

    @IBAction func notificationButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapNotificationBarButton()
    }
}
