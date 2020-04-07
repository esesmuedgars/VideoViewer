//
// Copyright © 2020 @esesmuedgars.
//

import SwiftUI
import Combine

struct VideoList: View {
    @ObservedObject private(set) var viewModel: ViewModel
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationView {
            List(viewModel.videos, id: \.id) { video in
                NavigationLink(
                destination: VideoDetails(viewModel: VideoDetails.ViewModel(video: video))) {
                    VideoRow(video: video)
                }
            }
            .onPullToRefresh(isRefreshing: $isRefreshing, perform: {
                self.viewModel.fetchVideos()
            })
            .onReceive(viewModel.$videos, perform: { _ in
                self.isRefreshing = false
            })
            .navigationBarTitle(viewModel.navigationBarTitle)
        }
        .onAppear(perform: viewModel.fetchVideos)
    }
}

#if DEBUG
struct VideoList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VideoList(viewModel: .init())
        }
    }
}
#endif
