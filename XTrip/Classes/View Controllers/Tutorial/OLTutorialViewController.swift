//
//  OLTutorialViewController.swift
//  Opla-User
//
//  Created by Hoang Cap on 8/6/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation

class OLTutorialViewController: UIViewController {
    
    // MARK:- Public method
    static func newInstance() -> OLTutorialViewController {
        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OLTutorialViewController") as! OLTutorialViewController
    }

//    @IBOutlet weak var pageControl: OLRectanglePageView!
//    @IBOutlet weak var pageControl: UIPageControl!
    
    
    @IBOutlet weak var pageControl: TDPageControl!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var startButton: UIButton!
    
    let tutorialImages:[UIImage] = [#imageLiteral(resourceName: "img_launchImage"), #imageLiteral(resourceName: "img_launchImage"), #imageLiteral(resourceName: "img_launchImage")];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.pageControl.numberOfPages = self.tutorialImages.count;
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        let registerVC = TDRegisterViewController.loadFromStoryboard();
        let nav = UINavigationController.init(rootViewController: registerVC);
        nav.setNavigationBarHidden(true, animated: false);
        AppDelegate.current.setRootViewController(nav);
    }
}

extension OLTutorialViewController:UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OLTutorialViewCell", for: indexPath) as! OLTutorialViewCell;
        
        
        cell.imageView.image = tutorialImages[indexPath.row];
        
        
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tutorialImages.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.view.size;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0;
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.width;
        
        let x = scrollView.contentOffset.x;
        
        let ratio = x / width;
        
        let index = Int(floor(ratio + 0.5));
        
        self.pageControl.currentPage = index;
    }

}
