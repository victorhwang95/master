//
//  TDMyTripsViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 12/2/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit

var isViewFriendTripDetail: Bool = false

class TDMyTripsViewController: TDBaseViewController {

    // MARK:- Outlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var myTripsButton: RoundedButton!
    @IBOutlet weak var friendTripsButton: RoundedButton!
    @IBOutlet weak var headerHeightConstraints: NSLayoutConstraint!
    
    // MARK:- Properties
    var tripListVC: TDTripListViewController!
    var friendTripLisrVC: TDTripListViewController!
//    var isPostNotification: Bool = false
    
    // MARK:- Public method
    static func newInstance() -> TDMyTripsViewController {
        return UIStoryboard.init(name: "MyTrips", bundle: nil).instantiateViewController(withIdentifier: "TDMyTripsViewController") as! TDMyTripsViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "My Trips"
        setupRightButtons(buttonType: .setting)
        changeNavigationBarToTransparentStyle()
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                self.headerHeightConstraints.constant = 88
            default:
                self.headerHeightConstraints.constant = 64
            }
        }
        
        if isViewFriendTripDetail {
            self.friendTripsAction(UIButton())
        } else {
            self.myTripsAction(UIButton())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Private method
    func setupView() {
        self.myTripsButton.setSelectedColor()
        self.friendTripsButton.setNonSelectColor()
        self.setupChildViewControllers()
    }
    
    fileprivate func setupChildViewControllers() {
        self.myTripsButton.setSelectedColor()
        self.friendTripsButton.setNonSelectColor()
        if (self.tripListVC == nil) {
            self.tripListVC = TDTripListViewController.newInstance()
            self.addChild(childViewController: self.tripListVC, inView: self.contentView)
        }
        if (self.friendTripLisrVC == nil) {
            self.friendTripLisrVC = TDTripListViewController.newInstance()
            self.friendTripLisrVC.isFriendTrip = true
        }
    }
    
    //MARK:-  Action
    @IBAction func myTripsAction(_ sender: Any) {
        self.myTripsButton.setSelectedColor()
        self.friendTripsButton.setNonSelectColor()
        if (self.tripListVC != nil) && (self.friendTripLisrVC != nil){
            self.remove(childViewController: self.friendTripLisrVC)
            self.addChild(childViewController: self.tripListVC, inView: self.contentView)
        }
    }
    
    @IBAction func friendTripsAction(_ sender: Any) {
        self.myTripsButton.setNonSelectColor()
        self.friendTripsButton.setSelectedColor()
        if (self.tripListVC != nil) && (self.friendTripLisrVC != nil){
            self.remove(childViewController: self.tripListVC)
            self.addChild(childViewController: self.friendTripLisrVC, inView: self.contentView)
        }
    }
}
