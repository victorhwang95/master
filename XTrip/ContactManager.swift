//
//  ContactManager.swift
//  XTrip
//
//  Created by Khoa Bui on 12/23/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation
import Contacts
import ContactsUI

let CONTACT_MANAGER = ContactManager.sharedInstance


class ContactManager {
    
    var deviceContacts: [PhoneContact]?//Cached list of PhoneContact after the Contact Book is loaded once
    
    // MARK: Shared Instance
    class var sharedInstance: ContactManager {
        struct Singleton {
            static let instance = ContactManager()
        }
        return Singleton.instance
    }
    
    func syncContactWithServer(completionHandler completion:((_ completed: Bool) -> Void)?) -> Void {
        self.requestForAccess(completionHandler: { (accessGranted) in
            if accessGranted {
                
                //Check for cached list of contacts first and use the cache is available
                if let contacts = self.deviceContacts {
                    API_MANAGER.requestSyncContacts(contacts: contacts, success: { _ in
                        completion?(true)
                    }, failure: { (error) in
                        completion?(false)
                    })
                } else {//If cache not available -> Request somewhere else
                    self.getContactBook { (contactArray) in
                        self.deviceContacts = contactArray.sorted {
                            $0.contactFullName!.localizedCaseInsensitiveCompare($1.contactFullName as! String) == ComparisonResult.orderedAscending
                        }
                        
                        // Firebase analytics
                        FIR_MANAGER.sendAppEvent(withEvent: FIREvent.SYNC_CONTACT_FUNCTION.rawValue, userId: nil)
                        
                        API_MANAGER.requestSyncContacts(contacts: contactArray, success: { _ in
                            completion?(true)
                        }, failure: { (error) in
                            completion?(false)
                        })
                    }
                }
            }else{
                completion?(false)
            }
        })
    }
    
    func requestForAccess(completionHandler completion:((_ completed: Bool) -> Void)?) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        let contactStore = CNContactStore()
        
        switch authorizationStatus {
        case .authorized:
            completion?(true)
            
        case .denied, .notDetermined:
            contactStore.requestAccess(for: .contacts, completionHandler: { [weak self](access, accessError) -> Void in
                if let weakSelf = self {
                    if access {
                        completion?(access)
                    }
                    else {
                        DispatchQueue.main.async(execute: {
                            completion?(false)
                        })
                    }
                }
            })
            
        default:
            completion?(false)
        }
    }
    
    func contactList() -> [CNContact] {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
    }
    
    func getContactBook(completionHandler completion:((_ contacts: [PhoneContact]) -> Void)?) -> Void{
        var cons = [PhoneContact]()
        let contacts = self.contactList()
        for contact in contacts {
            let fullname = CNContactFormatter.string(from: contact, style: .fullName)
            let firstName = contact.givenName
            let image = contact.imageData
            let lastName = contact.familyName
            var phones = [String]()
            for phone in contact.phoneNumbers{
                let phoneStr = NSString(string: phone.value.stringValue)
                if phoneStr.length > 0 {
                    phones.append(phoneStr as String)
                }
            }
            
            var emails = [String]()
            for email in contact.emailAddresses{
                let emailStr = email.value
                if emailStr.length > 0{
                    emails.append(emailStr as String)
                }
            }
            if (fullname != nil) && phones.count != 0 {
                let phoneContact = PhoneContact(contactName: fullname, firstName: firstName, lastName: lastName, contactEmail: emails, contactPhoneNum: phones, image: image)
                cons.append(phoneContact)
            }
        }
        
        self.deviceContacts = cons;
        completion?(cons)
    }
}
