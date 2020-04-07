//
// Copyright © 2020 @esesmuedgars.
//

import SwiftUI
import AVFoundation
import Combine

struct Player: View {
    private let player: AVPlayer
    
    @State private var isPlaying = false
    @State private var controlsAreVisible = true
        
    init(url: URL, asset: AVURLAsset?) {
        var playerItem: AVPlayerItem
        
        if let asset = asset {
            playerItem = AVPlayerItem(asset: asset)
        } else {
            playerItem = AVPlayerItem(url: url)
        }
        
        player = AVPlayer(playerItem: playerItem)
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            PlayerView(player: player)
                .cornerRadius(5, antialiased: true)
                .onTapGesture {
                    self.controlsAreVisible.toggle()
                    
                    // FIXME: Should have a debounce
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                        if self.isPlaying {
                            self.controlsAreVisible = false
                        }
                    }
                }
            
            PlayerControls(player: player,
                           isOpaque: $controlsAreVisible,
                           isPlaying: $isPlaying)
                .frame(width: 50, height: 50)
            
        }
        .foregroundColor(.white)
        .onDisappear(perform: player.pause)
    }
}

#if DEBUG
struct Player_Previews: PreviewProvider {
    static var previews: some View {
        Player(url: Response.Video.previewValue.videoURL, asset: nil)
            .aspectRatio(.landscape, contentMode: .fit)
            .padding(.horizontal, 15)
    }
}
#endif
