//
//  VLog.swift
//  MediaCache
//
//  Created by SoalHuang on 2019/2/27.
//  Copyright © 2019 soso. All rights reserved.
//

import Foundation

public enum MediaCacheLogLevel: UInt {
    
    case none, error, info, request, data
    
    var description: String {
        switch self {
        case .none:     return "NONE"
        case .error:    return "ERROR"
        case .info:     return "INFO"
        case .request:  return "REQUEST"
        case .data:     return "DATA"
        }
    }
}

var mediaCacheLogLevel: MediaCacheLogLevel = .none

private let logQueue = DispatchQueue(label: "com.video.cache.log.queue")

func VLog(file: String = #file, line: Int = #line, fun: String = #function, _ level: MediaCacheLogLevel, _ message: Any) {
    guard level.rawValue <= mediaCacheLogLevel.rawValue else { return }
    logQueue.async {
        Swift.print("[Video Cache] [\(level.description)] file: \(file.components(separatedBy: "/").last ?? "none"), line: \(line), func: \(fun): \(message)")
    }
}
