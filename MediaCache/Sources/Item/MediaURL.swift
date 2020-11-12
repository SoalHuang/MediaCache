//
//  VURL.swift
//  MediaCache
//
//  Created by SoalHuang on 2019/2/24.
//  Copyright © 2019 soso. All rights reserved.
//

import UIKit

public typealias MediaCacheKeyType = String

public protocol MediaURLType {
    
    var key: MediaCacheKeyType { get }
    var url: URL { get }
    var includeMediaCacheSchemeUrl: URL { get }
}

let MediaCacheConfigFileExt = "cfg"

extension MediaURL: MediaURLType {
    
    public var key: MediaCacheKeyType {
        return cacheKey
    }
    
    public var url: URL {
        return originUrl
    }
    
    public var includeMediaCacheSchemeUrl: URL {
        return URL(string: URL.MediaCacheScheme + url.absoluteString)!
    }
}

class MediaURL: NSObject, NSCoding {
    
    var cacheKey: MediaCacheKeyType
    
    var originUrl: URL
    
    required init?(coder aDecoder: NSCoder) {
        cacheKey = aDecoder.decodeObject(forKey: "key") as! String
        originUrl = URL(string: aDecoder.decodeObject(forKey: "url") as! String)!
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(cacheKey, forKey: "key")
        aCoder.encode(originUrl.absoluteString, forKey: "url")
    }
    
    init(cacheKey: MediaCacheKeyType, originUrl: URL) {
        self.cacheKey = cacheKey
        self.originUrl = originUrl
        super.init()
    }
    
    override var description: String {
        return ["cacheKey": cacheKey, "originUrl": originUrl].description
    }
}
