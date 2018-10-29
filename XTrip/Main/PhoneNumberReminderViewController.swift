//
//  PhoneNumberReminderViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 4/6/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit

protocol PhoneNumberReminderViewControllerDelegate: class {
    func didTapToUpdatePhoneNumber()
}


class PhoneNumberReminderViewController: UIViewController {

    // MARK:- Properties

    
    // MARK:- Outlets
    weak var delegate: PhoneNumberReminderViewControllerDelegate?
    
    // MARK:- Public method
    static func newInstance() -> PhoneNumberReminderViewController {
        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhoneNumberReminderViewController") as! PhoneNumberReminderViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func okButtonTapped(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: {() -> () in
            
        })
        self.delegate?.didTapToUpdatePhoneNumber()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
