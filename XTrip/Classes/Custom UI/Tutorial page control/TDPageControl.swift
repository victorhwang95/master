//
//  TDPageControl.swift
//  XTrip
//
//  Created by Hoang Cap on 1/26/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import Foundation
import SnapKit

import UIKit

class TDPageControl: UIView {
     @IBOutlet weak var stackView: UIStackView!
    
    var contentView: UIView!;
    
    var cachedDots = [TDPageDot]();
    
    var numberOfPages: Int = 1 {
        didSet {
            if (self.stackView != nil) {
                self.addDots();
            }
        }
    }
    
    var currentPage: Int = 0 {
        didSet {
            for i in 0 ..< self.numberOfPages {
                let view = self.stackView.arrangedSubviews[i] as! TDPageDot;
                if (i == currentPage) {
                    view.setBigSize(true);
                } else {
                    view.setBigSize(false);
                }
            }
        }
    }
    
    private func addDots() {
        //First remove all the subviews
        for view in self.stackView.arrangedSubviews {
            self.stackView.removeArrangedSubview(view);
            view.removeFromSuperview();
        }
        
        //Then add new subviews
        for _ in 0 ..< self.numberOfPages {
            let view = UINib(nibName: "TDPageDot", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TDPageDot
            view.snp.makeConstraints({ (maker) in
                maker.width.equalTo(view.width);
                maker.height.equalTo(view.height);
            })
            self.stackView.addArrangedSubview(view);
        }
        self.currentPage = 0;//Reset currentPage to 0 and re-size the dots when numberOfPages is reset
        self.layoutSubviews();
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib();
        self.baseSetup()
    }
    
    private func baseSetup() {
        self.backgroundColor = .clear;
        let view = Bundle.main.loadNibNamed("TDPageControl", owner: self, options: nil)?.last;
        if let view = view as? UIView {
            self.contentView = view;
            self.addSubview(view);
            view.frame = self.bounds;
            view.autoresizingMask = [.flexibleWidth,  .flexibleHeight];
        }
    }
    
    
}


