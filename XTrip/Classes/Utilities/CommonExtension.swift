//
//  UIView+Helper.swift
//  User-iOS
//
//  Created by Hoang Cap on 4/21/17.
//  Copyright © 2017 com.order. All rights reserved.
//

import Foundation
import UIKit


extension UIPageControl {
    var isLastPage: Bool {
        return self.currentPage == self.numberOfPages - 1
    }
}

extension UIView {
    var origin: CGPoint {
        return self.frame.origin;
    }
    
    func setOrigin(newOrigin:CGPoint) {
        var newFrame = self.frame;
        newFrame.origin = newOrigin;
        self.frame = newFrame;
    }
    
    var size: CGSize {
        return self.frame.size;
    }
    
    func setSize(newSize: CGSize) {
        var newFrame = self.frame;
        newFrame.size = newSize;
        self.frame = newFrame;
    }
    
    var x: CGFloat {
        return self.frame.origin.x;
    }
    
    func setX(newX:CGFloat) {
        var newFrame = self.frame;
        newFrame.origin.x = newX;
        self.frame = newFrame;
    }
    
    var y: CGFloat {
    return self.frame.origin.y;
    }
    
    func setY(newY: CGFloat) {
        var newFrame = self.frame;
        newFrame.origin.y = newY;
        self.frame = newFrame;
    }
    
    var height:CGFloat {
        return self.frame.size.height;
    }
    
    func setHeight(newHeight: CGFloat) {
        var newFrame = self.frame;
        newFrame.size.height = newHeight;
        self.frame = newFrame;
    }
    
    var width: CGFloat {
        return self.frame.size.width;
    }
    
    func setWidth(newWidth: CGFloat) {
        var newFrame = self.frame;
        newFrame.size.width = newWidth;
        self.frame = newFrame;
    }
    
    //
    func imageData () -> Data {
        UIGraphicsBeginImageContextWithOptions(self.layer.frame.size, false, 0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let data = UIImagePNGRepresentation(viewImage)
        return data!
    }
    
    static func viewFromNib() -> UIView {
        
        let nibName = self.description().components(separatedBy: ".").last!; //Must get the last part of the description behind "." because description might return something like "myBundle.MyViewClass" can cause a crash
        
        let nib = UINib.init(nibName: nibName, bundle: nil);
        let objectsFromNib = nib.instantiate(withOwner: nil, options: nil);
        return objectsFromNib.first as! UIView;
    }
    
    func setRoundedCorner(radius: CGFloat, borderWidth: CGFloat = 1, borderColor: UIColor = UIColor.clear) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.clipsToBounds = true
    }
    
    func takeScreenshot() -> UIImage {
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}


extension URL
{
    var queryDictionary:[String: [String]]? {
        get {
            if let query = self.query {
                var dictionary = [String: [String]]()
                
                for keyValueString in query.components(separatedBy: "&") {
                    var parts = keyValueString.components(separatedBy: "=")
                    if parts.count < 2 { continue; }
                    
                    let key = parts[0].removingPercentEncoding!
                    let value = parts[1].removingPercentEncoding!
                    
                    var values = dictionary[key] ?? [String]()
                    values.append(value)
                    dictionary[key] = values
                }
                
                return dictionary
            }
            return nil
        }
    }
}

extension Array where Element:Equatable {
    public mutating func remove(_ item:Element ) {
        var index = 0
        while index < self.count {
            if self[index] == item {
                self.remove(at: index)
            } else {
                index += 1
            }
        }
    }
    
    public func array( removing item:Element ) -> [Element] {
        var result = self
        result.remove( item )
        return result
    }
}

extension Double {
    
    func currencyString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter.string(from: self as NSNumber)!

    }
    
    func timeString () -> String {
        
        let date = Date(timeIntervalSince1970: self)
        let timeZone = TimeZone.current
        let calendar = Calendar.current
        let locale = Locale(identifier: "vi_VN")
        //let region = Region(calendar: calendar, zone: timeZone, locale: locale)
        
        return date.format(with: ("HH:MM"), locale: locale)
    }
    
    func unixTimeToString() -> String {
        let date = NSDate(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date as Date)
    }
    
    func unixTimeToDayString() -> String {
        let date = NSDate(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date as Date)
    }
    
    func unixTimeToDayMonthYearString() -> String {
        let date = NSDate(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date as Date)
    }
    
    func unixTimeToHourDayMonthYearString() -> String {
        let date = NSDate(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:MM dd MMM yyyy"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date as Date)
    }
}

extension AppDelegate {
    func setRootViewController(_ vc:UIViewController, _ animated: Bool) {
        
        if (animated) {
            UIView.animate(withDuration: 0.4, animations: { 
                self.window?.rootViewController = vc;
            })
        } else {
            self.window?.rootViewController = vc;
        }
    }
}

extension UIViewController {
    func showAlertWithTitle(_ title: String? = "Error", message mess: String?,
                            okButton ok: String? = nil,
                            alertViewType type: UIAlertControllerStyle = .alert,
                            okHandler: ((UIAlertAction) -> Void)?,
                            closeButton close: String? = nil,
                            closeHandler: ((UIAlertAction) -> Void)?,
                            completionHanlder completion: (()-> Void)?) -> Void {
        
        let alertVC = UIAlertController(title: title, message: mess, preferredStyle: type)
        
        if let ok = ok{
            let okAction = UIAlertAction(title: ok, style: .default, handler: okHandler)
            alertVC.addAction(okAction)
        }
        
        if let close = close{
            let closeAction = UIAlertAction(title: close, style: .cancel, handler: closeHandler)
            alertVC.addAction(closeAction)
        }
        
        if close == nil && ok == nil{
            let defaultAction = UIAlertAction(title: "Close", style: .default, handler: closeHandler)
            alertVC.addAction(defaultAction)
        }
        
        self.present(alertVC, animated: true, completion: completion)
    }
}


extension UIApplication {
    
    static func currentAppDelegate() -> AppDelegate {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate
    }
}

import SwiftDate
extension Date {
    func pickupTimeString() -> String {
        let timeZone = TimeZone.current
        let calendar = Calendar.current
        let locale = Locale(identifier: "vi_VN")
        //let region = Region(tz: timeZone, cal: calendar, loc: locale)
        
        return self.format(with: ("h'h'mm a, EEEE, dd MMMM"), locale: locale)
    }
}

extension CGRect {
    mutating func offsetInPlace(dx: CGFloat, dy: CGFloat) {
        self = self.offsetBy(dx: dx, dy: dy)
    }
}


extension UIImage {
    
    var jpegData: Data? {
        return UIImageJPEGRepresentation(self, 1)   // QUALITY min = 0 / max = 1
    }
    
    var pngData: Data? {
        return UIImagePNGRepresentation(self)
    }
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    func resizeImage( _ targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension UIPanGestureRecognizer {
    
    public struct PanGestureDirection: OptionSet {
        public let rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        static let Up = PanGestureDirection(rawValue: 1 << 0)
        static let Down = PanGestureDirection(rawValue: 1 << 1)
        static let Left = PanGestureDirection(rawValue: 1 << 2)
        static let Right = PanGestureDirection(rawValue: 1 << 3)
    }
    
    private func getDirectionBy(velocity: CGFloat, greater: PanGestureDirection, lower: PanGestureDirection) -> PanGestureDirection {
        if velocity == 0 {
            return []
        }
        return velocity > 0 ? greater : lower
    }
    
    public func direction(in view: UIView) -> PanGestureDirection {
        let velocity = self.velocity(in: view)
        let yDirection = getDirectionBy(velocity: velocity.y, greater: PanGestureDirection.Down, lower: PanGestureDirection.Up)
        let xDirection = getDirectionBy(velocity: velocity.x, greater: PanGestureDirection.Right, lower: PanGestureDirection.Left)
        return xDirection.union(yDirection)
    }
}

public enum UIPanGestureRecognizerDirection {
    case undefined
    case bottomToTop
    case topToBottom
    case rightToLeft
    case leftToRight
}
public enum TransitionOrientation {
    case unknown
    case topToBottom
    case bottomToTop
    case leftToRight
    case rightToLeft
}


extension UIPanGestureRecognizer {
    public var direction: UIPanGestureRecognizerDirection {
        let velocity = self.velocity(in: view)
        let isVertical = fabs(velocity.y) > fabs(velocity.x)
        
        var direction: UIPanGestureRecognizerDirection
        
        if isVertical {
            direction = velocity.y > 0 ? .topToBottom : .bottomToTop
        } else {
            direction = velocity.x > 0 ? .leftToRight : .rightToLeft
        }
        
        return direction
    }
    
    public func isQuickSwipe(for orientation: TransitionOrientation) -> Bool {
        let velocity = self.velocity(in: view)
        return isQuickSwipeForVelocity(velocity, for: orientation)
    }
    
    private func isQuickSwipeForVelocity(_ velocity: CGPoint, for orientation: TransitionOrientation) -> Bool {
        switch orientation {
        case .unknown : return false
        case .topToBottom : return velocity.y > 1000
        case .bottomToTop : return velocity.y < -1000
        case .leftToRight : return velocity.x > 1000
        case .rightToLeft : return velocity.x < -1000
        }
    }
}

extension UIPanGestureRecognizer {
    typealias GestureHandlingTuple = (gesture: UIPanGestureRecognizer? , handle: (UIPanGestureRecognizer) -> ())
    fileprivate static var handlers = [GestureHandlingTuple]()
    
    public convenience init(gestureHandle: @escaping (UIPanGestureRecognizer) -> ()) {
        self.init()
        UIPanGestureRecognizer.cleanup()
        set(gestureHandle: gestureHandle)
    }
    
    public func set(gestureHandle: @escaping (UIPanGestureRecognizer) -> ()) {
        weak var weakSelf = self
        let tuple = (weakSelf, gestureHandle)
        UIPanGestureRecognizer.handlers.append(tuple)
        addTarget(self, action: #selector(handleGesture))
    }
    
    fileprivate static func cleanup() {
        handlers = handlers.filter { $0.0?.view != nil }
    }
    
    @objc private func handleGesture(_ gesture: UIPanGestureRecognizer) {
        let handleTuples = UIPanGestureRecognizer.handlers.filter{ $0.gesture === self }
        handleTuples.forEach { $0.handle(gesture)}
    }
}

extension UIPanGestureRecognizerDirection {
    public var orientation: TransitionOrientation {
        switch self {
        case .rightToLeft: return .rightToLeft
        case .leftToRight: return .leftToRight
        case .bottomToTop: return .bottomToTop
        case .topToBottom: return .topToBottom
        default: return .unknown
        }
    }
}

extension UIPanGestureRecognizerDirection {
    public var isHorizontal: Bool {
        switch self {
        case .rightToLeft, .leftToRight:
            return true
        default:
            return false
        }
    }
}


private let imageCache = NSCache<NSString, UIImage>()

private var kAssociatedUrl = "kAssociatedUrl"

extension UIImageView {
    
    //An associated dictionary to hold the cached annotation views for drivers
    var downloadUrl: String? {
        get {
            return objc_getAssociatedObject(self, &kAssociatedUrl) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kAssociatedUrl, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func loadImage(fromURL urlString: String) {
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            DispatchQueue.main.async {
                self.image = cachedImage;
            }
        }
        
        self.downloadUrl = urlString;
        
        let url = URL(string: urlString);
        
        if let url = url {
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if (error != nil) {
                    return;
                }
                DispatchQueue.main.async {
                    if let imageToCache = UIImage(data: data!) {
                        if (self.downloadUrl == urlString) {
                            imageCache.setObject(imageToCache, forKey: urlString as NSString);
                            self.image = imageToCache;
                        }
                    }
                }
                }.resume();
        }
    }
}

extension UIPageControl {
    
    /// Return true if page control is at the last page
    var isAtLastPage: Bool {
        if (numberOfPages > 0) {
            return (self.currentPage == self.numberOfPages - 1);
        }
        return false;
    }
}

extension Data {
    var uiImage: UIImage? {
        return UIImage(data: self)
    }
}

extension String {
    //To check text field or String is blank or not
    var isBlank: Bool {
        get {
            let trimmed = trimmingCharacters(in: CharacterSet.whitespaces)
            return trimmed.isEmpty
        }
    }
}

public extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(self.rootViewController)
    }
    
    public static func getVisibleViewControllerFrom(_ vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(pvc)
            } else {
                return vc
            }
        }
    }
    
    public func setRootViewController(_ viewController: UIViewController, fromWindow window: UIWindow, withTransition transition: UIViewAnimationOptions, completionHandler completion: ((_ finished: Bool) -> Void)?){
        UIView.transition(with: window, duration: 0.5, options: transition, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            window.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
        }, completion: completion)
    }
}

//MARK:- UIButton
extension UIButton {
    func rotateButton(animationDuration timeInterVal :CFTimeInterval, inSecond second:CFTimeInterval) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = timeInterVal
        let repeatCount = Float(second) / Float(rotateAnimation.duration)
        rotateAnimation.repeatCount = repeatCount
        self.layer.add(rotateAnimation, forKey: nil)
    }
    
    func stopButtonAnimation() {
        self.layer.removeAllAnimations()
    }
}
