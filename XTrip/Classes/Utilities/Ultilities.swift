//
//  Ultilities.swift
//  Vaster
//
//  Created by Toan on 7/1/16.
//  Copyright © 2016 Elisoft. All rights reserved.
//

import UIKit

class Ultilities: NSObject {

    static func saveImageDocumentDirectory(_ image : UIImage) -> String{
        let nameFile = "\(String(describing: Date())).png"
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(nameFile)")
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
        return nameFile
    }
    
    static func saveFileDocumentDirectory(_ url: URL, fileType: String) -> String{
        var fileName = (url.absoluteString as NSString).lastPathComponent
        if fileType != "" {
            fileName = "\((fileName as NSString).deletingPathExtension).\(fileType)"
        }

        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(fileName)")
        fileManager.createFile(atPath: paths as String, contents: try? Data(contentsOf: url), attributes: nil)
        return fileName
    }
    
    static func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    static func getImage(_ nameFile: String) -> UIImage? {
        let fileManager = FileManager.default
        let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent("\(nameFile)")
        if fileManager.fileExists(atPath: imagePAth){
            return UIImage(contentsOfFile: imagePAth)
        }else{
            return nil
        }
    }
    
    static func getFile(_ nameFile: String) -> URL? {
        let fileManager = FileManager.default
        let filePath = (self.getDirectoryPath() as NSString).appendingPathComponent("\(nameFile)")
        if fileManager.fileExists(atPath: filePath){
            return URL(fileURLWithPath: filePath)
        }else{
            return nil
        }
    }
    
    static func stringStarsWithPrefixString(normalized: String, prefixString: String) -> Bool {
        if normalized.characters.count >= prefixString.characters.count {
            let indexPrefixString = normalized.index(normalized.startIndex, offsetBy: prefixString.characters.count)
            let prefixStringMatch = normalized.substring(to: indexPrefixString)
            if prefixStringMatch == prefixString {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }

    static func getDaysFromTwoDates(startDateUnix: Double, endDateUnix: Double) -> Int? {
        let calendar = NSCalendar.current
        // Replace the hour (time) of both dates with 00:00
        let startDate = Date(timeIntervalSince1970: TimeInterval(startDateUnix))
        let endDate = Date(timeIntervalSince1970: TimeInterval(endDateUnix))
        
        let date1 = calendar.startOfDay(for: startDate)
        let date2 = calendar.startOfDay(for: endDate)
        
        return calendar.dateComponents([.day], from: date1, to: date2).day
    }
}

