//
//  SNSShare.swift

import Foundation
import UIKit
import Social

public enum SNSType {
    
    case Twitter, Facebook, LINE
    
    public static var list: [SNSType] {
        return [SNSType.Twitter, .Facebook, .LINE]
    }
    
    public var serviceType: String {
        switch self {
        case .Twitter: return SLServiceTypeTwitter
        case .Facebook: return SLServiceTypeFacebook
        default: return ""
        }
    }
    
    public func useSocialFramework() -> Bool {
        switch self {
        case .Twitter, .Facebook: return true
        default: return false
        }
    }
    
}

public enum SNSShareResult {
    case Success
    case Failure(SNSShareErrorType)
}

public enum SNSShareErrorType: Error {
    case NotAvailable(SNSType)
    case EmptyData
    case Cancelled
    case URIEncodingError
    case UnknownError
}

public typealias SNSSharePostCompletion = (SNSShareResult) -> Void

public class SNSShareData {
    
    public var text: String = ""
    public var images: [UIImage] = [UIImage]()
    public var urls: [NSURL] = [NSURL]()
    
    public init() {
    }
    
    public init(_ text: String) {
        self.text = text
    }
    
    public init(_ images: [UIImage]) {
        self.images = images
    }
    
    public init(_ urls: [NSURL]) {
        self.urls = urls
    }
    
    public init(text: String, images: [UIImage], urls: [NSURL]) {
        self.text = text
        self.images = images
        self.urls = urls
    }
    
    public typealias BuilderClosure = (SNSShareData) -> Void
    public init(builder: BuilderClosure) {
        builder(self)
    }    
    
    public var isEmpty: Bool {
        return text.isEmpty && images.isEmpty && urls.isEmpty
    }
    
}

public class SNSShare {
    
    public class func available(type: SNSType) -> Bool {
        switch type {
        case .Twitter:
            return SLComposeViewController.isAvailable(forServiceType: SNSType.Twitter.serviceType)
        case .Facebook:
            return SLComposeViewController.isAvailable(forServiceType: SNSType.Facebook.serviceType)
        case .LINE:
            return UIApplication.shared.canOpenURL(NSURL(string: "line://")! as URL)
        }
    }
    
    public class func availableSNSList() -> [SNSType] {
        return SNSType.list.filter { available(type: $0) }
    }
    
    public class func post(
        type: SNSType,
        data: SNSShareData,
        controller: UIViewController,
        completion: @escaping SNSSharePostCompletion = { _ in })
    {
        guard available(type: type) else {
            completion(.Failure(.NotAvailable(type)))
            return
        }
        
        guard !data.isEmpty else {
            completion(.Failure(.EmptyData))
            return
        }
        
        if type.useSocialFramework() {
            postToSocial(serviceType: type.serviceType, data: data, controller: controller, completion: completion)
        } else {
            if case .LINE = type {
                postToLINE(data: data, completion: completion)
            } else {
                completion(.Failure(.UnknownError))
            }
        }
    }
    
    private class func postToSocial(
        serviceType: String,
        data: SNSShareData,
        controller: UIViewController,
        completion: @escaping SNSSharePostCompletion)
    {
        let sheet = SLComposeViewController(forServiceType: serviceType)
        sheet?.completionHandler = { result in
            switch result {
            case .done: completion(.Success)
            case .cancelled: completion(.Failure(.Cancelled))
            }
        }
        sheet?.setInitialText(data.text)
        data.images.forEach {sheet?.add($0) }
        data.urls.forEach { sheet?.add($0 as URL) }
        controller.present(sheet!, animated: true, completion: nil)
    }
    
    
    private class func postToLINE(data: SNSShareData, completion: SNSSharePostCompletion) {
        
        var scheme = "line://msg/"
        if let image = data.images.first, let imageData = UIImagePNGRepresentation(image) {
            let pasteboard = UIPasteboard.general
            pasteboard.setData(imageData, forPasteboardType: "public.png")
            scheme += "image/\(pasteboard.name)"
        } else {
            var texts = [String]()
            texts.append(data.text)
            data.urls.forEach{ texts.append($0.absoluteString!) }
            let set = NSCharacterSet.alphanumerics
            guard let text = texts
                .joined(separator: "\n").addingPercentEncoding(withAllowedCharacters: set) else
            {
                completion(.Failure(.URIEncodingError))
                return
            }
            scheme += "text/\(text)"
        }
        
        guard let url = NSURL(string: scheme) else {
            completion(.Failure(.UnknownError))
            return
        }
        
        UIApplication.shared.openURL(url as URL)
        completion(.Success)
    }
    
}
