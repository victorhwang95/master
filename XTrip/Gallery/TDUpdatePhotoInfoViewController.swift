//
//  TDUpdatePhotoInfoViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 12/10/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import GooglePlaces

protocol UpdatePhotoInfoViewControllerDelegate: class {
    func didUploadSuccess(viewController: TDUpdatePhotoInfoViewController, withPicture updatePic: TDMyPicture)
}

class TDUpdatePhotoInfoViewController: TDBaseViewController {
    
    // MARK:- Properties
    let singlePscope = PermissionScope()
    
    var myTrip: TDTrip?
    var selectedPlace: TDPlace?
    var selectedTypeTab: PlaceType = .hotel
    var tripPictureData: TDMyPicture?
    var tripPictureDataArray: [TDMyPicture] = [TDMyPicture]()
    var googlePlaceData = [String:[String: [TDPlace]]]()
    var placeTypeArray: [PlaceType] = [.hotel, .restaurant, .bar, .museum, .other, .POI]
    var choosePhotoDataArray: [(image: UIImage, location: CLLocationCoordinate2D?, date: Date?)] = [(UIImage, CLLocationCoordinate2D?, Date?)]()
    
    let googlePlaceGroup = DispatchGroup()
    let uploadGroup = DispatchGroup()
    
    weak var delegate: UpdatePhotoInfoViewControllerDelegate?
    
    // Data
    var long: Double = 0.0
    var lat: Double = 0.0
    var prevCell: Int = 0
    var radius: Double = 5000.0
    var keyword: String = ""
    
    var headerViewDict: [Int : HeaderTripView] = [:]
    
    // MARK:- Outlets
    @IBOutlet weak var pagingController: UIPageControl!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var locationVIew: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    
    // MARK:- Public method
    static func newInstance() -> TDUpdatePhotoInfoViewController {
        return UIStoryboard.init(name: "MyPictures", bundle: nil).instantiateViewController(withIdentifier: "TDUpdatePhotoInfoViewController") as! TDUpdatePhotoInfoViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupData()
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = ""
        setupRightButtons(buttonType: .save)
        changeNavigationBarToTransparentStyle()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Private method
    fileprivate func setupView() {
        
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        
        let tripPlaceSelectView = UINib(nibName: "TripPlaceSelectView", bundle: nil)
        self.tableView.register(tripPlaceSelectView, forCellReuseIdentifier: "TripPlaceSelectView")
        
        let tripPlaceSelectFirstView = UINib(nibName: "TripPlaceSelectFirstView", bundle: nil)
        self.tableView.register(tripPlaceSelectFirstView, forCellReuseIdentifier: "TripPlaceSelectFirstView")
        
        let tripPlaceSelectLastView = UINib(nibName: "TripPlaceSelectLastView", bundle: nil)
        self.tableView.register(tripPlaceSelectLastView, forCellReuseIdentifier: "TripPlaceSelectLastView")
        
        APP_PERMISSIONS_MANAGER.checkLocationInUsePermissions(viewController: self, completionHandler: { (isAuthorized) in
            if isAuthorized {
                LOCATION_MANAGER.startLocationService()
                self.loadPlaceListNearMe()
            }
        }, onTapped: nil)
    }
    
    fileprivate func setupData() {
        self.pageController.numberOfPages = self.choosePhotoDataArray.count
        self.pageController.currentPage = 0
        if choosePhotoDataArray.count>0 {
            for choosePhoto in choosePhotoDataArray {
                let myPicture = TDMyPicture()
                myPicture.tripId = 0
                myPicture.caption = ""
                myPicture.isUpload = false
                myPicture.trip = nil
                
                let imageLocation = LocationInfo()
                imageLocation.placeId = self.selectedPlace?.placeId
                imageLocation.name = self.selectedPlace?.name
                imageLocation.typeString = self.selectedTypeTab.description
                imageLocation.long = String(choosePhoto.location?.longitude ?? 0.0 )
                imageLocation.lat = String(choosePhoto.location?.latitude ?? 0.0 )
                
                if let date = choosePhoto.date {
                    myPicture.uploadedAt = date.timeIntervalSince1970;
                } else {
                    myPicture.uploadedAt = Date().timeIntervalSince1970;
                }
                
                log.debug("Photo Lat : \(String(describing: imageLocation.lat)) Long: \(String(describing: imageLocation.long))")
                
                myPicture.imageLocation = imageLocation
                tripPictureDataArray.append(myPicture)
            }
            self.loadPictureDataToView(selectedPicture:0)
        } else {
            // no photo
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    fileprivate func loadPlaceListNearMe() {
        
        // Load google place data near user
        self.long = LOCATION_MANAGER.lastKnownCoordinate!.longitude
        self.lat = LOCATION_MANAGER.lastKnownCoordinate!.latitude
        self.xt_startNetworkIndicatorView(withMessage: "")
        
        var i = 0
        for myPicture in tripPictureDataArray {
            if myPicture.imageLocation == nil {
                let imageLocation = LocationInfo()
                imageLocation.placeId = self.selectedPlace?.placeId
                imageLocation.name = self.selectedPlace?.name
                imageLocation.typeString = self.selectedTypeTab.description
                imageLocation.long = String(self.long)
                imageLocation.lat = String(self.lat)
                myPicture.imageLocation = imageLocation;
            }
            
            if myPicture.imageLocation?.lat==nil || myPicture.imageLocation?.lat == "0.0" || myPicture.imageLocation?.lat == "" {
                myPicture.imageLocation?.lat = String( self.lat )
                myPicture.imageLocation?.long = String( self.long )
            }
            
            for placeType in self.placeTypeArray {
                if !googlePlaceData.keys.contains(String(i)) {
                    googlePlaceData[String(i)] = [String: [TDPlace]]()
                }
                googlePlaceData[String(i)]![placeType.description] = nil;
                
                let Index = i
                self.googlePlaceGroup.enter()
                log.debug("requestGetPlaceInfolistNearMeByLocation Lat : \(myPicture.imageLocation?.lat ?? String(self.lat)) Long: \(myPicture.imageLocation?.long ?? String(self.long))")
                API_MANAGER.requestGetPlaceInfolistNearMeByLocation(longitude: Double( myPicture.imageLocation?.long ?? String(self.long) )!, latitude: Double( myPicture.imageLocation?.lat ?? String(self.lat) )!, radius: self.radius , type: placeType, success: {[weak self] (places, placeType) in
                    if let weakSelf = self {
                        weakSelf.googlePlaceGroup.leave()
                        weakSelf.googlePlaceData[String(Index)]![placeType.description] = places
                    }
                }) { [weak self](error) in
                    if let weakSelf = self {
                        weakSelf.googlePlaceGroup.leave()
                    }
                }
            }
            i = i + 1;
        }
        
        self.googlePlaceGroup.notify(queue: DispatchQueue.main) {
            // Refesh data on UI
            self.xt_stopNetworkIndicatorView()
            self.tableView.reloadData()
        }
    }
    
    fileprivate func loadPictureDataToView(selectedPicture: Int) {
        self.tripPictureData = tripPictureDataArray[selectedPicture]
        self.captionTextField.text = self.tripPictureData?.caption
        self.selectedTypeTab = self.tripPictureData?.imageLocation?.type ?? .hotel
        self.tripNameLabel.text = self.tripPictureData?.trip?.name ?? self.tripNameLabel.text
        self.long = Double(self.tripPictureData?.imageLocation?.long ?? "0.0")!
        self.lat = Double(self.tripPictureData?.imageLocation?.lat ?? "0.0")!
        if self.tripPictureData?.imageLocation != nil && tripPictureData?.imageLocation?.name != "" {
            self.selectedPlace = TDPlace.init(name: self.tripPictureData?.imageLocation?.name ?? "", type: self.tripPictureData?.imageLocation?.type ?? .hotel, placeId: self.tripPictureData?.imageLocation?.placeId ?? "", lat: self.lat, lng: self.long)
        } else {
            self.selectedPlace = nil;
        }
        
        // if no placeid but got locationname then write to keyword
        self.keyword = "";
        if ( self.selectedPlace?.placeId == nil || self.selectedPlace?.placeId == "" ) && ( self.selectedPlace?.name != nil && self.selectedPlace?.name != "" ) {
            self.keyword = (self.selectedPlace?.name)!
        }
    }
    
    fileprivate func writePictureDataFromView() {
        let imageLocation = LocationInfo()
        imageLocation.placeId = self.selectedPlace?.placeId
        imageLocation.name = self.selectedPlace?.name
        if self.keyword != "" {
            imageLocation.name = self.keyword
            imageLocation.placeId = ""
        }
        imageLocation.typeString = self.selectedTypeTab.description
        if self.selectedPlace != nil && ((self.selectedPlace?.location) != nil) {
            imageLocation.long = String(self.selectedPlace?.location.coordinate.longitude ?? self.long)
            imageLocation.lat = String(self.selectedPlace?.location.coordinate.latitude ?? self.lat)
        } else {
            imageLocation.long = String(self.long)
            imageLocation.lat = String(self.lat)
        }
        if imageLocation.lat == "" || imageLocation.lat == "0.0" {
            imageLocation.lat = String(describing: LOCATION_MANAGER.lastKnownCoordinate?.latitude)
            imageLocation.long = String(describing: LOCATION_MANAGER.lastKnownCoordinate?.longitude)
        }
        let myPicture = tripPictureDataArray[prevCell]
        myPicture.tripId = self.myTrip?.tripId
        myPicture.trip = self.myTrip
        myPicture.caption = self.captionTextField.text
        myPicture.isUpload = false
        myPicture.imageLocation = imageLocation
    }
    
    override func saveButtonTapped() {
        
        if self.myTrip?.tripId == nil {
            UIAlertController.show(in: self, withTitle: "Reminder", message: "Please choose your trip", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            return
        }
        self.writePictureDataFromView()
        // check all info in tripPictureDataArray
        var i = 0
        for myPicture in tripPictureDataArray {
            if myPicture.imageLocation == nil || myPicture.imageLocation?.name == nil || myPicture.imageLocation?.name == "" {
                UIAlertController.show(in: self, withTitle: "Reminder", message: "Please choose place for Picture " + String(i+1), cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
                return
            }
            
            i = i + 1
        }
        self.handleUploadMultiplePicture()
    }
    
    fileprivate func cleaningPictureData() {
        var i = 0
        for myPicture in tripPictureDataArray {
            if ( myPicture.imageLocation?.placeId == nil || myPicture.imageLocation?.placeId == "" ) && ( myPicture.imageLocation?.name != nil && myPicture.imageLocation?.name != "" ) {
                // free text location name, use photo location or empty location
                if self.choosePhotoDataArray[i].location == nil {
                    myPicture.imageLocation?.lat = ""
                    myPicture.imageLocation?.long = ""
                }
                log.debug("photo \(i) lat: \(String(describing: myPicture.imageLocation?.lat)) long \(String(describing: myPicture.imageLocation?.long))")
            }
            i = i + 1
        }
    }
    
    fileprivate func handleUploadMultiplePicture() {
        if CONNECTION_MANAGER.isNetworkAvailable(willShowAlertView: false) {
            self.cleaningPictureData()
            print("got internet.")
            var index = 0
            self.xt_startNetworkIndicatorView(withMessage: "Uploading...")

            for myPicture in self.tripPictureDataArray {
                
                let uploadAtDate = Date.init(timeIntervalSince1970: myPicture.uploadedAt!);//Unwrapping is safe because the value of myPicture.uploadedAt is already set inside setupdate
                
                let i = index
                if myPicture.imageLocation?.lat != nil && myPicture.imageLocation?.lat != "" && myPicture.imageLocation?.lat != "0.0" {
                    log.debug("with lat long")
                    self.uploadGroup.enter()

                    //TRICK CODE: Deceive GMSGeocoder to use English response by changing value of AppleLanguages to "en_US"
                    
                    //1. Store the original value of AppleLanguages
                    let currentLanguage = UserDefaults.standard.stringArray(forKey: "AppleLanguages")
                    
                    //2. Set "AppleLanguages" to "en_US" before performing geocoder
                    UserDefaults.standard.set(["en_US"], forKey: "AppleLanguages")

                    GMSGeocoder().reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: Double(myPicture.imageLocation?.lat ?? "0.0")!, longitude: Double(myPicture.imageLocation?.long ?? "0.0")!)) { response, error in
                        
                        //3. put "AppleLanguages" back to its original value
                        UserDefaults.standard.set(currentLanguage, forKey: "AppleLanguages")
                        
                        let Index = i
                        if let addressObj = response?.firstResult() {
                            var cityName = addressObj.locality ?? ""
                            var administrativeArea = addressObj.administrativeArea ?? ""
                            let countryName = addressObj.country ?? ""
                            
                            // 3 particular cases have a country name like city name
                            if countryName == "Singapore" {
                                cityName = "Singapore"
                                administrativeArea = "Singapore"
                            }
                            
                            if countryName == "Monaco" {
                                cityName = "Monaco"
                                administrativeArea = "Monaco"
                            }
                            
                            if countryName == "Vatican" {
                                cityName = "Vatican"
                                administrativeArea = "Vatican"
                            }
                            
                            // "" value mean Unknown , because server want client pass "" to param
                            let validCityName = countryName.isBlank ? "" : (administrativeArea.isBlank ? cityName : administrativeArea)
                            let validCountryName = validCityName.isBlank ? "" : countryName
                            
                            // Firebase analytics
                            FIR_MANAGER.sendAppEvent(withEvent: FIREvent.UPLOAD_PIC_FUNCTION.rawValue, userId: nil)
                            
                            API_MANAGER.requestUploadTripImages(tripId: (self.myTrip?.tripId)!, country: "", city: validCityName, longitude: Double( myPicture.imageLocation?.long ?? String(LOCATION_MANAGER.lastKnownCoordinate?.longitude ?? 0.0))!, latitude: Double( myPicture.imageLocation?.lat ?? String(LOCATION_MANAGER.lastKnownCoordinate?.latitude ?? 0.0))!, createdDate: uploadAtDate, caption: myPicture.caption, itemType: (myPicture.imageLocation?.typeString)!, itemId: (myPicture.imageLocation?.placeId)!, itemName: (myPicture.imageLocation?.name)!, selectedImage: self.choosePhotoDataArray[Index].image, countryName: validCountryName, success: { () in
                                self.uploadGroup.leave()
                                log.debug("with lat long : success")
                            }) { (error) in
                                log.debug(myPicture.imageLocation)
                                self.savePictureToLocalDatabase(photoIndex: Index)
                                self.uploadGroup.leave()
                                log.debug("with lat long : failed")
                            }
                        } else {
                            self.xt_stopNetworkIndicatorView()
                            self.navigationController?.popToRootViewController(animated: false)
                            // Push notification center to enter my trip page
                            NotificationCenter.default.post(name: NotificationName.didUploadPictureSuccess, object: nil, userInfo: nil)
                        }
                    }
                } else {
                    log.debug("no lat long")
                    // upload photo without location but with freetext location name.
                    let cityName = ""
                    let countryCode = ""
                    let Index = i
                    self.uploadGroup.enter()
                    API_MANAGER.requestUploadTripImages(tripId: (self.myTrip?.tripId)!, country: countryCode, city: cityName, longitude: 0.0, latitude: 0.0, createdDate:uploadAtDate, caption: myPicture.caption, itemType: (myPicture.imageLocation?.typeString)!, itemId: (myPicture.imageLocation?.placeId)!, itemName: (myPicture.imageLocation?.name)!, selectedImage: self.choosePhotoDataArray[Index].image, countryName: "", success: { () in
                        self.uploadGroup.leave()
                        log.debug("with lat long : success")
                    }) { (error) in
                        log.debug(myPicture.imageLocation)
                        self.savePictureToLocalDatabase(photoIndex: Index)
                        self.uploadGroup.leave()
                        log.debug("with lat long : failed")
                    }
                }
                index = index + 1
            }
            
            self.uploadGroup.notify(queue: DispatchQueue.main) {
                self.xt_stopNetworkIndicatorView()
                self.navigationController?.popToRootViewController(animated: false)
                // Push notification center to enter my trip page
                NotificationCenter.default.post(name: NotificationName.didUploadPictureSuccess, object: nil, userInfo: nil)
            }
            
        } else {
            self.cleaningPictureData()
            for i in 0...self.tripPictureDataArray.count-1 {
                self.savePictureToLocalDatabase(photoIndex: i)
            }
            
            self.xt_stopNetworkIndicatorView()
            self.navigationController?.popToRootViewController(animated: false)
            // Push notification center to enter my trip page
            NotificationCenter.default.post(name: NotificationName.didUploadPictureSuccess, object: nil, userInfo: nil)
            UIAlertController.show(in: self, withTitle: "No internet connection", message: "The picture was saved to the My Picture tab, please update it when the internet connection back again", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        }
    }
    
    fileprivate func savePictureToLocalDatabase(photoIndex: Int) {
        let myPicture = tripPictureDataArray[photoIndex]
        let imageData = choosePhotoDataArray[photoIndex]
        myPicture.imageUrl = Ultilities.saveImageDocumentDirectory(imageData.image)
        TDMyPicture.addMyPicture(myPicture)
    }
    
    // MARK:- Actions
    
    @IBAction func vacationButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = MYPICTURES_STORYBOARD.instantiateViewController(withIdentifier: "TDMyTripViewController") as! TDMyTripViewController
        vc.delegate = self
        vc.isFriendTrip = false
        self.present(vc, animated: true, completion: nil)
//        UIAlertController.showActionSheet(in: self, withTitle: title, message: nil, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: ["Select from my trip", "Select from my friends' trip"], popoverPresentationControllerBlock: { (popOver) in
//
//            popOver.sourceView = sender
//
//        }) { (controller, index) in
//            if (index == 3) {
//                vc.isFriendTrip = true
//                self.isUploadToFriendTrip = true
//                self.present(vc, animated: true, completion: nil)
//            } else if (index == 2) {
//                vc.isFriendTrip = false
//                self.isUploadToFriendTrip = false
//                self.present(vc, animated: true, completion: nil)
//            }
//        }
    }
}

extension TDUpdatePhotoInfoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedPlace = self.googlePlaceData[String(self.pageController.currentPage)]![self.selectedTypeTab.description]?[indexPath.row]
        //        // replace all empty location to this locatioin
        //        self.replaceEmptyPictureData()
        self.keyword = ""
        self.tableView.reloadData()
    }
}

extension TDUpdatePhotoInfoViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let placeData = self.googlePlaceData[String(self.pageController.currentPage)] {
            return placeData[self.selectedTypeTab.description]?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cell = self.headerViewDict[section] {
            cell.tabBarOffsetConstraint.constant = 60
            cell.delegate = self
            cell.customTextDelegate = self
            if let placeData = self.googlePlaceData[String(self.pageController.currentPage)] {
                cell.setData(tripCity: nil, googlePlaceData: placeData, tabPosition: self.selectedTypeTab)
            }
            cell.setCustomText(keyword: self.keyword)
            
            return cell
        } else {
            let cell = HeaderTripView.viewFromNib() as! HeaderTripView
            self.headerViewDict[section] = cell
            cell.tabBarOffsetConstraint.constant = 60
            cell.delegate = self
            cell.customTextDelegate = self
            if let placeData = self.googlePlaceData[String(self.pageController.currentPage)] {
                cell.setData(tripCity: nil, googlePlaceData: placeData, tabPosition: self.selectedTypeTab)
            }
            cell.setCustomText(keyword: self.keyword)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TripPlaceSelectFirstView", for: indexPath) as! TripPlaceSelectView
            let placeData = self.googlePlaceData[String(self.pageController.currentPage)]![self.selectedTypeTab.description]?[indexPath.row]
            cell.setData(googlePlaceData: placeData, selectedPlace: self.selectedPlace)
            return cell
            
        case self.tableView(tableView, numberOfRowsInSection: 0) - 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TripPlaceSelectLastView", for: indexPath) as! TripPlaceSelectView
            let placeData = self.googlePlaceData[String(self.pageController.currentPage)]![self.selectedTypeTab.description]?[indexPath.row]
            cell.setData(googlePlaceData: placeData, selectedPlace: self.selectedPlace)
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TripPlaceSelectView", for: indexPath) as! TripPlaceSelectView
            let placeData = self.googlePlaceData[String(self.pageController.currentPage)]![self.selectedTypeTab.description]?[indexPath.row]
            cell.setData(googlePlaceData: placeData, selectedPlace: self.selectedPlace)
            return cell
        }
    }
}

extension TDUpdatePhotoInfoViewController: HeaderTripViewDelegate {
    
    func didTapButtonToChannelTypePlace(placeType: PlaceType, atSection: Int) {
        self.selectedTypeTab = placeType
        self.tableView.reloadData()
    }
}

extension TDUpdatePhotoInfoViewController: HeaderTripViewCustomLocationDelegate {
    
    func didWriteCustomLocation(name: String) {
        if self.keyword == name {
            return
        }
        
        self.keyword = name;
        if name == "" {
            self.xt_startNetworkIndicatorView(withMessage: "Searching Nearby Locations ...")
            for placeType in self.placeTypeArray {
                self.googlePlaceGroup.enter()
                API_MANAGER.requestGetPlaceInfolistNearMeByLocation(longitude: self.long, latitude: self.lat, radius: self.radius , type: placeType, success: {[weak self] (places, placeType) in
                    if let weakSelf = self {
                        weakSelf.googlePlaceGroup.leave()
                        weakSelf.googlePlaceData[String(weakSelf.pageController.currentPage)]![placeType.description] = places
                    }
                }) { [weak self](error) in
                    if let weakSelf = self {
                        weakSelf.googlePlaceGroup.leave()
                    }
                }
            }
            self.googlePlaceGroup.notify(queue: DispatchQueue.main) {
                self.xt_stopNetworkIndicatorView()
                self.tableView.reloadData()
            }
        } else {
            // search the location with the name , within location in metadata or cur location
            let myPicture = tripPictureDataArray[self.pageController.currentPage]
            if myPicture.imageLocation != nil {
                
                self.xt_startNetworkIndicatorView(withMessage: "Searching ...")
                for placeType in self.placeTypeArray {
                    self.googlePlaceGroup.enter()
                    API_MANAGER.requestSearchPlaceInfoByName(longitude: Double( myPicture.imageLocation?.long ?? String(self.long) )!, latitude: Double( myPicture.imageLocation?.lat ?? String(self.lat) )!, radius: self.radius , type: placeType , keyword: name, success: {[weak self] (places, placeType) in
                        if let weakSelf = self {
                            weakSelf.googlePlaceGroup.leave()
                            if places.count>0 {
                                weakSelf.googlePlaceData[String(weakSelf.pageController.currentPage)]![placeType.description] = places
                            } else {
                                weakSelf.googlePlaceData[String(weakSelf.pageController.currentPage)]![placeType.description] = [TDPlace]()
                            }
                        }
                    }) { [weak self](error) in
                        if let weakSelf = self {
                            weakSelf.googlePlaceGroup.leave()
                        }
                    }
                }
                self.googlePlaceGroup.notify(queue: DispatchQueue.main) {
                    self.xt_stopNetworkIndicatorView()
                    self.tableView.reloadData()
                }
                
            } else {
            }
        }
    }
}

extension TDUpdatePhotoInfoViewController: TDMyTripViewDelegate {
    
    func didSelectedCreateNewTrip(viewController vc: TDMyTripViewController) {
        
        let myPicture = tripPictureDataArray[prevCell];
        
        let takenDate = Date.init(timeIntervalSince1970:myPicture.uploadedAt!);//Unwrapping is safe because all objects in tripPictureDataArray has their uploadedAt assigned in setupData()
        
        let createTripVC = TDCreateTripViewController.newInstance()
        
        createTripVC.enterFromDashBoard = false
        createTripVC.delegate = self
        createTripVC.startDate = takenDate;
        self.navigationController?.pushViewController(createTripVC, animated: true)
    }
    
    func didSelectedTrip(viewController vc: TDMyTripViewController, withTrip trip: TDTrip) {
        self.tripNameLabel.text = trip.name ?? ""
        self.myTrip = trip
    }
    
}

extension TDUpdatePhotoInfoViewController: UICollectionViewDataSource , UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.choosePhotoDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! UploadImageCollectionViewCell
        let image = self.choosePhotoDataArray[indexPath.item].image
        cell.setData(image: image, editImageUrl: nil, updateImageUrl: nil)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.size.width, height: self.collectionView.size.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !scrollView.isKind(of: UICollectionView.self) {
            return
        }
        if collectionView.indexPathsForVisibleItems.count>1 {
            perform(#selector(scrollViewDidEndDecelerating), with: scrollView, afterDelay: 0.3)
            return
        }
        
        // write data to prevCell
        self.writePictureDataFromView()
        
        // update view base on cur picture
        self.keyword = ""
        let selectedPicture = collectionView.indexPathsForVisibleItems.first?.row ?? 0
        self.loadPictureDataToView(selectedPicture: selectedPicture)
        
        prevCell = selectedPicture
        
        let pageWidth = collectionView.frame.size.width
        let currentPage = collectionView.contentOffset.x / pageWidth
        
        if (0.0 != fmodf(Float(currentPage), 1.0)) {
            self.pageController.currentPage = Int(currentPage + 1)
        } else {
            self.pageController.currentPage = Int(currentPage);
        }
        self.tableView.reloadData()
    }
}

extension TDUpdatePhotoInfoViewController: CreateTripViewControllerDelegate {
    func didCreateTripSuccess(viewController: TDCreateTripViewController, tripData trip: TDTrip) {
        self.tripNameLabel.text = trip.name ?? ""
        self.myTrip = trip
    }
}

extension UIViewController {
    func getCountryCodeByCountryName(countryName: String) -> String? {
        
        let countryCodes = NSLocale.isoCountryCodes
        var countries = [String]()
        
        for countryCode in countryCodes {
            let identifier = NSLocale.localeIdentifier(fromComponents: [countryCode: NSLocale.Key.countryCode.rawValue])
            let country = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: identifier)
            if let unwarpCountry = country {
                countries.append(unwarpCountry)
            }
        }
        let codeForCountryDictionary:NSDictionary = NSDictionary(objects: countryCodes, forKeys: countries as [NSCopying])
        if let countryCode = codeForCountryDictionary.object(forKey: countryName) as? String {
            return countryCode
        }
        return nil
    }
}
