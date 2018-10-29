//
//  TDMyActivityViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 12/26/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit

class TDMyActivityViewController: TDBaseViewController {

    // MARK:- Outlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var myMyNewsfeedButton: RoundedButton!
    @IBOutlet weak var myPassportButton: RoundedButton!
    @IBOutlet weak var headerHeightConstraints: NSLayoutConstraint!
    
    // MARK:- Properties
    var myMyNewsfeedListVC: TDMyNewsfeedViewController!
    var myPassportListVC: TDMyPassportViewController!

    // MARK:- Public method
    static func newInstance() -> TDMyActivityViewController {
        return UIStoryboard.init(name: "MyActivity", bundle: nil).instantiateViewController(withIdentifier: "TDMyActivityViewController") as! TDMyActivityViewController
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
        title = "My Activity"
        setupRightButtons(buttonType: .setting)
        changeNavigationBarToTransparentStyle()
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                self.headerHeightConstraints.constant = 120
            default:
                self.headerHeightConstraints.constant = 100
            }
        }
    }
    
    // MARK:- Private method
    func setupView() {
        self.setupChildViewControllers()
    }
    
    fileprivate func setupChildViewControllers() {
        self.myMyNewsfeedButton.setSelectedColor()
        self.myPassportButton.setNonSelectColor()
        if (self.myMyNewsfeedListVC == nil) {
            self.myMyNewsfeedListVC = TDMyNewsfeedViewController.newInstance()
            self.addChild(childViewController: self.myMyNewsfeedListVC, inView: self.contentView)
        }
        if (self.myPassportListVC == nil) {
            self.myPassportListVC = TDMyPassportViewController.newInstance()
        }
    }
    
    //MARK:-  Action
    @IBAction func myMyNewsfeedButtonTapped(_ sender: Any) {
        self.myMyNewsfeedButton.setSelectedColor()
        self.myPassportButton.setNonSelectColor()
        if (self.myMyNewsfeedListVC != nil) && (self.myPassportListVC != nil){
            self.remove(childViewController: self.myPassportListVC)
            self.addChild(childViewController: self.myMyNewsfeedListVC, inView: self.contentView)
        }
    }
    
    @IBAction func myPassportButtonTapped(_ sender: Any) {
        self.myMyNewsfeedButton.setNonSelectColor()
        self.myPassportButton.setSelectedColor()
        if (self.myMyNewsfeedListVC != nil) && (self.myPassportListVC != nil){
            self.remove(childViewController: self.myMyNewsfeedListVC)
            self.addChild(childViewController: self.myPassportListVC, inView: self.contentView)
        }
    }

}
