//
//  VideoLRUConfiguration.swift
//  MediaCache
//
//  Created by SoalHuang on 2019/2/27.
//  Copyright © 2019 soso. All rights reserved.
//

import Foundation

public protocol MediaLRUConfigurationType {
    
    func update(visitTimes timesWeigth: Int, accessTime timeWeight: Int)
    
    @discardableResult
    func visit(url: MediaURLType) -> Bool
    
    @discardableResult
    func delete(url: MediaURLType) -> Bool
    
    @discardableResult
    func deleteAll(without downloading: [MediaCacheKeyType: MediaURLType]) -> Bool
    
    @discardableResult
    func synchronize() -> Bool
    
    func oldestURL(maxLength: Int, without downloading: [MediaCacheKeyType: MediaURLType]) -> [MediaURLType]
}

extension MediaLRUConfiguration: MediaLRUConfigurationType {
    
    /// visitTimes timesWeigth default 1, accessTime timeWeight default 2
    func update(visitTimes timesWeigth: Int, accessTime timeWeight: Int) {
        self.useWeight = timesWeigth
        self.timeWeight = timeWeight
        synchronize()
    }
    
    @discardableResult
    func visit(url: MediaURLType) -> Bool {
        VLog(.info, "use url: \(url)")
        lock.lock()
        defer { lock.unlock() }
        if let content = contentMap[url.key] {
            content.use()
        } else {
            let content = LRUContent(url: url)
            contentMap[url.key] = content
        }
        return synchronize()
    }
    
    @discardableResult
    func delete(url: MediaURLType) -> Bool {
        VLog(.info, "delete url: \(url)")
        lock.lock()
        defer { lock.unlock() }
        contentMap.removeValue(forKey: url.key)
        return synchronize()
    }
    
    @discardableResult
    func deleteAll(without downloading: [MediaCacheKeyType: MediaURLType]) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        contentMap = contentMap.filter { downloading[$0.key] != nil }
        return synchronize()
    }
    
    @discardableResult
    func synchronize() -> Bool {
        guard let path = filePath else { return false }
        return NSKeyedArchiver.archiveRootObject(self, toFile: path)
    }
    
    // If accessTime weight is 1, visitTimes weight is 2
    // accessTime sorted:   [A, B, C, D, E, F]
    // accessTime weight:   [A(1), B(2), C(3), D(4), E(5), F(6)]
    // visitTimes sorted:   [C, E, D, F, A, B]
    // visitTimes weight:   [C(1), E(2), D(3), F(4), A(5), B(6)]
    // combine:             [A(1 + 5 * 2), B(2 + 6 * 2), C(3 + 1 * 2), D(4 + 3 * 2), E(5 + 2 * 2), F(6 + 4 * 2)]
    // result:              [A(11), B(14), C(5), D(10), E(9), F(14)]
    // result sorted:       [C(5), E(9), D(10), A(11), B(14), F(14)]
    // oldest:              C(5)
    
    func oldestURL(maxLength: Int = 1, without downloading: [MediaCacheKeyType: MediaURLType]) -> [MediaURLType] {
        
        lock.lock()
        defer { lock.unlock() }
        
        let urls = contentMap.filter { downloading[$0.key] == nil }.values
        
        VLog(.info, "urls: \(urls)")
        
        guard urls.count > maxLength else { return urls.compactMap { $0.url} }
        
        urls.sorted { $0.time < $1.time }.enumerated().forEach { $0.element.weight += ($0.offset + 1) * timeWeight }
        urls.sorted { $0.count < $1.count }.enumerated().forEach { $0.element.weight += ($0.offset + 1) * useWeight }
        
        return urls.sorted(by: { $0.weight < $1.weight }).prefix(maxLength).compactMap { $0.url }
    }
}

let lruFileName = "lru"

class MediaLRUConfiguration: NSObject, NSCoding {
    
    var timeWeight: Int = 2
    var useWeight: Int = 1
    
    var filePath: String?
    
    private var contentMap: [MediaCacheKeyType: LRUContent] = [:]
    
    static func read(from filePath: String) -> MediaLRUConfiguration? {
        let config = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? MediaLRUConfiguration
        config?.filePath = filePath
        return config
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        timeWeight = aDecoder.decodeInteger(forKey: "timeWeight")
        useWeight = aDecoder.decodeInteger(forKey: "useWeight")
        contentMap = (aDecoder.decodeObject(forKey: "map") as? [MediaCacheKeyType: LRUContent]) ?? [:]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(timeWeight, forKey: "timeWeight")
        aCoder.encode(useWeight, forKey: "useWeight")
        aCoder.encode(contentMap, forKey: "map")
    }
    
    init(path: String) {
        super.init()
        filePath = path
    }
    
    private let lock = NSLock()
}

extension LRUContent {
    
    func use() {
        time = Date().timeIntervalSince1970
        count += 1
    }
}

class LRUContent: NSObject, NSCoding {
    
    var time: TimeInterval = Date().timeIntervalSince1970
    
    var count: Int = 1
    
    var weight: Int = 0
    
    let url: MediaURL
    
    init(url: MediaURLType) {
        self.url = MediaURL(cacheKey: url.key, originUrl: url.url)
        super.init()
    }
    
    override var description: String {
        return ["time": time, "count": count, "weight": weight, "url": url].description
    }
    
    required init?(coder aDecoder: NSCoder) {
        url = aDecoder.decodeObject(forKey: "url") as! MediaURL
        super.init()
        time = aDecoder.decodeDouble(forKey: "time")
        count = aDecoder.decodeInteger(forKey: "count")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(url, forKey: "url")
        aCoder.encode(time, forKey: "time")
        aCoder.encode(count, forKey: "count")
    }
}
