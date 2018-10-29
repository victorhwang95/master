//
//  TDFilterTimeListViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 1/9/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit

protocol FilterTimeListViewControllerDelegate: class {
    func didSelectFilterTime(viewController: TDFilterTimeListViewController, filterTimeKey: (key: String?, title: String), resignFilterMode resign: Bool)
}

class TDFilterTimeListViewController: UIViewController {
    
    // MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK:- Properties
    weak var delegate: FilterTimeListViewControllerDelegate?
    var timeFilterArray: [(key: String?, title: String)] = [("24h","Last 24 Hours"),  ("3d", "Last 3 Days"), ("7d", "Last 7 Days"), ("30d", "Last 30 Days"), ("90d", "Last 90 Days")]
    
    // MARK:- Public method
    static func newInstance() -> TDFilterTimeListViewController {
        return UIStoryboard.init(name: "MyPictures", bundle: nil).instantiateViewController(withIdentifier: "TDFilterTimeListViewController") as! TDFilterTimeListViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Action method
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapGestureTapped(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension TDFilterTimeListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let timeStr = self.timeFilterArray[indexPath.row]
            self.delegate?.didSelectFilterTime(viewController: self, filterTimeKey: timeStr, resignFilterMode: true)
            self.dismiss(animated: true, completion: nil)
        } else {
            let timeStr = self.timeFilterArray[indexPath.row]
            self.delegate?.didSelectFilterTime(viewController: self, filterTimeKey: timeStr, resignFilterMode: false)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
}

extension TDFilterTimeListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return self.timeFilterArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTimeCell", for: indexPath) as! FilterTimeTableViewCell
        if indexPath.section == 0 {
            cell.timeLabel.text = "Recent Added"
            return cell
        } else {
            let timeStr = self.timeFilterArray[indexPath.row].title
            cell.timeLabel.text = timeStr
            return cell
        }
    }
}
