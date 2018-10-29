//
//  FacebookShareManager.swift
//  Vaster
//
//  Created by Khoa Bui on 7/17/17.
//  Copyright © 2017 Elinext. All rights reserved.
//

import Foundation
import Alamofire
import FacebookShare

let FACEBOOK_MANAGER = FacebookShareManager.sharedInstance

class FacebookShareManager {
    
    // MARK: Shared Instance
    class var sharedInstance: FacebookShareManager {
        struct Singleton {
            static let instance = FacebookShareManager()
        }
        return Singleton.instance
    }
    
    func sharePicture(image: UIImage, hastag: String, viewController: UIViewController) {
        if let fbURL = URL(string:"fb://"),
            UIApplication.shared.canOpenURL(fbURL) == true  {
            let photo: Photo = Photo(image: image, userGenerated: true)
            let hashtag = Hashtag.init("#\(hastag)")
            var content = PhotoShareContent(photos: [photo])
            content.hashtag = hashtag
            self.showShareDialog(content, viewController: viewController)
        } else {
            UIAlertController.show(in: viewController, withTitle: "Error", message: "Please install the facebook application to use the sharing feature", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        }
    }
    
    func shareMultiPicture(images: [UIImage], hastag: String, viewController: UIViewController) {
        if let fbURL = URL(string:"fb://"),
            UIApplication.shared.canOpenURL(fbURL) == true  {
            var photoArray: [Photo] = []
            for image in images {
                let photo: Photo = Photo(image: image, userGenerated: true)
                photoArray.append(photo)
            }
            let hashtag = Hashtag.init("#\(hastag)")
            var content = PhotoShareContent(photos: photoArray)
            content.hashtag = hashtag
            self.showShareDialog(content, viewController: viewController)
        } else {
            UIAlertController.show(in: viewController, withTitle: "Error", message: "Please install the facebook application to use the sharing feature", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        }
    }
    
    fileprivate func showShareDialog<C: ContentProtocol>(_ content: C, mode: ShareDialogMode = .native, viewController: UIViewController) {
        let dialog = ShareDialog(content: content)
        dialog.presentingViewController = viewController
        dialog.mode = mode
        do {
            try dialog.show()
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
}
