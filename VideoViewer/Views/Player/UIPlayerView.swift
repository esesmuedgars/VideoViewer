//
// Copyright © 2020 @esesmuedgars.
//

import UIKit
import AVFoundation

final class UIPlayerView: UIView {
    let playerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer()
        playerLayer.videoGravity = .resizeAspectFill
        
        return playerLayer
    }()
    
    init(frame: CGRect = .zero, player: AVPlayer) {
        super.init(frame: frame)
        
        backgroundColor = .black
        
        playerLayer.player = player
        
        layer.addSublayer(playerLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("UIPlayerView.init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playerLayer.frame = bounds
    }
}
