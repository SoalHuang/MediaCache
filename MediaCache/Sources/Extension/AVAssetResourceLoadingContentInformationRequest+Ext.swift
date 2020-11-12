//
//  AVAssetResourceLoadingContentInformationRequest+Ext.swift
//  MediaCache
//
//  Created by SoalHuang on 2019/2/26.
//  Copyright © 2019 soso. All rights reserved.
//

import AVFoundation

extension AVAssetResourceLoadingContentInformationRequest {
    
    func update(contentInfo: ContentInfo) {
        guard contentType == nil, contentInfo.totalLength > 0 else { return }
        contentType = contentInfo.type
        contentLength = Int64(contentInfo.totalLength)
        isByteRangeAccessSupported = contentInfo.byteRangeAccessSupported
        VLog(.info, "content info: \(contentInfo)")
    }
}
