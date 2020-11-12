//
//  Configuration.swift
//  MediaCache
//
//  Created by SoalHuang on 2019/2/21.
//  Copyright © 2019 soso. All rights reserved.
//

import Foundation

protocol MediaConfigurationType: NSObjectProtocol {
    
    var url: MediaURL { get }
    
    var contentInfo: ContentInfo { get set }
    
    var reservedLength: MediaRangeBounds { get set }
    
    var fragments: [MediaRange] { get }
    
    func overlaps(_ other: MediaRange) -> [MediaRange]
    
    func reset(fragment: MediaRange)
    
    func add(fragment: MediaRange)
    
    @discardableResult
    func synchronize(to path: String) -> Bool
}

class MediaConfiguration: NSObject, NSCoding {
    
    let url: MediaURL
    
    var contentInfo: ContentInfo = ContentInfo(totalLength: 0)
    
    var reservedLength: MediaRangeBounds = 0
    
    var fragments: [MediaRange] = []
    
    var lastTimeInterval: TimeInterval = Date().timeIntervalSince1970
    
    required init?(coder aDecoder: NSCoder) {
        url = aDecoder.decodeObject(forKey: "url") as! MediaURL
        super.init()
        contentInfo = aDecoder.decodeObject(forKey: "contentInfo") as! ContentInfo
        reservedLength = aDecoder.decodeInt64(forKey: "reservedLength")
        lastTimeInterval = aDecoder.decodeDouble(forKey: "lastTimeInterval")
        
        if let frags = aDecoder.decodeObject(forKey: "fragments") as? [CodingRange] {
            fragments = frags.compactMap { MediaRange(range: $0) }
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(url, forKey: "url")
        aCoder.encode(contentInfo, forKey: "contentInfo")
        aCoder.encode(reservedLength, forKey: "reservedLength")
        aCoder.encode(lastTimeInterval, forKey: "lastTimeInterval")
        aCoder.encode(fragments.compactMap { $0.range }, forKey: "fragments")
    }
    
    init(url: MediaURLType) {
        self.url = MediaURL(cacheKey: url.key, originUrl: url.url)
        super.init()
    }
    
    private let lock = NSLock()
    
    override var description: String {
        return ["url": url, "contentInfo": contentInfo, "reservedLength": reservedLength, "lastTimeInterval": lastTimeInterval, "fragments": fragments].description
    }
}

extension MediaConfiguration: MediaConfigurationType {
    
    @discardableResult
    func synchronize(to path: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        lastTimeInterval = Date().timeIntervalSince1970
        return NSKeyedArchiver.archiveRootObject(self, toFile: path)
    }
    
    func overlaps(_ range: MediaRange) -> [MediaRange] {
        lock.lock()
        defer { lock.unlock() }
        return fragments.overlaps(range)
    }
    
    func reset(fragment: MediaRange) {
        VLog(.data, "reset fragment: \(fragment)")
        lock.lock()
        defer { lock.unlock() }
        fragments = [fragment]
    }
    
    func add(fragment: MediaRange) {
        VLog(.data, "add fragment: \(fragment)")
        lock.lock()
        defer { lock.unlock() }
        guard fragment.isValid else { return }
        fragments = fragments.union(fragment)
    }
}
