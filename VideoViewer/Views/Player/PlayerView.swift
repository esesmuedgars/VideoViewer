//
// Copyright © 2020 @esesmuedgars.
//

import SwiftUI
import AVFoundation

struct PlayerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: UIViewRepresentableContext<PlayerView>) -> UIPlayerView {
        return UIPlayerView(player: player)
    }
    
    func updateUIView(_ uiView: UIPlayerView, context: UIViewRepresentableContext<PlayerView>) {
        uiView.playerLayer.player = player
    }
}
