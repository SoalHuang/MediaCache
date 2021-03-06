//
//  Action.swift
//  MediaCache
//
//  Created by SoalHuang on 2019/2/26.
//  Copyright © 2019 soso. All rights reserved.
//

import Foundation

enum Action {
    
    case local(MediaRange)
    case remote(MediaRange)
}

extension Action {
    
    var unwrap: MediaRange {
        switch self {
        case .local(let localRange): return localRange
        case .remote(let remoteRange): return remoteRange
        }
    }
}

extension Action: Comparable {
    
    static func == (lhs: Action, rhs: Action) -> Bool {
        switch (lhs, rhs) {
        case (.local(let llr), .local(let lrr)): return llr == lrr
        case (.remote(let rlr), .remote(let rrr)): return rlr == rrr
        default: return false
        }
    }
    
    static func != (lhs: Action, rhs: Action) -> Bool {
        return !(lhs == rhs)
    }
    
    static func < (lhs: Action, rhs: Action) -> Bool {
        return lhs.unwrap.lowerBound < rhs.unwrap.lowerBound
    }
    
    static func > (lhs: Action, rhs: Action) -> Bool {
        return lhs.unwrap.lowerBound > rhs.unwrap.lowerBound
    }
}
