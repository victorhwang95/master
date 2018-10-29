//
//  TDMyPicturesViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 1/4/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit

class TDMyPicturesViewController: TDBaseViewController {

    // MARK:- Outlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var myPicturesButton: RoundedButton!
    @IBOutlet weak var friendPicturesButton: RoundedButton!
    @IBOutlet weak var headerHeightConstraints: NSLayoutConstraint!
    
    // MARK:- Properties
    var myPictureListVC: TDTripPictureListViewController!
    var friendPictureLisrVC: TDTripPictureListViewController!
    
    // MARK:- Public method
    static func newInstance() -> TDMyPicturesViewController {
        return UIStoryboard.init(name: "MyPictures", bundle: nil).instantiateViewController(withIdentifier: "TDMyPicturesViewController") as! TDMyPicturesViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "My Pictures"
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
    }
    
    // MARK:- Private method
    func setupView() {
        self.myPicturesButton.setSelectedColor()
        self.friendPicturesButton.setNonSelectColor()
        self.setupChildViewControllers()
    }
    
    fileprivate func setupChildViewControllers() {
        self.myPicturesButton.setSelectedColor()
        self.friendPicturesButton.setNonSelectColor()
        if (self.myPictureListVC == nil) {
            self.myPictureListVC = TDTripPictureListViewController.newInstance()
            self.addChild(childViewController: self.myPictureListVC, inView: self.contentView)
        }
        if (self.friendPictureLisrVC == nil) {
            self.friendPictureLisrVC = TDTripPictureListViewController.newInstance()
            self.friendPictureLisrVC.isFriendPicture = true
        }
    }

    //MARK:- Action
    
    @IBAction func myPicturesButtonTapped(_ sender: UIButton) {
        self.myPicturesButton.setSelectedColor()
        self.friendPicturesButton.setNonSelectColor()
        if (self.myPictureListVC != nil) && (self.friendPictureLisrVC != nil){
            self.remove(childViewController: self.friendPictureLisrVC)
            self.addChild(childViewController: self.myPictureListVC, inView: self.contentView)
        }
    }
    
    @IBAction func friendPicturesButtonTapped(_ sender: UIButton) {
        self.myPicturesButton.setNonSelectColor()
        self.friendPicturesButton.setSelectedColor()
        if (self.myPictureListVC != nil) && (self.friendPictureLisrVC != nil){
            self.remove(childViewController: self.myPictureListVC)
            self.addChild(childViewController: self.friendPictureLisrVC, inView: self.contentView)
        }
    }
}
