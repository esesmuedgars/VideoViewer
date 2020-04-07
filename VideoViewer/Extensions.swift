//
// Copyright © 2020 @esesmuedgars.
//

import UIKit

extension CGFloat {
    static var landscape: CGFloat { 16 / 9 }
    
    static var square: CGFloat { 1 }
    
    static var classic: CGFloat { 4 / 3 }
    
    static var cinemascope: CGFloat { 21 / 9 }
}

extension Notification.Name {
    static let AssetDownloadProgress = Notification.Name(rawValue: "AssetDownloadProgressNotification")
    
    static let AssetDownloadStateChanged = Notification.Name(rawValue: "AssetDownloadStateChangedNotification")
}
