//
//  TDSettingViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 12/20/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import Kingfisher
import FacebookLogin

class TDSettingViewController: TDBaseViewController {
    
    // MARK:- Outlets
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avatarImageView: RoundedImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailTextInput: AnimatedTextInput!
    @IBOutlet weak var nameTextInput: AnimatedTextInput!
    @IBOutlet weak var contactTextInput: AnimatedTextInput!
    @IBOutlet weak var passTextInput: AnimatedTextInput!
    @IBOutlet weak var facebookTextInput: AnimatedTextInput!
    @IBOutlet weak var socialAccountLabel: UILabel!
    @IBOutlet weak var facebookLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var someOneTagMeLabel: UILabel!
    @IBOutlet weak var receiveMessLabel: UILabel!
    @IBOutlet var textInputs: [AnimatedTextInput]!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var someOneTagMeSwitch: UISwitch!
    @IBOutlet weak var receiveMessSwitch: UISwitch!
    @IBOutlet weak var headerHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var topSignOutConstraint: NSLayoutConstraint!
    @IBOutlet weak var topCountryViewConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passordEditButton: UIImageView!
    
    @IBOutlet weak var backButton: UIButton!
    // MARK:- Properties
    var selectedCountryCode: String?
    let picker = UIImagePickerController()
    var selectedCoverImage: UIImage?
    var selectedAvatarImage: UIImage?
    var isCoverPicture: Bool = false
    var isForceUpdatePhoneNumber: Bool = false
    
    // MARK:- Public method
    static func newInstance() -> TDSettingViewController {
        return UIStoryboard.init(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "TDSettingViewController") as! TDSettingViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.settupView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                self.headerHeightConstraints.constant = 84
            default:
                self.headerHeightConstraints.constant = 64
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Private method
    fileprivate func settupView() {
        
        // Setup Navigation bar button amd title
        if self.isForceUpdatePhoneNumber {
            self.backButton.isHidden = true
        }
    
        self.contactTextInput.delegate = self
        self.emailTextInput.type = .email
        self.passTextInput.type = .password(toggleable: false)
        self.passTextInput.delegate = self;
        self.facebookTextInput.isUserInteractionEnabled = false
        
        for textInput in self.textInputs {
            textInput.placeHolderText = ""
            textInput.clearButtonMode = .never
            textInput.delegate = self
        }
        
        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        }
        
        self.picker.delegate = self
        self.picker.popoverPresentationController?.sourceView = self.view
        
        // Load user data
        self.loadUserData()
    }
    
    fileprivate func showImagePicker(fromLibrary library:Bool) {
        self.picker.allowsEditing = false
        self.picker.sourceType = library ? .photoLibrary : .camera
        self.present(picker, animated: true, completion: nil)
    }
    
    fileprivate func changePicture(button: UIButton, isCoverPicture: Bool) {
        var title = ""
        self.isCoverPicture = isCoverPicture
        if isCoverPicture {
            title = "Update Profile Picture"
        } else {
            title = "Update Cover Photo"
        }
        UIAlertController.showActionSheet(in: self, withTitle: title, message: nil, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: ["Choose From My Photo", "Take A Photo"], popoverPresentationControllerBlock: { (popOver) in
            
            popOver.sourceView = button
            
        }) { (controller, index) in
            if (index == 3) {
                self.showImagePicker(fromLibrary: false)
            } else if (index == 2) {
                
                self.showImagePicker(fromLibrary: true)
            }
        }
    }
    
    fileprivate func loadUserData() {
        if let userData = TDUser.currentUser() {
            if let utlStr = userData.coverPicture, let url = URL(string: utlStr) {
                _ = self.coverImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "img_launchImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                    
                },completionHandler: { image, error, cacheType, imageURL in
                })
            }
            
            if let utlStr = userData.profilePicture, let url = URL(string: utlStr) {
                _ = self.avatarImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "avatar_placeholder"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                    
                },completionHandler: { image, error, cacheType, imageURL in
                    
                })
            }
            
            self.emailTextInput.text = userData.email
            
            self.passTextInput.style = AnimatedTextInputStyleBlack()

            self.passTextInput.placeHolderText = "********"
            self.nameTextInput.text = userData.name
            self.nameLabel.text = userData.name
            if let contact = userData.contact {
                self.contactTextInput.text = "\(contact)"
            }
            self.setCountryValueWithCode(code: userData.country ?? "")
            
            if let facebookId = userData.fbId {
                self.facebookTextInput.text = "https://www.facebook.com/" + facebookId
                self.topCountryViewConstraint.constant = 20
                self.passTextInput.isHidden = true
                self.passwordLabel.isHidden = true
                self.passordEditButton.isHidden = true
            } else {
                self.facebookLabel.isHidden = true
                self.socialAccountLabel.isHidden = true
                self.facebookTextInput.isHidden = true
                self.topSignOutConstraint.constant = 400
                
                self.topCountryViewConstraint.constant = 105
                self.passTextInput.isHidden = false
                self.passwordLabel.isHidden = false
                self.passordEditButton.isHidden = false
            }
            
            self.notificationLabel.textColor = (userData.allowNotification ?? false) ? UIColor.black : UIColor.lightGray
            self.someOneTagMeLabel.textColor = (userData.allowTagMe ?? false) ? UIColor.black : UIColor.lightGray
            self.receiveMessLabel.textColor = (userData.receiveMessage ?? false) ? UIColor.black : UIColor.lightGray
            self.notificationSwitch.setOn(userData.allowNotification ?? false, animated: true)
            self.someOneTagMeSwitch.setOn(userData.allowTagMe ?? false, animated: true)
            self.receiveMessSwitch.setOn(userData.receiveMessage ?? false, animated: true)
        } 
    }
    
    fileprivate func setCountryValueWithCode(code: String) {
        if code.isBlank {
            self.countryLabel.text = "Choose your country"
        } else {
            self.selectedCountryCode = code
            self.countryLabel.text = code.countryName
            self.flagImageView.image = UIImage.init(named: code)
        }
    }
    
    //MARK:- Actions

    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func coverButtonTapped(_ sender: UIButton) {
        self.changePicture(button: sender, isCoverPicture: true)
    }
    
    @IBAction func avartaButtonTapped(_ sender: UIButton) {
        self.changePicture(button: sender, isCoverPicture: false)
    }
    
    @IBAction func countryButtonTapped(_ sender: UIButton) {
        let countryVC = TDCountrySelectionViewController.loadFromStoryboard()
        countryVC.delegate = self
        let nav = UINavigationController.init(rootViewController: countryVC)
        self.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func signoutButtonTapped(_ sender: UIButton) {
        self.xt_startNetworkIndicatorView(withMessage: "Logout...")
        API_MANAGER.requestLogout(success: {
            self.xt_stopNetworkIndicatorView()
            TDUser.clear()
            LoginManager().logOut();
            USER_DEFAULT_SET(value: false, key: .isUpdatedeviceToken)
            AppDelegate.current.showLoginScreen()
        }) { (error) in
            self.xt_stopNetworkIndicatorView()
            TDUser.clear()
            LoginManager().logOut();
            USER_DEFAULT_SET(value: false, key: .isUpdatedeviceToken)
            AppDelegate.current.showLoginScreen()
        }
    }
    
    @IBAction func notificationSwitchChanged(_ sender: UISwitch) {
        self.notificationLabel.textColor = sender.isOn ? UIColor.black : UIColor.lightGray
    }
    
    @IBAction func tagMeSwitchChanged(_ sender: UISwitch) {
        self.someOneTagMeLabel.textColor = sender.isOn ? UIColor.black : UIColor.lightGray
    }
    
    @IBAction func receiveamessageSwitchChanged(_ sender: UISwitch) {
        self.receiveMessLabel.textColor = sender.isOn ? UIColor.black : UIColor.lightGray
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        guard let name = self.nameTextInput.text, !name.isBlank else {
            UIAlertController.show(in: self, withTitle: "Reminder", message: "Please enter your name", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            return
        }
        
        guard let contact = self.contactTextInput.text, !contact.isBlank else {
            UIAlertController.show(in: self, withTitle: "Reminder", message: "Please enter your phone number", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            return
        }
        
        guard let countryCode = self.selectedCountryCode, !countryCode.isBlank else {
            UIAlertController.show(in: self, withTitle: "Reminder", message: "Please select your country", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            return
        }
        
        var tempPass: String?
        if let pass = self.passTextInput.text, !pass.isBlank {
            tempPass = pass
        }
        
        self.xt_startNetworkIndicatorView(withMessage: "Updating...")
        API_MANAGER.requestUpdateProfile(email: self.emailTextInput.text, name: name, password: tempPass, passwordComfirmation: tempPass, contact: contact, country: countryCode, fbId: TDUser.currentUser()?.fbId, allowNotification: self.notificationSwitch.isOn, allowTagMe: self.someOneTagMeSwitch.isOn, receiveMessage: self.receiveMessSwitch.isOn, profilePicture: self.avatarImageView.image, coverPicture: self.coverImageView.image, success: { (user) in
            TDUser.save(user)
            self.xt_stopNetworkIndicatorView()
            self.dismiss(animated: true, completion: nil)
        }) { (error) in
            self.xt_stopNetworkIndicatorView()
            UIAlertController.show(in: self, withTitle: "Error", message: error.message, cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        }
    }
    
}

extension TDSettingViewController: TDCountrySelectionViewDelegate {
    func countrySelectionViewDidPickCountryCodes(_ codes: [String]) {

        let code = codes.first!//Unwrapping is safe
        self.setCountryValueWithCode(code: code)
    }
}

extension TDSettingViewController: AnimatedTextInputDelegate{
    func animatedTextInputDidBeginEditing(animatedTextInput: AnimatedTextInput) {
        if animatedTextInput == self.facebookTextInput {
            self.view.endEditing(true)
        } else if (animatedTextInput == self.passTextInput) {
            if let text = animatedTextInput.text {
                if (text.length == 0) {
                    self.passTextInput.placeHolderText = ""
                }
            }
            
        }
    }
    
    
    func animatedTextInputDidEndEditing(animatedTextInput: AnimatedTextInput) {
        if (animatedTextInput == self.passTextInput) {
            if let text = animatedTextInput.text {
                if (text.length == 0) {
                    self.passTextInput.placeHolderText = "********"
                }
            }
        }
    }
    
    func animatedTextInput(animatedTextInput: AnimatedTextInput, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if animatedTextInput == self.contactTextInput{
            
            let invalidCharacters = CharacterSet(charactersIn: "0123456789+").inverted
            guard let text = animatedTextInput.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            if (string.rangeOfCharacter(from: invalidCharacters, options: [], range: string.startIndex ..< string.endIndex) == nil) && (newLength <= 20) {
                return true
            } else {
                return false
            }
        }
        
        let acceptable = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.:@"
        let cs = CharacterSet(charactersIn: acceptable).inverted
        let str = string.components(separatedBy: cs).joined(separator: "")
        
        return string == str;
    }
}

extension TDSettingViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        
        imageView.contentMode = .scaleAspectFill
        imageView.image = chosenImage
        
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, true, 1.0)
        
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let snapshotImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        if self.isCoverPicture {
            self.coverImageView.image = snapshotImage
            self.selectedCoverImage = snapshotImage
        } else {
            self.avatarImageView.image = snapshotImage
            self.selectedAvatarImage = snapshotImage
        }
        
        dismiss(animated:true, completion: nil) //5
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

