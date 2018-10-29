//
//  CustomPhotoAlbum.swift
//  XTrip
//
//  Created by Khoa Bui on 1/12/18.
//  Copyright © 2018 Hoang Cap. All rights reserved.
//

import Foundation
import Photos

class CustomPhotoAlbum {
    
    static let albumName = "TravelX"
    static let sharedInstance = CustomPhotoAlbum()
    
    var assetCollection: PHAssetCollection!
    
    init() {
        
        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            
            if let _: AnyObject = collection.firstObject {
                return collection.firstObject as! PHAssetCollection
            }
            
            return nil
        }
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)
        }) { success, _ in
            if success {
                self.assetCollection = fetchAssetCollectionForAlbum()
            }
        }
    }
    
    func saveImage(image: UIImage) {
        
        if assetCollection == nil {
            return   // If there was an error upstream, skip the save.
        }
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest1 = PHAssetCollectionChangeRequest(for: self.assetCollection)
//            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
//            albumChangeRequest1?.addAssets(<#T##assets: NSFastEnumeration##NSFastEnumeration#>)
            let fastEnumeration = NSArray(array: [assetPlaceholder!] as [PHObjectPlaceholder])
            albumChangeRequest1?.addAssets(fastEnumeration)
        }, completionHandler: nil)
    }
    
    
}
