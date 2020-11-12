//
//  URL+Ext.swift
//  MediaCache
//
//  Created by SoalHuang on 2019/2/22.
//  Copyright © 2019 soso. All rights reserved.
//

import Foundation
import MobileCoreServices

extension URL {
    
    static let MediaCacheScheme = "__MediaCache__:"
    
    var isCacheScheme: Bool {
        return absoluteString.hasPrefix(URL.MediaCacheScheme)
    }
    
    var originUrl: URL {
        return URL(string: absoluteString.replacingOccurrences(of: URL.MediaCacheScheme, with: "")) ?? self
    }
    
    var contentType: String? {
        return UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, pathExtension as CFString, nil)?.takeRetainedValue() as String?
    }
}
