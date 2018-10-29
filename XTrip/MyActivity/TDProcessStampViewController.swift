//
//  TDProcessStampViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 1/31/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import UIKit

class TDProcessStampViewController: TDBaseViewController {

    // MARK:- Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stampImageView: UIImageView!
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var countryImage: UIImageView!
    
    @IBOutlet weak var stampDateLabel: UILabel!
    @IBOutlet weak var stampCountryLabel: UILabel!
    
    
    // MARK:- Properties
    var stampCountryInfo: TDLocalCountry?
    var chooseStampCountry: TDLocalCountry?
    var isChooseNewStamp: Bool = false
    
    // MARK:- Public method
    static func newInstance() -> TDProcessStampViewController {
        return UIStoryboard.init(name: "MyActivity", bundle: nil).instantiateViewController(withIdentifier: "TDProcessStampViewController") as! TDProcessStampViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func loadData() {
        
        let data = self.isChooseNewStamp ? chooseStampCountry : stampCountryInfo
        
        self.titleLabel.text = "You are in \(data?.name ?? "country")"
        self.countryLabel.text = data?.name ?? ""
        self.countryImage.image = UIImage.init(named: (data?.alpha2)!)

        if let stampImageUrl = data?.stamp {
            self.stampImageView.image = UIImage.init(named: stampImageUrl)
        } else {
            self.stampImageView.image = #imageLiteral(resourceName: "sampleImage")
        }
        
        if self.isChooseNewStamp {
            self.stampDateLabel.text = data?.date?.timeIntervalSince1970.unixTimeToDayMonthYearString();
        } else {
            self.stampDateLabel.text = Date().timeIntervalSince1970.unixTimeToDayMonthYearString();
        }

        self.stampCountryLabel.text = data?.name;
        self.stampCountryLabel.superview?.bringSubview(toFront: self.stampCountryLabel);
        self.stampDateLabel.superview?.bringSubview(toFront: self.stampDateLabel);
    }
    
    
    @IBAction func processButtonTapped(_ sender: UIButton) {
        
        let data = self.isChooseNewStamp ? chooseStampCountry : stampCountryInfo
        
        
        if let countryCode = data?.alpha2 {
            self.xt_startNetworkIndicatorView(withMessage: "Processing...")
            
            // Firebase analytics
            FIR_MANAGER.sendAppEvent(withEvent: FIREvent.POST_MY_PASSPORT_FUNCTION.rawValue, userId: nil)
            
            let date: TimeInterval!;
            if let chosenDate = chooseStampCountry?.date?.timeIntervalSince1970, self.isChooseNewStamp {
                date = chosenDate;
            } else {
                date = Date().timeIntervalSince1970;
            }
            
            API_MANAGER.postStampByCountryCode(countryCode: countryCode, uploadedAt: date, success: {
                self.xt_stopNetworkIndicatorView()
                self.navigationController?.popToRootViewController(animated: true)
            }) { (error) in
                self.xt_stopNetworkIndicatorView()
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func chooseCountryButtonTapped(_ sender: UIButton) {
        let vc = ValidStampPhotoViewController.newInstance()
        vc.currentStampCountryInfo = stampCountryInfo
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
}

extension TDProcessStampViewController: ValidStampPhotoViewControllerDelegate {
    func didSelectValidStamp(viewController: ValidStampPhotoViewController, validStamp: ValidStamp?) {
        if let validStamp = validStamp {
            self.isChooseNewStamp = true
            for localStamp in self.getCountryListFromJsonFile() {
                if validStamp.countryCode == localStamp.alpha2 {
                    self.chooseStampCountry = localStamp
                    self.chooseStampCountry?.date = validStamp.createDate
                    self.loadData()
                    break
                }
            }
        } else {
            self.isChooseNewStamp = false
            self.loadData()
        }
    }
}

extension TDProcessStampViewController: TDCountrySelectionViewDelegate {
    func countrySelectionViewDidPickCountryCodes(_ codes: [String]) {
        self.dismiss(animated: true, completion: nil);
        if let stampImage = UIImage(named: codes.first! + "_stamp") {
            let code = codes.first!;//Unwrapping is safe
            
            self.countryLabel.text = code.countryName;
            
            self.countryImage.image = UIImage.init(named: code)!
            
            self.stampImageView.image = stampImage
        }
    }
}
