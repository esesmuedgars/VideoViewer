//
// Copyright © 2020 @esesmuedgars.
//

import Foundation

enum Endpoint: String {
    case videos = "test-api/videos"
    
    var base: String {
        "https://iphonephotographyschool.com"
    }
}

extension URL {
    init?(endpoint: Endpoint) {
        guard var url = URL(string: endpoint.base) else {
            return nil
        }
        
        url.appendPathComponent(endpoint.rawValue)
        
        self = url
    }
}
