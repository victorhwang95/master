//
//  PhoneContact.swift
//  XTrip
//
//  Created by Khoa Bui on 12/23/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation
import PhoneNumberKit

class PhoneContact: NSObject {
    
    var contactFullName: NSString?
    var contactFirstName: NSString?
    var contactLastName: NSString?
    var contactEmail: [String]?
    var contactPhoneNum = [String]()
    var contactImage: Data?
    var hasJoinedVaster: Bool?
    var vasterId: String?
    
    convenience init(contactName: String?, firstName: String?, lastName: String?, contactEmail: [String]?, contactPhoneNum:  [String],  image: Data?){
        self.init()
        self.setupWithABRecordRef(contactName, firstName: firstName, lastName: lastName, email: contactEmail, phoneNum: contactPhoneNum, image: image)
    }
    
    func setupWithABRecordRef(_ name: String?, firstName: String?, lastName: String?, email: [String]?, phoneNum:  [String], image: Data?){
        
        contactFullName = name as NSString?
        contactEmail = email
        contactLastName = lastName as NSString?
        contactFirstName = firstName as NSString?
        
        //Process the phoneNum list to international format
        let kit = PhoneNumberKit();
        var countryPhonePrefix = "+1"//Default is +1 for USA
        
        //Then check for current user's country code and get the corresponding phone prefix
        if let country = TDUser.currentUser()?.country,
            let code = kit.countryCode(for: country) {
            countryPhonePrefix = "+" + String(code);
        }
        contactPhoneNum = {
            var result = [String]();
            //process phone numbers, if number not in international format, convert it to international format
            phoneNum.forEach { (phoneNumber) in
                
                var cleanNumber = phoneNumber.components(separatedBy: .whitespaces).joined()
                print("========name: \(contactFullName)")
                print("origin: \(phoneNumber)");
                
                
                if (cleanNumber.starts(with: "+")) {//international format -> add normally
                    result.append(cleanNumber);
                } else {
                    if (cleanNumber.starts(with: "0")) {//Local phone number -> Convert to international
                        cleanNumber.remove(at: cleanNumber.startIndex);
                        cleanNumber = "\(countryPhonePrefix)" + cleanNumber;
                    }
                    result.append(cleanNumber);
                }
                print("After: \(cleanNumber)");
            }
            return result;
        }()

        contactImage = image
    }
}
