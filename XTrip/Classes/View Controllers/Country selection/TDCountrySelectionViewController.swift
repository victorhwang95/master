//
//  TDCountrySelectionViewController.swift
//  XTrip
//
//  Created by Hoang Cap on 11/13/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation

class CountryCell:UITableViewCell {
    
    @IBOutlet weak var countryImageView: UIImageView!
    @IBOutlet weak var countryNameLabel: UILabel!
    
    @IBOutlet weak var orderView: RoundedView!
    @IBOutlet weak var orderLabel: UILabel!
}

protocol TDCountrySelectionViewDelegate:class {
    func countrySelectionViewDidPickCountryCodes(_ codes:[String]);
}


/// additional delegate used for Facebook registration process
protocol TDCountrySelectionViewFBDelegate:class {
    func countrySelectionViewDidPickCountryCodesForFacebook(_ codes:[String]);
    func countrySelectionViewDidCancel();//Callback to delegate when user tap on "Back" button without choosing any country
}

private let countryCodes: [String] = {
    //    do {
    let file = Bundle.main.url(forResource: "Countries", withExtension: "json")!;
    let data = try! Data(contentsOf: file);
    let json = try! JSONSerialization.jsonObject(with: data, options: []);
    let object = json as! [[String: Any]];
    let arr = object.flatMap({ (dict) -> String in
        return dict["alpha-2"] as! String;
    });
    
    //1. After country codes are retrieved -> Get the list of country names
    var countryNames = arr.flatMap({ (countryCode) -> String in
        if let countryName = countryCode.countryName {
            return countryName;
        } else {
            return countryCode;
        }
    })
    
    //2. Sort the country names
    countryNames = countryNames.sorted();
    
    //After country names are sorted, we will sort the country code accordingly
    var sorted = [String]();
    countryNames.forEach({ (countryName) in
        arr.forEach({ (countryCode) in
            if let name = countryCode.countryName {
                if (name == countryName) {
                    sorted.append(countryCode);
                }
            }
        })
    })
    
    //Finally, filter the codes: If coresponding names and flags exists -> Keep it
    sorted = sorted.filter({ (code) -> Bool in
        let countryName = code.countryName;
        let flag = UIImage.init(named: code);
        return countryName != nil && flag != nil;
    })

    sorted.forEach({ (str) in
        print(str);
    })
    
    return sorted;
}()

class TDCountrySelectionViewController:UIViewController {
    
    var allowsMultipleSelection = false;//Determines if multiple selection is allowed or not.
    
    var selectedCountryCodes = [String]()//List of country that will be passed in delegate callback.
    
    var showUnknownCountry = false;
    
    weak var delegate:TDCountrySelectionViewDelegate?;
    weak var facebookDelegate:TDCountrySelectionViewFBDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var displayCountryCodes = [String]() {
        didSet {
            self.tableView.reloadData();
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.title = "Select your country";
        self.navigationController?.navigationBar.barTintColor = UIColor.init(hex: "#2DC3FA")
        let closeButton = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        self.navigationItem.leftBarButtonItem = closeButton;
        
//        //If allowsMultipleSelection -> Display "Done" button for selection confirmation
//        if (self.allowsMultipleSelection) {
            let doneButton = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(done))
            self.navigationItem.rightBarButtonItem = doneButton;
//        }
        self.displayCountryCodes = countryCodes;
        if showUnknownCountry {
            self.displayCountryCodes.append("Unknown")
        }
    }
    
    func cancel() {
        self.presentingViewController?.dismiss(animated: true, completion: nil);
        self.facebookDelegate?.countrySelectionViewDidCancel();
    }
    
    func done() {
        if (self.selectedCountryCodes.count > 0) {
            self.delegate?.countrySelectionViewDidPickCountryCodes(self.selectedCountryCodes);
            self.facebookDelegate?.countrySelectionViewDidPickCountryCodesForFacebook(self.selectedCountryCodes);
            self.presentingViewController?.dismiss(animated: true, completion: nil);
        }
    }
}

extension TDCountrySelectionViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.displayCountryCodes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath) as! CountryCell;
        
        let row = indexPath.row;
        
        let countryCode = self.displayCountryCodes[row];
        if let countryName = countryCode.countryName {
            cell.countryNameLabel.text = countryName;
        }
        if let countryImage = UIImage.init(named: countryCode) {
            cell.countryImageView.image = countryImage;
        }
        
        if let index = self.selectedCountryCodes.index(of: countryCode) {
            
            cell.orderView.alpha = 1;
            
            if (allowsMultipleSelection) {//In case of of multiple selection -> Display the order
                cell.orderLabel.text = "\(index + 1)";
            } else {
                cell.orderLabel.isHidden = true;//Hide the orderLabel, so the "Tick" image will be revealed
            }
        } else {
            cell.orderView.alpha = 0;
        }
        
        
        return cell;
    }
}

extension TDCountrySelectionViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row;
        let countryCode = self.displayCountryCodes[row];
        
        if (selectedCountryCodes.contains(countryCode)) {
            self.selectedCountryCodes.remove(countryCode);
        } else {
            if (allowsMultipleSelection) {
                self.selectedCountryCodes.append(countryCode);
            } else {
                self.selectedCountryCodes = [countryCode];
            }
        }
        tableView.reloadData();

//        //If multiple selection is allowed -> Handle properly
//        if (allowsMultipleSelection) {
//            tableView.reloadData();
//        } else {//Only single selection is allow -> Call delegate method
//
//            self.delegate?.countrySelectionViewDidPickCountryCodes(self.selectedCountryCodes);
//
//            //Also call facebookDelegate method because in facebook login, we only allow single selection
//            self.facebookDelegate?.countrySelectionViewDidPickCountryCodesForFacebook(self.selectedCountryCodes)
//        }
    }
}

extension TDCountrySelectionViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.length > 0) {
            self.displayCountryCodes = countryCodes.filter({ (code) -> Bool in
                if let name = code.countryName {
                    return name.starts(with: searchText);
                } else {
                    return false;
                }
            })
        } else {
            self.displayCountryCodes = countryCodes;
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder();
    }
    
}

extension String {
    var countryName:String? {
        let locale = Locale.init(identifier: "en_US");
        return locale.localizedString(forRegionCode: self) ?? "Unknown";
    }
}
