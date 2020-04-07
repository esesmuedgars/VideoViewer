//
// Copyright © 2020 @esesmuedgars.
//

import Foundation
import Combine
import SwiftUI

extension VideoList {
    class ViewModel: ObservableObject {
        @Published private(set) var videos = [VideoUseCase]()
        private var dataTask: Cancellable?
        
        let navigationBarTitle = "Videos"
        
        private let apiService: APIServiceProtocol
        private let coreDataService: CoreDataServiceProtocol
                
        init(apiService: APIServiceProtocol = Dependencies.shared.apiService,
             coreDataService: CoreDataServiceProtocol = Dependencies.shared.coreDataService) {
            self.apiService = apiService
            self.coreDataService = coreDataService
        }
        
        func fetchVideos() {
            dataTask = apiService.fetchVideos()
                .tryMap { videos -> [VideoUseCase] in
                    let videoItems = try self.coreDataService.fetchVideoItems()
                    
                    for video in videos {
                        if let videoItem = videoItems.first(where: { $0.id == video.id }) {
                            videoItem.update(video)
                        } else {
                            self.coreDataService.setItem(video)
                        }
                    }
                    
                    try self.coreDataService.saveContext()
                    
                    return try self.coreDataService.fetchVideoItems().map { videoItem in
                        VideoUseCase(id: videoItem.id,
                                     name: videoItem.name,
                                     thumbnailURL: videoItem.thumbnailURL,
                                     description: videoItem.itemDescription,
                                     videoURL: videoItem.videoURL)
                    }
                }
                .replaceError(with: [])
                .receive(on: DispatchQueue.main)
                .assign(to: \.videos, on: self)
        }
    }
}
