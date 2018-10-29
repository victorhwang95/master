//
//  StampFBShareContainerView.swift
//  XTrip
//
//  Created by Khoa Bui on 5/23/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit
import SnapKit

class StampFBShareContainerView: UIView {

    @IBOutlet weak var widthContainerViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func loadData(stampSelectedArray: [TDStamp]) {
        var oldFrame = self.frame
        oldFrame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y, width: CGFloat(150 * stampSelectedArray.count), height: 150)
        self.frame = oldFrame
        self.widthContainerViewConstraint.constant = CGFloat(150 * stampSelectedArray.count)
        var lastStampFBShareView: StampFBShareView?
        for stampSelected in stampSelectedArray {
            let captureView = StampFBShareView.viewFromNib() as! StampFBShareView
            captureView.loadData(stamp: stampSelected, selectedStamp: [], isVisitFriendLayout: true)
            self.containerView.addSubview(captureView)
            // Set autolay constraint
            captureView.snp.makeConstraints {(make) in
                
                make.top.bottom.equalTo(self.containerView)
                make.width.equalTo(150)
                if let lastStampFBShareView = lastStampFBShareView {
                    make.left.equalTo(lastStampFBShareView.snp.right)
                } else {
                    make.left.equalTo(self.containerView)
                }
                if stampSelected.id == stampSelectedArray.last?.id {
                    make.right.equalTo(self.containerView)
                }
                lastStampFBShareView = captureView
            }
        }
    }
}
