//
// Copyright © 2020 @esesmuedgars.
//

import SwiftUI
import Combine
import Foundation

struct AsyncImage: View {
    @ObservedObject private(set) var imageLoader: ImageLoader
    @State private var isLoading: Bool = false

    init(url: URL) {
        imageLoader = ImageLoader(url: url)
    }
    
    private var image: some View {
        Group {
            if imageLoader.image != nil {
                Image(uiImage: imageLoader.image!)
                    .resizable()
            } else {
                ActivityIndicator(isAnimating: $isLoading, style: .medium)
            }
        }
    }
    
    var body: some View {
        image.onAppear(perform: {
                self.isLoading = true
                self.imageLoader.loadImage()
            })
            .onReceive(imageLoader.$image, perform: { output in
                self.isLoading = false
                self.imageLoader.cancelTask()
            })
            .onDisappear(perform: imageLoader.cancelTask)
    }
}
