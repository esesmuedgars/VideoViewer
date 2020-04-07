//
// Copyright © 2020 @esesmuedgars.
//

import Foundation

struct VideoUseCase {
    let id: Int
    let name: String
    let thumbnailURL: URL
    let description: String
    let videoURL: URL
}

#if DEBUG
extension VideoUseCase {
    static var previewValue: VideoUseCase {
        VideoUseCase(
            id: 29,
            name: "How To Hold Your iPhone When Taking Photos",
            thumbnailURL: URL(string: "https://i.picsum.photos/id/29/2000/2000.jpg")!,
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
            videoURL: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!
        )
    }
}
#endif
