//
//  StampManager.swift
//  XTrip
//
//  Created by Khoa Bui on 2/11/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import Foundation
import Photos
import CoreLocation

let STAMP_MANAGER = StampManager.sharedInstance

protocol StampManagerDelegate: class {
    func didGetValidStamp(withValidStampArray validStampArray: [ValidStamp])
}

class ValidStamp {
    var location: CLLocationCoordinate2D!
    var createDate: Date!
    var countryCode: String?
    var name: String?
    
    init(location: CLLocationCoordinate2D, createDate: Date, countryCode: String?, name: String?) {
        self.location = location
        self.createDate = createDate
        self.countryCode = countryCode
        self.name = name
    }
}

class StampManager {
    
    fileprivate var validStampArray:[ValidStamp] = []
    fileprivate var maxValidStamp = 10
    
//    let option = PHImageRequestOptions()
    fileprivate lazy var photos = TDGalleryViewController.loadPhotos()
    fileprivate lazy var imageManager = PHCachingImageManager()
    weak fileprivate var validStampDelegate : StampManagerDelegate?
    
    fileprivate lazy var thumbnailSize: CGSize = {
        return CGSize(width: 5, height: 5)
    }()
    
    // MARK: Shared Instance
    class var sharedInstance: StampManager {
        struct Singleton {
            static let instance = StampManager()
        }
        return Singleton.instance
    }
    
    func setTripStatusDelegate(_ delegate: StampManagerDelegate?) {
        self.validStampDelegate = delegate
    }
    
    func getValidStampBaseOnDevicePhoto() {
        //Remove all previous fetched stamps if any.
        self.validStampArray.removeAll()
        for var index in 0 ..< self.photos.count {
            print("\(index)");
            let requestOptions = PHImageRequestOptions();
            requestOptions.isSynchronous = true;
            let asset = self.photos[index]
            self.imageManager.requestImage(for: asset, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { image, dict in
                if let imageLocation = asset.location?.coordinate,
                let imageDate = asset.creationDate {
                    if self.validStampArray.count == 0 { // Check if valid stamp array in empty, just add the first emlement
                        self.validStampArray.append(ValidStamp(location: imageLocation, createDate: imageDate, countryCode: nil, name: nil))
                    } else { // Check location distance , if > 10km
                        let theLastValidImageLocation = self.validStampArray.last!.location! //Unwrapping is safe because the validArray is already has value
                        let lastLocation = CLLocation(latitude: theLastValidImageLocation.latitude, longitude: theLastValidImageLocation.longitude)
                        let location = CLLocation(latitude: imageLocation.latitude, longitude: imageLocation.longitude)
                        let distance = lastLocation.distance(from: location)
                        if distance >= 10000 {
                            self.validStampArray.append(ValidStamp(location: imageLocation, createDate: imageDate, countryCode: nil, name: nil))
                            if self.validStampArray.count == 10 {
                                self.validStampDelegate?.didGetValidStamp(withValidStampArray: self.validStampArray)
                                self.validStampDelegate = nil;//Release the delegate, so that when the for loop ends, the delegate will not be called one more time
                                index = self.photos.count;//Change the value of index to stop for loop
                                return;
                            }
                        }
                    }
                }
            });
        }
        
        //After finishing the for loop -> Call the delegate method
        self.validStampDelegate?.didGetValidStamp(withValidStampArray: self.validStampArray);
        
//        if self.indexStamp < self.photos.count {
//            let requestOptions = PHImageRequestOptions()
//            requestOptions.isSynchronous = false
//            let asset = self.photos.object(at: indexStamp)
//            self.imageManager.requestImage(for: asset, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { image, dict in
//                if let imageLocation = asset.location?.coordinate,
//                    let imageDate = asset.creationDate {
//                    if self.validStampArray.count == 0 { // Check if valid stamp array in empty, just add the first emlement
//                        self.validStampArray.append(ValidStamp(location: imageLocation, createDate: imageDate, countryCode: nil, name: nil))
//                        self.releaseFilterProcess()
//                    } else { // Check location distance , if > 10m
//                        let theLastValidImageLocation = self.validStampArray.last!.location! //Unwrapping is safe because the validArray is already has value
//                        let lastLocation = CLLocation(latitude: theLastValidImageLocation.latitude, longitude: theLastValidImageLocation.longitude)
//                        let location = CLLocation(latitude: imageLocation.latitude, longitude: imageLocation.longitude)
//                        let distance = lastLocation.distance(from: location)
//                        if distance >= 100000 {
//                            if self.validStampArray.count < 10 {
//                                self.validStampArray.append(ValidStamp(location: imageLocation, createDate: imageDate, countryCode: nil, name: nil))
//                                self.releaseFilterProcess()
//                            } else {
//                                self.releaseFilterProcess()
//                            }
//                        } else {
//                            self.releaseFilterProcess()
//                        }
//                    }
//                } else {
//                    self.releaseFilterProcess()
//                }
//            })
//        } else {
//            self.validStampDelegate?.didGetValidStamp(withValidStampArray: self.validStampArray)
//        }
    }
    
//    fileprivate func releaseFilterProcess() {
//        if self.indexStamp <= self.photos.count - 1 {
//            self.indexStamp += 1
//            self.getValidStampBaseOnDevicePhoto()
//        } else {
//            self.validStampDelegate?.didGetValidStamp(withValidStampArray: self.validStampArray)
//        }
//    }
    
}
