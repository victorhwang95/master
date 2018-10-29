//
//  TDFilterFriendListViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 1/8/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

protocol FilterFriendListViewControllerDelegate: class {
    func didSelectFilterFriend(viewController: TDFilterFriendListViewController, filterFriendKey: (key: String?, title: String), resignFilterMode resign: Bool)
}

class TDFilterFriendListViewController: UIViewController {

    // MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK:- Properties
    weak var delegate:FilterFriendListViewControllerDelegate?
    var appContactList: [AppContact] = [AppContact]()
    var currentTripPage = 0
    
    // MARK:- Public method
    static func newInstance() -> TDFilterFriendListViewController {
        return UIStoryboard.init(name: "MyPictures", bundle: nil).instantiateViewController(withIdentifier: "TDFilterFriendListViewController") as! TDFilterFriendListViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Private method
    fileprivate func setupView() {
        self.tableView.tableFooterView = UIView()
        self.refreshData()
    }
    
    @objc fileprivate func refreshData() {
        xt_startNetworkIndicatorView(withMessage: "Loading...")
        API_MANAGER.requestGetFriendList(success: { (appContactArray) in
            self.xt_stopNetworkIndicatorView()
            self.appContactList = appContactArray
            self.tableView.reloadData()
        }) { (error) in
            self.xt_stopNetworkIndicatorView()
            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        }
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func tapGestureTapped(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension TDFilterFriendListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let contact = self.appContactList[indexPath.row]
            self.delegate?.didSelectFilterFriend(viewController: self, filterFriendKey: ("\(contact.id ?? 0)", contact.name ?? ""), resignFilterMode: true)
            self.dismiss(animated: true, completion: nil)
        } else {
            let contact = self.appContactList[indexPath.row]
            self.delegate?.didSelectFilterFriend(viewController: self, filterFriendKey: ("\(contact.id ?? 0)", contact.name ?? ""), resignFilterMode: false)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension TDFilterFriendListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return self.appContactList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterFriendCell", for: indexPath) as! FilterFriendTableViewCell
        if indexPath.section == 0 {
            cell.friendNameLabel.text = "All Friends"
            return cell
        } else {
            let contact = self.appContactList[indexPath.row]
            cell.friendNameLabel.text = contact.name
            return cell
        }
    }
}

extension TDFilterFriendListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Opps!", attributes: nil)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No friends to show", attributes: nil)
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
        return #imageLiteral(resourceName: "refesh")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        button.rotateButton(animationDuration: 1, inSecond: 10)
        self.refreshData()
    }
}

