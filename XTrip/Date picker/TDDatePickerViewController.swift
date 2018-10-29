//
//  OLMonthYearPickerViewController.swift
//  Opla-User
//
//  Created by Hoang Cap on 11/28/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation
import SwiftDate

private let MAXIMUM_YEAR_GAP = 50;
protocol TDDatePickerViewDelegate:class {
    func datePickerViewDidSelect(date: Date);
}

extension TDDatePickerViewController {
    func datePickerViewDidSelect(date: Date) {
        //do nothing
    }
}

class TDDatePickerViewController: UIViewController {
    
    static var sharedController: TDDatePickerViewController = {
        let vc = TDDatePickerViewController.loadFromStoryboard();
        vc.modalPresentationStyle = .overCurrentContext;
        return vc;
    }()
    
    var dateToShow = Date();//Set the current date for the picker when self is shown
    
    var minimumDate: Date? {
        didSet {
            if let date = minimumDate, let picker = self.datePicker {
                picker.minimumDate = date
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //At launch, check if mininumDate is set, then set the value for datePicker
        if let date = minimumDate {
            self.datePicker.minimumDate = date;
        } else {//Otherwise set mininumDate to be long ago
            self.datePicker.minimumDate = Date.init(timeIntervalSince1970: 0);
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.opacityView.alpha = 0;//set alpha = 0 here, then we will show the view animatedly in viewDidAppear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        UIView.animate(withDuration: 0.25, animations: {
            self.opacityView.alpha = 1;
            self.datePicker.date = self.dateToShow;
        })
    }
    
    weak var delegate: TDDatePickerViewDelegate?
    
    @IBOutlet weak var opacityView: UIView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        let date = self.datePicker.date;
        self.delegate?.datePickerViewDidSelect(date: date);
        self.presentingViewController?.dismiss(animated: true, completion: nil);
    }
    
    
    func setDate(_ date:Date) {
        
        if let datePicker = self.datePicker {//Must check for datePicker with nil first, because
            datePicker.date = date;
        }
    }
    
    //Sub classes of this abstract class will be designed in MonthYearPickerViewController.storyboard
    override class func storyboardName() -> String {
        return "DatePicker";
    }
}

protocol TDDatePickerShowable: class where Self: UIViewController {
    func showDatePicker()
}

extension TDDatePickerShowable {
    func showDatePicker() {
        AppDelegate.current.window?.rootViewController?.present(TDDatePickerViewController.sharedController, animated: true, completion: nil);
    }
}



