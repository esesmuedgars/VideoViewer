//
// Copyright © 2020 @esesmuedgars.
//

import SwiftUI
import AVFoundation

struct VideoDetails: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject private(set) var viewModel: ViewModel
    
    @State private var downloadProgress: CGFloat = 0
    
    var body: some View {
        ScrollView {
            VStack {
                if viewModel.isDownloading {
                    ProgressBar(value: $downloadProgress)
                        .frame(height: 5)
                        .onReceive(viewModel.$downloadProgress) { progress in
                            self.downloadProgress = progress
                    }
                }
                
                Player(url: viewModel.video.videoURL, asset: viewModel.avAsset)
                    .aspectRatio(.landscape, contentMode: .fit)
                
                VStack(spacing: 10) {
                    Text(viewModel.video.name)
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                    Text(viewModel.video.description)
                        .font(.body)
                        .foregroundColor(colorScheme == .dark ? Color.gray : Color.black)
                }
                
                Spacer()
            }
            .padding(15)
        }.navigationBarItems(trailing:
            Button(action: {
                self.viewModel.toggleVideoDownload()
            }, label: {
                Text(viewModel.isDownloading ? "Cancel download" : "Download video")
                Image(systemName: "square.and.arrow.down")
            })
            .opacity(viewModel.isOpaqueBarButton ? 1 : 0)
        ).navigationBarTitle("", displayMode: .inline)
    }
}

#if DEBUG
struct VideoDetails_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VideoDetails(viewModel: .init(video: .previewValue))
        }
    }
}
#endif
