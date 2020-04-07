//
// Copyright © 2020 @esesmuedgars.
//

import Foundation
import AVFoundation
@testable import VideoViewer

protocol HLSServiceMockProtocol: class {
    var url: URL? { get set }
}

final class HLSServiceMock: HLSServiceProtocol, HLSServiceMockProtocol {
    
    var url: URL?
    func localAssetForStream(withId key: String) -> AVURLAsset? {
        guard let url = url else {
            return nil
        }
        
        return AVURLAsset(url: url)
    }
    
    func cancelDownload(for asset: Asset) {
        let userInfo = [
            Asset.Keys.id: asset.id,
            Asset.Keys.downloadState: HLSService.DownloadState.idle.rawValue
        ]
        
        NotificationCenter.default.post(name: .AssetDownloadStateChanged,
                                        object: nil,
                                        userInfo: userInfo)
    }
    
    func downloadStream(for asset: Asset) {
        let userInfo = [
            Asset.Keys.id: asset.id,
            Asset.Keys.downloadState: HLSService.DownloadState.inProgress.rawValue
        ]
              
        NotificationCenter.default.post(name: .AssetDownloadStateChanged,
                                        object: nil,
                                        userInfo: userInfo)
    }
}
