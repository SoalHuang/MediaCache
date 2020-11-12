//
//  MediaCacheFragment.swift
//  MediaCache
//
//  Created by SoalHuang on 2019/12/13.
//  Copyright © 2019 soso. All rights reserved.
//

import Foundation

public enum MediaCacheFragment {
    
    case prefix(MediaRangeBounds)
    case suffix(MediaRangeBounds)
    case range(MediaRange)
}

extension MediaCacheFragment {
    
    func ranges(for totalLength: MediaRangeBounds) -> MediaRange {
        switch self {
        case .prefix(let bounds):   return 0...bounds
        case .suffix(let bounds):   return max(0, totalLength - bounds)...totalLength
        case .range(let range):     return range
        }
    }
}
