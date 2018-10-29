//
//  UIViewController+StoryboardLoader.swift
//  Opla-User
//
//  Created by Hoang Cap on 10/5/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import Foundation
import ObjectMapper

extension UIViewController {
    
    func getCountryListFromJsonFile() -> [TDLocalCountry] {
        let file = Bundle.main.url(forResource: "Countries", withExtension: "json")!;
        let data = try! Data(contentsOf: file);
        let json = try! JSONSerialization.jsonObject(with: data, options: []);
        let object = json as! [[String: Any]]
        var localCountryArray: [TDLocalCountry] = []
        let countryArray = Mapper<TDLocalCountry>().mapArray(JSONArray: object)
        if countryArray.count > 0 {
            localCountryArray = countryArray
        }
        return localCountryArray
    }
    
    /// Instantiate the view controller with proper class from Storyboard
    ///
    /// - Returns: instantiated view controller
    class func loadFromStoryboard() -> Self {
        
        return self.instantiateFromStoryboardHelper();
    }
    
    private class func instantiateFromStoryboardHelper<T>() -> T
    {
        
        let className = String(describing: self);
        
        let storyboard = UIStoryboard(name: self.storyboardName(), bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: className) as! T;
        return vc
    }
    
    
    //To be override by sub classes, default storyboard is "Main"
    //View controllers that aren't designed in Main.storyboard must override this method
    class open func storyboardName() -> String {
        return "Main";
    }
    
    // Add child view
    func addChild(childViewController vc:UIViewController, inView view: UIView) {
        self.addChildViewController(vc)
        view.addSubview(vc.view)
        
        vc.view.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(view)
        }
        vc.didMove(toParentViewController: self)
    }
    
    func remove(childViewController childVC: UIViewController?) {
        childVC?.willMove(toParentViewController: nil)
        childVC?.view.removeFromSuperview()
        childVC?.removeFromParentViewController()
    }
}
