//
//  Bundle+Extension.swift
//  Driver-iOS
//
//  Created by Than Dang on 5/18/17.
//  Copyright © 2017 com.MaiLinh.iOS. All rights reserved.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
