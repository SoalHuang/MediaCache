//
//  UIDevice+Capacity.swift
//  MediaCache
//
//  Created by SoalHuang on 2019/5/29.
//  Copyright © 2019 soso. All rights reserved.
//

import UIKit

extension UIDevice {
    
    public var totalCapacity: Int? {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory())
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeTotalCapacityKey])
            return values.volumeTotalCapacity
        } catch {
            VLog(.info, error.localizedDescription)
            return nil
        }
    }
    
    public var availableCapacity: Int? {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory())
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityKey])
            return values.volumeAvailableCapacity
        } catch {
            VLog(.info, error.localizedDescription)
            return nil
        }
    }
}
