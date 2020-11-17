//
//  AVPlayerItem+Cache.swift
//  MediaCache
//
//  Created by SoalHuang on 2019/2/22.
//  Copyright © 2019 soso. All rights reserved.
//

import AVFoundation
import ObjectiveC.runtime

extension AVPlayerItem {
    
    /// if cache key is nil, it will be filled by url.absoluteString's md5 string
    public convenience init(manager: MediaCacheManager = MediaCacheManager.default,
                            remote url: URL,
                            cacheKey key: MediaCacheKeyType? = nil,
                            cacheFragments: [MediaCacheFragment] = [.prefix(MediaRangeBounds.max)]) {
        
        let `key` = key ?? url.absoluteString.mediaCacheMD5
        
        let videoUrl = MediaURL(cacheKey: key, originUrl: url)
        manager.visit(url: videoUrl)
        
        let loaderDelegate = VideoResourceLoaderDelegate(manager: manager,
                                                         url: videoUrl,
                                                         cacheFragments: cacheFragments)
        let urlAsset = AVURLAsset(url: loaderDelegate.url.includeMediaCacheSchemeUrl, options: nil)
        urlAsset.resourceLoader.setDelegate(loaderDelegate, queue: .main)
        
        self.init(asset: urlAsset)
        canUseNetworkResourcesForLiveStreamingWhilePaused = true
        
        resourceLoaderDelegate = loaderDelegate
    }
    
    public func cacheCancel() {
        resourceLoaderDelegate?.cancel()
        resourceLoaderDelegate = nil
    }
    
    /// default is true
    public var allowsCellularAccess: Bool {
        get { return resourceLoaderDelegate?.allowsCellularAccess ?? true }
        set { resourceLoaderDelegate?.allowsCellularAccess = newValue }
    }
    
    /// default is false
    public var useChecksum: Bool {
        get { return resourceLoaderDelegate?.useChecksum ?? false }
        set { resourceLoaderDelegate?.useChecksum = newValue }
    }
}
