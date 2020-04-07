//
// Copyright © 2020 @esesmuedgars.
//

import AVFoundation
import Combine

extension VideoDetails {
    class ViewModel: NSObject, ObservableObject, AVAssetDownloadDelegate {
        @Published private(set) var downloadProgress: CGFloat = 0
        @Published private(set) var isOpaqueBarButton: Bool = true
        @Published private(set) var isDownloading: Bool = false
        @Published private(set) var avAsset: AVURLAsset? = nil
        private var cancellable: Cancellable?
        
        let video: VideoUseCase
        let asset: Asset
        let hlsService: HLSServiceProtocol
        
        init(video: VideoUseCase, hlsService: HLSServiceProtocol = Dependencies.shared.hlsService) {
            self.video = video
            self.asset = Asset(video)
            self.hlsService = hlsService
                    
            super.init()
            
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self,
                                           selector: #selector(handleAssetDownloadStateChanged(_:)),
                                           name: .AssetDownloadStateChanged,
                                           object: nil)
            notificationCenter.addObserver(self,
                                           selector: #selector(handleAssetDownloadProgress(_:)),
                                           name: .AssetDownloadProgress,
                                           object: nil)
            
            avAsset = hlsService.localAssetForStream(withId: asset.id)
            
            cancellable = $avAsset.map({ $0 == nil })
                .receive(on: DispatchQueue.main)
                .assign(to: \.isOpaqueBarButton, on: self)
        }
        
        @objc
        private func handleAssetDownloadStateChanged(_ notification: Notification) {
            guard let assetStreamId = notification.userInfo?[Asset.Keys.id] as? String,
                let downloadStateRawValue = notification.userInfo?[Asset.Keys.downloadState] as? String,
                let downloadState = HLSService.DownloadState(rawValue: downloadStateRawValue),
                assetStreamId == asset.id else {
                    return
            }
            
            isDownloading = downloadState == .inProgress
            
            guard case .completed = downloadState else {
                return
            }
            
            avAsset = hlsService.localAssetForStream(withId: asset.id)
        }

        @objc
        private func handleAssetDownloadProgress(_ notification: Notification) {
            guard let assetStreamId = notification.userInfo?[Asset.Keys.id] as? String,
                assetStreamId == asset.id else {
                return
            }
            
            guard let progress = notification.userInfo?[Asset.Keys.percentDownloaded] as? Double else {
                return
            }

            self.downloadProgress = CGFloat(progress)
        }
        
        func toggleVideoDownload() {
            if isDownloading {
                hlsService.cancelDownload(for: asset)
                downloadProgress = 0
            } else {
                hlsService.downloadStream(for: asset)
            }
        }
    }
}
