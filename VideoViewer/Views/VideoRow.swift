//
// Copyright © 2020 @esesmuedgars.
//

import SwiftUI

struct VideoRow: View {
    var video: VideoUseCase
    
    var body: some View {
        HStack(alignment: .center) {
            AsyncImage(url: video.thumbnailURL)
                .frame(width: 60, height: 60, alignment: .center)
                .cornerRadius(5, antialiased: true)
                .id(video.id)
            
            Text(video.name)
            Spacer()
        }
    }
}

#if DEBUG
struct VideoRow_Previews: PreviewProvider {
    static var previews: some View {
        VideoRow(video: .previewValue)
    }
}
#endif
