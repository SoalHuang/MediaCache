//
//  CodingRange.swift
//  MediaCache
//
//  Created by SoalHuang on 2019/3/15.
//  Copyright © 2019 soso. All rights reserved.
//

import Foundation

public typealias MediaRangeBounds = Int64
public typealias MediaRange = ClosedRange<MediaRangeBounds>

class CodingRange: NSObject, NSCoding {
    
    var lowerBound: MediaRangeBounds
    var upperBound: MediaRangeBounds
    
    init(lowerBound: MediaRangeBounds, upperBound: MediaRangeBounds) {
        self.lowerBound = lowerBound
        self.upperBound = upperBound
    }
    
    required init?(coder aDecoder: NSCoder) {
        lowerBound = aDecoder.decodeInt64(forKey: "lowerBound")
        upperBound = aDecoder.decodeInt64(forKey: "upperBound")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(lowerBound, forKey: "lowerBound")
        aCoder.encode(upperBound, forKey: "upperBound")
    }
    
    override var description: String {
        return "(\(lowerBound)...\(upperBound))"
    }
}
