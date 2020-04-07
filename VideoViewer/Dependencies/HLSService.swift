//
// Copyright © 2020 @esesmuedgars.
//

import Foundation
import AVFoundation

protocol HLSServiceProtocol: class {
    func localAssetForStream(withId key: String) -> AVURLAsset?
    func cancelDownload(for asset: Asset)
    func downloadStream(for asset: Asset)
}

final class HLSService: NSObject, HLSServiceProtocol {
    @Published var downloadProgress: Double = 0
    
    private let configuration: URLSessionConfiguration
    private lazy var downloadSession = AVAssetDownloadURLSession(configuration: configuration,
                                                                 assetDownloadDelegate: self,
                                                                 delegateQueue: OperationQueue.main)

    private var activeDownloads = [AVAggregateAssetDownloadTask: Asset]()

    private var willDownloadToUrl = [AVAggregateAssetDownloadTask: URL]()
    
    enum DownloadState: String {
        case idle, inProgress, completed
    }
    
    private var userDefaults: UserDefaults {
        UserDefaults.standard
    }
    
    override init() {
        configuration = URLSessionConfiguration.background(
            withIdentifier: "DownloadSessionConfigurationBackgroundIdentifier"
        )
        
        super.init()
    }
    
    func downloadStream(for asset: Asset) {
        let avAsset = AVURLAsset(url: asset.url)
        
        guard let downloadTask = downloadSession.aggregateAssetDownloadTask(
            with: avAsset,
            mediaSelections: [avAsset.preferredMediaSelection],
            assetTitle: asset.id,
            assetArtworkData: nil,
            options: [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 265_000]
        ) else { return }
        
        activeDownloads[downloadTask] = asset
        
        downloadTask.resume()
        
        var userInfo = [String: Any]()
        userInfo[Asset.Keys.id] = asset.id
        userInfo[Asset.Keys.downloadState] = DownloadState.inProgress.rawValue
        
        NotificationCenter.default.post(name: .AssetDownloadStateChanged,
                                        object: nil,
                                        userInfo: userInfo)
    }
    
    func assetForStream(withId id: String) -> Asset? {
        activeDownloads.first(where: { $1.id == id })?.value
    }
    
    func localAssetForStream(withId key: String) -> AVURLAsset? {
        guard let localFileLocation = userDefaults.value(forKey: key) as? Data else {
            return nil
        }
        
        var bookmarkDataIsStale = false
        do {
            let url = try URL(resolvingBookmarkData: localFileLocation,
                              bookmarkDataIsStale: &bookmarkDataIsStale)

            if bookmarkDataIsStale {
                fatalError("Bookmark data is stale!")
            }
            
            return AVURLAsset(url: url)
        } catch {
            fatalError("Failed to create URL from bookmark with error: \(error)")
        }
    }

    func downloadState(for asset: Asset) -> DownloadState {
        if let localFileLocation = localAssetForStream(withId: asset.id)?.url {
            if FileManager.default.fileExists(atPath: localFileLocation.path) {
                return .completed
            }
        }
        
        for (_, assetValue) in activeDownloads where asset == assetValue {
            return .inProgress
        }

        return .idle
    }
    
    func deleteAsset(withId key: String) {
        do {
            if let localFileLocation = localAssetForStream(withId: key)?.url {
                try FileManager.default.removeItem(at: localFileLocation)

                userDefaults.removeObject(forKey: key)

                var userInfo = [String: Any]()
                userInfo[Asset.Keys.id] = key
                userInfo[Asset.Keys.downloadState] = DownloadState.idle.rawValue

                NotificationCenter.default.post(name: .AssetDownloadStateChanged,
                                                object: nil,
                                                userInfo: userInfo)
            }
        } catch {
            print("An error occured deleting the file: \(error)")
        }
    }
    
    func cancelDownload(for asset: Asset) {
        activeDownloads.first(where: { $0.value == asset })?.key.cancel()
    }
}

// MARK: - AVAssetDownloadDelegate

extension HLSService: AVAssetDownloadDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let downloadTask = task as? AVAggregateAssetDownloadTask,
            let asset = activeDownloads.removeValue(forKey: downloadTask) else {
                return
        }

        guard let downloadURL = willDownloadToUrl.removeValue(forKey: downloadTask) else {
            return
        }

        var userInfo = [String: Any]()
        userInfo[Asset.Keys.id] = asset.id

        if let error = error as NSError? {
            switch (error.domain, error.code) {
            case (NSURLErrorDomain, NSURLErrorCancelled):
                if let localFileLocation = localAssetForStream(withId: asset.id)?.url {
                    do {
                        try FileManager.default.removeItem(at: localFileLocation)

                        userDefaults.removeObject(forKey: asset.id)
                    } catch {
                        print("An error occured trying to delete the contents on disk for \(asset.id): \(error)")
                    }
                }
                
                userInfo[Asset.Keys.downloadState] = DownloadState.idle.rawValue

            case (NSURLErrorDomain, NSURLErrorUnknown):
                fatalError("Downloading HLS streams is not supported in the simulator.")

            default:
                fatalError("An unexpected error occured \(error.domain)")
            }
        } else {
            do {
                let bookmark = try downloadURL.bookmarkData()
                
                userDefaults.set(bookmark, forKey: asset.id)
            } catch {
                print("Failed to create bookmarkData for download URL.")
            }
            
            userInfo[Asset.Keys.downloadState] = DownloadState.completed.rawValue
        }

        NotificationCenter.default.post(name: .AssetDownloadStateChanged,
                                        object: nil,
                                        userInfo: userInfo)
    }
    
    func urlSession(_ session: URLSession,
                    aggregateAssetDownloadTask: AVAggregateAssetDownloadTask,
                    willDownloadTo location: URL) {
        willDownloadToUrl[aggregateAssetDownloadTask] = location
    }
    
    func urlSession(_ session: URLSession,
                    aggregateAssetDownloadTask: AVAggregateAssetDownloadTask,
                    didCompleteFor mediaSelection: AVMediaSelection) {
        guard let asset = activeDownloads[aggregateAssetDownloadTask] else {
            return
        }

        aggregateAssetDownloadTask.resume()

        var userInfo = [String: Any]()
        userInfo[Asset.Keys.id] = asset.id
        userInfo[Asset.Keys.downloadState] = DownloadState.inProgress.rawValue

        NotificationCenter.default.post(name: .AssetDownloadStateChanged,
                                        object: nil,
                                        userInfo: userInfo)
    }

    func urlSession(_ session: URLSession,
                    aggregateAssetDownloadTask: AVAggregateAssetDownloadTask,
                    didLoad timeRange: CMTimeRange,
                    totalTimeRangesLoaded loadedTimeRanges: [NSValue],
                    timeRangeExpectedToLoad: CMTimeRange,
                    for mediaSelection: AVMediaSelection) {
        guard let asset = activeDownloads[aggregateAssetDownloadTask] else {
            return
        }
        
        var percentComplete: Double = 0
        for value in loadedTimeRanges {
            let loadedTimeRange = value.timeRangeValue
            percentComplete +=
                loadedTimeRange.duration.seconds / timeRangeExpectedToLoad.duration.seconds
        }
        
        var userInfo = [String: Any]()
        userInfo[Asset.Keys.id] = asset.id
        userInfo[Asset.Keys.percentDownloaded] = percentComplete

        NotificationCenter.default.post(name: .AssetDownloadProgress,
                                        object: nil,
                                        userInfo: userInfo)
    }
}
