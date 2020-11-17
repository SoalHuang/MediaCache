//
//  VideoLoader.swift
//  MediaCache
//
//  Created by SoalHuang on 2019/2/24.
//  Copyright © 2019 soso. All rights reserved.
//

import Foundation
import AVFoundation

protocol MediaLoaderType: NSObjectProtocol {
    
    func add(loadingRequest: AVAssetResourceLoadingRequest)
    func remove(loadingRequest: AVAssetResourceLoadingRequest)
    func cancel()
}

protocol MediaLoaderDelegate: NSObjectProtocol {
    
    func loaderAllowWriteData(_ loader: MediaLoader) -> Bool
}

extension MediaLoader: MediaLoaderType {
    
    func add(loadingRequest: AVAssetResourceLoadingRequest) {
        let downloader = MediaDownloader(paths: paths,
                                         session: session,
                                         url: url,
                                         loadingRequest: loadingRequest,
                                         fileHandle: fileHandle,
                                         useChecksum: useChecksum)
        downloader.delegate = self
        downLoaders.append(downloader)
        downloader.execute()
    }
    
    func remove(loadingRequest: AVAssetResourceLoadingRequest) {
        downLoaders.removeAll {
            guard $0.loadingRequest == loadingRequest else { return false }
            $0.finish()
            return true
        }
    }
    
    func cancel() {
        VLog(.info, "VideoLoader cancel\n")
        downLoaders.forEach { $0.cancel() }
        downLoaders.removeAll()
    }
}

extension MediaLoader: MediaDownloaderDelegate {
    
    func downloaderAllowWriteData(_ downloader: MediaDownloader) -> Bool {
        return delegate?.loaderAllowWriteData(self) ?? false
    }
    
    func downloaderFinish(_ downloader: MediaDownloader) {
        downloader.finish()
        downLoaders.removeAll { $0.loadingRequest == downloader.loadingRequest }
    }
    
    func downloader(_ downloader: MediaDownloader, finishWith error: Error?) {
        VLog(.error, "loader download failure: \(String(describing: error))")
        cancel()
    }
}

fileprivate struct DownloadQueue {
    
    static let shared = DownloadQueue()
    
    let queue: OperationQueue = OperationQueue()
    
    init() {
        queue.name = "com.video.cache.download.queue"
    }
}

class MediaLoader: NSObject {
    
    weak var delegate: MediaLoaderDelegate?
    
    let paths: MediaCachePaths
    let url: MediaURLType
    let cacheFragments: [MediaCacheFragment]
    let useChecksum: Bool
    
    var session: URLSession?
    
    deinit {
        VLog(.info, "VideoLoader deinit\n")
        cancel()
        session?.invalidateAndCancel()
        session = nil
    }
    
    init(paths: MediaCachePaths,
         url: MediaURLType,
         cacheFragments: [MediaCacheFragment],
         allowsCellularAccess: Bool,
         useChecksum: Bool,
         delegate: MediaLoaderDelegate?) {
        
        self.paths = paths
        self.url = url
        self.cacheFragments = cacheFragments
        self.useChecksum = useChecksum
        self.delegate = delegate
        
        super.init()
        
        let configuration = URLSessionConfiguration.default
//        configuration.timeoutIntervalForRequest = 30
//        configuration.timeoutIntervalForResource = 60
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.networkServiceType = .video
        configuration.allowsCellularAccess = allowsCellularAccess
        session = URLSession(configuration: configuration,
                             delegate: self,
                             delegateQueue: DownloadQueue.shared.queue)
    }
    
    private lazy var fileHandle: MediaFileHandle = MediaFileHandle(paths: paths,
                                                                   url: url,
                                                                   cacheFragments: cacheFragments)
    
    private var downLoaders_: [MediaDownloaderType] = []
    private let lock = NSLock()
    private var downLoaders: [MediaDownloaderType] {
        get { lock.lock(); defer { lock.unlock() }; return downLoaders_ }
        set { lock.lock(); defer { lock.unlock() }; downLoaders_ = newValue }
    }
}

extension MediaLoader: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let serverTrust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.useCredential, nil)
        }
    }
    
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        downLoaders.forEach {
            if $0.task == dataTask {
                $0.dataReceiver?.urlSession?(session,
                                             dataTask: dataTask,
                                             didReceive: response,
                                             completionHandler: completionHandler)
            }
        }
    }
    
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive data: Data) {
        downLoaders.forEach {
            if $0.task == dataTask {
                $0.dataReceiver?.urlSession?(session,
                                             dataTask: dataTask,
                                             didReceive: data)
            }
        }
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        downLoaders.forEach {
            if $0.task == task {
                $0.dataReceiver?.urlSession?(session,
                                             task: task,
                                             didCompleteWithError: error)
            }
        }
    }
}
