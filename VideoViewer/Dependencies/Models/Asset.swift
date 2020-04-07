//
// Copyright © 2020 @esesmuedgars.
//

import Foundation

struct Asset: Equatable {
    let id: String
    let url: URL
    
    struct Keys {
        static let id = "AssetIdentifierKey"
        static let percentDownloaded = "AssetPercentDownloadedKey"
        static let downloadState = "AssetDownloadStateKey"
    }
}
