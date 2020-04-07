//
// Copyright © 2020 @esesmuedgars.
//

import Foundation
import CoreData

final class VideoItem: NSManagedObject, Identifiable {
    @NSManaged var id: Int
    @NSManaged var name: String
    @NSManaged var thumbnailURL: URL
    @NSManaged var itemDescription: String
    @NSManaged var videoURL: URL
    
    func set(_ video: Response.Video) {
        id = video.id
        name = video.name
        thumbnailURL = video.thumbnailURL
        itemDescription = video.description
        videoURL = video.videoURL
    }
    
    func update(_ video: Response.Video) {
        guard id == video.id else {
            return
        }
        
        name = video.name
        thumbnailURL = video.thumbnailURL
        itemDescription = video.description
        videoURL = video.videoURL
    }
}
