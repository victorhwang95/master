//
//  TDGalleryViewController.swift
//  XTrip
//
//  Created by Khoa Bui on 12/9/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import Photos
import DZNEmptyDataSet
import MJRefresh

class TDGalleryViewController: TDBaseViewController {

    // MARK:- Public method
    static func newInstance() -> TDGalleryViewController {
        return UIStoryboard.init(name: "MyPictures", bundle: nil).instantiateViewController(withIdentifier: "TDGalleryViewController") as! TDGalleryViewController
    }
    
     // MARK:- Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK:- Properties
    var selectedAsset = [PHAsset]();
    
    var thumbDictionary = [String: (image: UIImage, error: Bool)]()//Cached dictionary for cell thumbnails
    var cachedAssetIndex = [Int]()//List of indexes to keep track of which cell was cached. If the list gets to big, we will remove the older thumbnails to prevent memory spike
    
    var performedRequestIds = [PHImageRequestID]();//List of image request. This is used to keep track of asset thumbnail request, if the list gets big, we will cancel the older request, making resource for newer requests

    let requestGalleryGroup = DispatchGroup()
    let header = MJRefreshNormalHeader()
    
    let option = PHImageRequestOptions()
    fileprivate lazy var photos = TDGalleryViewController.loadPhotos()
    fileprivate lazy var imageManager = PHCachingImageManager.default()
    
    fileprivate lazy var thumbnailSize: CGSize = {
        let cellSize = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        return CGSize(width: 180,
                      height: 180)
    }()
    
    static func loadPhotos() -> [PHAsset] {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.includeHiddenAssets = false;
        
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        var result = [PHAsset]();
        
        let assets = PHAsset.fetchAssets(with: allPhotosOptions);
        
        for i in 0 ..< assets.count {
            let asset = assets.object(at: i);
            if (asset.sourceType == .typeUserLibrary) {
                result.append(asset);
            }
        }
        
        return result;
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        print(self.thumbnailSize);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Upload Picture"
        setupRightButtons(buttonType: .setting)
            self.photos = TDGalleryViewController.loadPhotos()
        self.collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Private method
    fileprivate func setupView() {
        
        APP_PERMISSIONS_MANAGER.checkPhotoPermissions(viewController: self, completionHandler: {(isAuth) -> () in
            
        }, onTapped: {(isTap) -> () in
            self.photos = TDGalleryViewController.loadPhotos()
            self.collectionView.reloadData()
        })
        
        // Set refreshing with target
        self.header.setRefreshingTarget(self, refreshingAction: #selector(self.refreshData))
        // add header to table view
        self.collectionView.mj_header = self.header
        
        self.refreshData()
    }
    
    @objc fileprivate func refreshData() {
        self.collectionView.mj_header.endRefreshing()
        APP_PERMISSIONS_MANAGER.checkPhotoPermissions(viewController: self, completionHandler: { (isAuthorized) in
            self.photos = TDGalleryViewController.loadPhotos()
            self.collectionView.reloadData()
        }) { (onTapped) in
            self.photos = TDGalleryViewController.loadPhotos()
            self.collectionView.reloadData()
        }
    }

    // MARK:- Actions
    @IBAction func selectAllImageButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func uploadButtonTapped(_ sender: UIButton) {        
        if self.selectedAsset.count != 0 {
            let vc = TDUpdatePhotoInfoViewController.newInstance()
            var loadingPhotoDataArray: [(UIImage, CLLocationCoordinate2D?, Date?)] = [(UIImage, CLLocationCoordinate2D?, Date?)]()
            for asset in self.selectedAsset {
                
                self.requestGalleryGroup.enter()
                // Get photo location
                let imageLocation = asset.location?.coordinate
                
                let imageDate = asset.creationDate;
                
                // Create request to get photo
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                requestOptions.resizeMode = .none
                requestOptions.deliveryMode = .highQualityFormat
                requestOptions.isNetworkAccessAllowed = true
                imageManager.requestImage(for: asset, targetSize: view.frame.size, contentMode: .aspectFill, options: requestOptions, resultHandler: { [weak self] image, info in
                    if let weakSelf = self {
                        guard let image = image, let info = info else { return }
                        loadingPhotoDataArray.append((image, imageLocation, imageDate))
                        weakSelf.requestGalleryGroup.leave()
                    }
                })
            }
            
            self.requestGalleryGroup.notify(queue: DispatchQueue.main) {
                vc.choosePhotoDataArray = loadingPhotoDataArray
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            UIAlertController.show(in: self, withTitle: "Reminder", message: "Please select a picture", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
        }
    }
}

private let MAXIMUM_CACHES = 100;

extension TDGalleryViewController: UICollectionViewDataSource , UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let asset = photos[indexPath.item];
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCollectionViewCell
        
        if let cache = self.thumbDictionary[asset.localIdentifier] {
            cell.galleryImageView.image = cache.image;
            if (self.selectedAsset.contains(asset)) {
                cell.selectButton.isSelected = true;
            } else {
                cell.selectButton.isSelected = false;
            }
            
        } else {
            //Set generic icon first
            cell.galleryImageView.image = #imageLiteral(resourceName: "sampleImage");
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = false
//
//            requestOptions.isNetworkAccessAllowed = false;
            
            let id = imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { [unowned self] image, dict in
                
                let assetIdentifier = asset.localIdentifier;
                
                if let image = image {
                    self.thumbDictionary[assetIdentifier] = (image, false);
                } else {
                    self.thumbDictionary[assetIdentifier] = (#imageLiteral(resourceName: "errorImage"), true);
                }

                self.cachedAssetIndex.append(indexPath.row);
                
                //After thumbnail is loaded, we will check the number of cached thumbnails, if it gets big -> Remove the old ones
                if (self.cachedAssetIndex.count > MAXIMUM_CACHES) {
                    let removedIndex = self.cachedAssetIndex.removeFirst();//The index of the first (oldest) cache
                    let removedCachedId = self.photos[removedIndex].localIdentifier;//Get the id of the cached asset based on the index
                    self.thumbDictionary.removeValue(forKey: removedCachedId);//Remove the cached thumbnail of the asset
                }

                if let requestingCell = collectionView.cellForItem(at: indexPath) as? GalleryCollectionViewCell {
                    if (self.selectedAsset.contains(asset)) {
                        requestingCell.selectButton.isSelected = true;
                    } else {
                        requestingCell.selectButton.isSelected = false;
                    }
                    requestingCell.galleryImageView.image = self.thumbDictionary[assetIdentifier]?.image;
                };
            })
            
            //Each time we perform a request, append it to the list
            self.performedRequestIds.append(id);
            
            //If the list gets big -> Cancel the old ones
            if (self.performedRequestIds.count > MAXIMUM_CACHES) {
                let removedRequestId = self.performedRequestIds.removeFirst();
                self.imageManager.cancelImageRequest(removedRequestId);
            }
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = photos[indexPath.item];
        
        //Handle the special corner case when the asset's image cannot be loaded due to iOS error
        if let cache = self.thumbDictionary[asset.localIdentifier], cache.error {
            UIAlertController.show(in: self, withTitle: "Error", message: "This picture can not be loaded, please select another one", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            return;
        }
        
        if (self.selectedAsset.contains(asset)) {
            self.selectedAsset.remove(asset);
        } else {
            if self.selectedAsset.count > 9 {
                UIAlertController.show(in: self, withTitle: "Reminder", message: "You can only select up to 10 pictures", cancelButtonTitle: "OK", otherButtonTitles: nil, tap: nil)
            } else {
                self.selectedAsset.append(asset)
            }
        }
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = SCREEN_SIZE.width/4
        return CGSize(width: width, height: width)
    }
}

extension TDGalleryViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Opps!", attributes: nil)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No photos to show", attributes: nil)
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
        return #imageLiteral(resourceName: "refesh")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        button.rotateButton(animationDuration: 1, inSecond: 10)
        self.photos = TDGalleryViewController.loadPhotos()
        self.collectionView.reloadData()
    }
}
