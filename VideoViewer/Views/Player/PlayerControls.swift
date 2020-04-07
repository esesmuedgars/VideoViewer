//
// Copyright © 2020 @esesmuedgars.
//

import SwiftUI
import AVFoundation

struct PlayerControls: View {
    let player: AVPlayer
    
    @Binding var isOpaque: Bool
    @Binding var isPlaying: Bool
    
    var body: some View {
        Image(systemName: isPlaying ? "pause.circle" : "play.circle")
            .resizable()
            .onTapGesture(perform: togglePlayer)
            .opacity(isOpaque ? 1 : 0)
            .animation(.easeInOut, value: isOpaque)
    }
    
    func togglePlayer() {
        if isPlaying {
            player.pause()
            isPlaying = false
            isOpaque = true
        } else {
            player.play()
            isPlaying = true

            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                self.isOpaque = false
            }
        }
    }
}

#if DEBUG
struct PlayerControls_Previews: PreviewProvider {
    static var previews: some View {
        PlayerControls(player: AVPlayer(),
                       isOpaque: .constant(true),
                       isPlaying: .constant(false))
            .frame(width: 50, height: 50)
    }
}
#endif
