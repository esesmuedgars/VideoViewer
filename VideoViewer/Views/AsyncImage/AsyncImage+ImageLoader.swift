//
// Copyright © 2020 @esesmuedgars.
//

import SwiftUI
import Combine

extension AsyncImage {
    class ImageLoader: ObservableObject {
        @Environment(\.imageCache) private var imageCache
        @Published private(set) var image: UIImage?
        
        private let url: URL
        private var dataTask: Cancellable?
        
        init(url: URL) {
            self.url = url
        }
        
        func loadImage() {
            if let image = imageCache[url] {
                self.image = image
                return
            }
            
            dataTask = URLSession.shared.dataTaskPublisher(for: url)
                .map { (data, _) in
                    UIImage(data: data)
                }
                .replaceError(with: UIImage())
                .handleEvents(receiveOutput: { image in
                    self.imageCache[self.url] = image
                })
                .receive(on: DispatchQueue.main)
                .assign(to: \.image, on: self)
        }
        
        func cancelTask() {
            dataTask?.cancel()
        }
        
        deinit {
            dataTask?.cancel()
        }
    }
}
