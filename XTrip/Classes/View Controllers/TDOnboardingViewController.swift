//
//  TDOnboardingViewController.swift
//  travelDiary
//
//  Created by Hoang Cap on 8/3/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation

class TDOnboardingViewController:UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    
    override func viewDidLoad() {
        self.pageControl.numberOfPages = 3;
        self.pageControl.currentPage = 0;
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if let indexPath = self.collectionView.indexPathsForVisibleItems.first {
            let row = indexPath.row;
            if (row < pageControl.numberOfPages - 1) {
                let newIndexPath = IndexPath(item: row + 1, section: 0);
                self.collectionView.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true);
            }
            
            
        }
    }
    
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        log.info("Skip tapped");
    }
}

extension TDOnboardingViewController:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TDOnboardingCollectionViewCell", for: indexPath);
        
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.width, height: collectionView.height);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0;
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.width;
        
        let x = scrollView.contentOffset.x;
        
        let ratio = x / width;
        
        let index = Int(floor(ratio + 0.5));
        
        self.pageControl.currentPage = index;
        
        if (self.pageControl.isAtLastPage) {
            self.nextButton.setTitle("Finish", for: .normal);
        } else {
            self.nextButton.setTitle("Next", for: .normal);
        }
        
    }
}

