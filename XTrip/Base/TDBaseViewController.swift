//
//  TDBaseViewController.swift
//  XTrip
//
//  Created by Hoang Cap on 11/29/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation

import UINavigationItem_Margin

enum RightButtonType: Int {
    case setting = 0
    case save
}

class TDBaseViewController: UIViewController {
    
    var notificationBarView: NotificationView?
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //Also set the attributes for navigation title
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white];
        self.changeNavigationBarToDefaultStyle()
        
        //Show the custom back bar button when self is on top of navigation stack
        if let viewControllers = self.navigationController?.viewControllers,
            self != viewControllers.first {
            
            let button = UIButton()
            button.setImage(#imageLiteral(resourceName: "button_navigationBack"), for: .normal)
            button.addTarget(self, action: #selector(popNavigation), for: .touchUpInside)
            let barButton = UIBarButtonItem(customView: button)
            
            if #available(iOS 11.0, *) {
                barButton.customView?.snp.makeConstraints({ (make) in
                    make.width.equalTo(45)
                    make.height.equalTo(36)
                })
                
                self.navigationItem.leftBarButtonItems = [barButton]
                
            } else {
                button.frame = CGRect(x: 0, y: 0, width: 45, height: 36);
            }
            self.navigationItem.leftBarButtonItems = [barButton]
            self.navigationItem.leftMargin = 0;
        }
        
    }
    
    func popNavigation() {
        self.navigationController?.popViewController(animated: true);
    }
    
    func setupRightButtons(buttonType: RightButtonType) {
        
        switch buttonType {
        case .setting:
            let button = UIButton()
            button.setImage(#imageLiteral(resourceName: "button_navigationSetting"), for: .normal)
            button.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
            let barButton = UIBarButtonItem(customView: button)
            if #available(iOS 11.0, *) {
                barButton.customView?.snp.makeConstraints({ (make) in
                    make.width.equalTo(45)
                    make.height.equalTo(36)
                })
                
            } else {
                button.frame = CGRect(x: 0, y: 0, width: 45, height: 36);
            }
            self.navigationItem.rightBarButtonItems = [barButton];
            self.navigationItem.rightMargin = 0;
        case .save:
            
            let button = UIButton();
            button.setTitle("Save", for: .normal);
            button.sizeToFit();
            
            button.titleLabel?.layer.shadowRadius = 3
            button.titleLabel?.layer.shadowColor = UIColor.black.cgColor
            button.titleLabel?.layer.shadowOffset = CGSize(width: 0, height: 1)
            button.titleLabel?.layer.shadowOpacity = 0.5
            button.titleLabel?.layer.masksToBounds = false
            button.addTarget(self, action: #selector(self.saveButtonTapped), for: .touchUpInside);
            
//            let barSaveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveButtonTapped))
            
            let barSaveButton = UIBarButtonItem(customView: button)
            
            self.navigationItem.rightBarButtonItems = [barSaveButton]
            
        }
    }
    
    func setupNavigationButton() {
        
        self.notificationBarView = NotificationView.viewFromNib() as! NotificationView
        notificationBarView?.delegate = self
        let barButton = UIBarButtonItem(customView: notificationBarView!)
        
        if #available(iOS 11.0, *) {
            barButton.customView?.snp.makeConstraints({ (make) in
                make.width.equalTo(45)
                make.height.equalTo(36)
            })
            
            self.navigationItem.leftBarButtonItems = [barButton]
            
        } else {
            self.notificationBarView?.frame = CGRect(x: 0, y: 0, width: 45, height: 36);
        }
        self.navigationItem.leftBarButtonItems = [barButton]
        self.navigationItem.leftMargin = 0;
    }
    
    func settingButtonTapped() {
        self.view.endEditing(true)
        let settingVC = TDSettingViewController.newInstance()
        self.present(settingVC, animated: true, completion: nil)
    }
    
    func saveButtonTapped() {
        self.view.endEditing(true)
    }
    
    func notificationButtonTapped() {
        self.view.endEditing(true)
        let notificationVC = TDNotificationViewController.newInstance()
        self.navigationController?.pushViewController(notificationVC, animated: true)
    }
    
    func changeNavigationBarToDefaultStyle() {
        
        let attributes:NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = attributes as? [String : AnyObject]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "background_image_navigation") ,for: .default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    func changeNavigationBarToTransparentStyle() {
        
        let attributes:NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = attributes as? [String : AnyObject]
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    }
}

extension TDBaseViewController: NotificationViewDelegate {
    func didTapNotificationBarButton() {
        self.notificationButtonTapped()
    }
}
