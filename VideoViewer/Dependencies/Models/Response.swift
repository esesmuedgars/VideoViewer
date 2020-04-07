//
// Copyright © 2020 @esesmuedgars.
//

import Foundation

struct Response: Decodable {
    let videos: [Video]
    
    struct Video: Identifiable, Equatable {
        let id: Int
        let name: String
        let thumbnailURL: URL
        let description: String
        let videoURL: URL
    }
}

extension Response.Video: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case thumbnail
        case description
        case video = "video_link"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        let thumbnail = try container.decode(String.self, forKey: .thumbnail)
        guard let thumbnailURL = URL(string: thumbnail) else {
            throw DecodingError.dataCorruptedError(forKey: .thumbnail,
                                                   in: container,
                                                   debugDescription: "\"\(thumbnail)\" is not a valid URL.")
            
        }
        
        self.thumbnailURL = thumbnailURL
        
        description = try container.decode(String.self, forKey: .description)
        
        let video = try container.decode(String.self, forKey: .video)
        guard let videoURL = URL(string: video) else {
            throw DecodingError.dataCorruptedError(forKey: .video,
                                                   in: container,
                                                   debugDescription: "\"\(thumbnail)\" is not a valid URL.")
        }
        
        self.videoURL = videoURL
    }
}

#if DEBUG
extension Response.Video {
    static var previewValue: Response.Video {
        Response.Video(
            id: 29,
            name: "How To Hold Your iPhone When Taking Photos",
            thumbnailURL: URL(string: "https://i.picsum.photos/id/29/2000/2000.jpg")!,
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
            videoURL: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!
        )
    }
}
#endif
