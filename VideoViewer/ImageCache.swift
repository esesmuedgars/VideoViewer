//
// Copyright © 2020 @esesmuedgars.
//

import Foundation
import SwiftUI

struct ImageCacheEnvironmentKey: EnvironmentKey {
    static let defaultValue = ImageCache()
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get {
            self[ImageCacheEnvironmentKey.self]
        }
        set {
            self[ImageCacheEnvironmentKey.self] = newValue
        }
    }
}

class ImageCache {
    private let cache = NSCache<NSURL, UIImage>()
    
    subscript(_ key: URL) -> UIImage? {
        get {
            cache.object(forKey: key as NSURL)
        }
        set {
            if let value = newValue {
                cache.setObject(value, forKey: key as NSURL)
            } else {
                cache.removeObject(forKey: key as NSURL)
            }
        }
    }
}
