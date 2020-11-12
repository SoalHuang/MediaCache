//
//  Data+CheckSum.swift
//  MediaCache
//
//  Created by SoalHuang on 2019/12/10.
//  Copyright © 2019 soso. All rights reserved.
//

import Foundation

extension Data {
    
    func checksum(split: MediaRangeBounds = Int64(1).KB, vacuate: MediaRangeBounds? = nil) -> Bool {
        return (self as NSData).checksum(split: split)
    }
}

extension NSData {
    
    func checksum(split: MediaRangeBounds, vacuate: MediaRangeBounds? = nil) -> Bool {
        
        if isEmpty {
            return false
        }
        
        let totalRange = MediaRange(0, MediaRangeBounds(count))
        
        var splitRanges = totalRange.split(limit: split).filter { $0.isValid }
        let vacuateCount: MediaRangeBounds = vacuate ?? MediaRangeBounds(sqrt(Double(splitRanges.count)))
        
        let results: [MediaRange] = (0..<vacuateCount).compactMap { _ in
            let index = Int.random(in: splitRanges.indices)
            return splitRanges.remove(at: index)
        }
        
        for range in results {
            
            let r = NSRange(location: Int(range.lowerBound), length: Int(range.length))
            
            let data = subdata(with: r)
            
            guard data.count == r.length else {
                return false
            }
            
            let sum: MediaRangeBounds = data.reduce(0) { $0 + MediaRangeBounds($1) }
            
            VLog(.data, "sub-range: \(r) checksum: \(sum) --> \(sum < r.length ? "invalid" : "valid")")
            
            if sum < r.length {
                return false
            }
        }
        
        return true
    }
}
