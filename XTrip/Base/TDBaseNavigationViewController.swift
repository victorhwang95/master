//
//  TDBaseNavigationViewController.swift
//  XTrip
//
//  Created by Hoang Cap on 12/6/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation

class TDBaseNavigationViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "image_app_gradient"), for: .default);
        self.navigationBar.isTranslucent = false;
    }
}
